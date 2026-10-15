"""IronMind AI Production FastAPI Backend

Provides user authentication (PBKDF2 + Bearer Tokens), profile storage,
workout history persistence in SQLite, progress analytics, and dynamic exercise recommendations.
"""
from contextlib import asynccontextmanager
from datetime import datetime, timezone
import hashlib
import os
from pathlib import Path
import secrets
import sqlite3

from fastapi import Depends, FastAPI, HTTPException, Header, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field

from app.services.recommendations import workout_for_goal

DATABASE = Path(__file__).resolve().parent.parent / "ironmind.db"

# Active user token session store (in-memory token -> user_id)
TOKEN_SESSIONS: dict[str, str] = {}


def connection() -> sqlite3.Connection:
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db


def hash_password(password: str, salt_hex: str | None = None) -> tuple[str, str]:
    """Hash password using PBKDF2-HMAC-SHA256 with 100,000 iterations."""
    if salt_hex is None:
        salt_bytes = os.urandom(16)
        salt_hex = salt_bytes.hex()
    else:
        salt_bytes = bytes.fromhex(salt_hex)
    hash_bytes = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt_bytes, 100000)
    return hash_bytes.hex(), salt_hex


def initialise_database() -> None:
    with connection() as db:
        db.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            user_id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            fitness_level TEXT NOT NULL DEFAULT 'Beginner',
            goal TEXT NOT NULL DEFAULT 'Build strength',
            created_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS profiles (
            user_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            fitness_level TEXT NOT NULL,
            goal TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
        );
        CREATE TABLE IF NOT EXISTS workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            exercise TEXT NOT NULL,
            reps INTEGER NOT NULL,
            form_score INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
        );
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
        CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
        CREATE INDEX IF NOT EXISTS idx_workouts_completed ON workouts(completed_at);
        """)


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialise_database()
    yield


app = FastAPI(
    title="IronMind AI Production API",
    description="Backend API for IronMind AI: Auth, Profiles, Workouts, and Pose Analytics.",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Request & Response Models ---

class RegisterRequest(BaseModel):
    email: str
    name: str = Field(min_length=2, max_length=80)
    password: str = Field(min_length=6, max_length=128)
    fitness_level: str = "Beginner"
    goal: str = "Build strength"


class LoginRequest(BaseModel):
    email: str
    password: str


class RecommendationRequest(BaseModel):
    goal: str
    level: str = "Beginner"


class ProfileRequest(BaseModel):
    user_id: str = "demo-user"
    name: str = Field(min_length=1, max_length=80)
    fitness_level: str
    goal: str


class WorkoutRequest(BaseModel):
    user_id: str = "demo-user"
    exercise: str
    reps: int = Field(ge=0, le=10000)
    form_score: int = Field(ge=0, le=100)
    duration_seconds: int = Field(ge=0, le=86400)


# --- Auth Helper ---

def get_current_user_id(authorization: str = Header(None)) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        return "demo-user"
    token = authorization.split("Bearer ", 1)[1].strip()
    user_id = TOKEN_SESSIONS.get(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired session token",
        )
    return user_id


# --- API Routes ---

@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "ironmind-ai-production", "version": "1.0.0"}


@app.post("/auth/register", status_code=status.HTTP_201_CREATED)
def register(req: RegisterRequest) -> dict:
    user_id = f"usr_{secrets.token_hex(8)}"
    now = datetime.now(timezone.utc).isoformat()
    pwd_hash, salt = hash_password(req.password)

    with connection() as db:
        existing = db.execute("SELECT user_id FROM users WHERE email = ?", (req.email.lower(),)).fetchone()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email already exists",
            )

        db.execute(
            """INSERT INTO users(user_id, email, name, password_hash, salt, fitness_level, goal, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (user_id, req.email.lower(), req.name, pwd_hash, salt, req.fitness_level, req.goal, now),
        )
        db.execute(
            """INSERT INTO profiles(user_id, name, fitness_level, goal, updated_at)
            VALUES (?, ?, ?, ?, ?)""",
            (user_id, req.name, req.fitness_level, req.goal, now),
        )

    token = f"tok_{secrets.token_hex(24)}"
    TOKEN_SESSIONS[token] = user_id

    return {
        "token": token,
        "user": {
            "user_id": user_id,
            "email": req.email.lower(),
            "name": req.name,
            "fitness_level": req.fitness_level,
            "goal": req.goal,
        },
    }


@app.post("/auth/login")
def login(req: LoginRequest) -> dict:
    with connection() as db:
        user = db.execute("SELECT * FROM users WHERE email = ?", (req.email.lower(),)).fetchone()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    expected_hash, _ = hash_password(req.password, user["salt"])
    if expected_hash != user["password_hash"]:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    user_id = user["user_id"]
    token = f"tok_{secrets.token_hex(24)}"
    TOKEN_SESSIONS[token] = user_id

    return {
        "token": token,
        "user": {
            "user_id": user_id,
            "email": user["email"],
            "name": user["name"],
            "fitness_level": user["fitness_level"],
            "goal": user["goal"],
        },
    }


@app.get("/auth/me")
def get_me(user_id: str = Depends(get_current_user_id)) -> dict:
    with connection() as db:
        user = db.execute(
            "SELECT user_id, email, name, fitness_level, goal, created_at FROM users WHERE user_id = ?",
            (user_id,),
        ).fetchone()

    if not user:
        return {
            "user_id": user_id,
            "email": "demo@ironmind.ai",
            "name": "Demo User",
            "fitness_level": "Beginner",
            "goal": "Build strength",
        }
    return dict(user)


@app.post("/recommendations")
def recommendations(request: RecommendationRequest) -> dict:
    return {"goal": request.goal, "level": request.level, "workout": workout_for_goal(request.goal)}


@app.put("/profiles")
def save_profile(profile: ProfileRequest) -> dict:
    timestamp = datetime.now(timezone.utc).isoformat()
    with connection() as db:
        db.execute(
            """INSERT INTO profiles(user_id, name, fitness_level, goal, updated_at)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(user_id) DO UPDATE SET name=excluded.name,
            fitness_level=excluded.fitness_level, goal=excluded.goal,
            updated_at=excluded.updated_at""",
            (profile.user_id, profile.name, profile.fitness_level, profile.goal, timestamp),
        )
        db.execute(
            """UPDATE users SET name = ?, fitness_level = ?, goal = ? WHERE user_id = ?""",
            (profile.name, profile.fitness_level, profile.goal, profile.user_id),
        )
    return {"saved": True, "user_id": profile.user_id}


@app.get("/profiles/{user_id}")
def get_profile(user_id: str) -> dict:
    with connection() as db:
        row = db.execute("SELECT * FROM profiles WHERE user_id = ?", (user_id,)).fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return dict(row)


@app.post("/workouts")
def save_workout(workout: WorkoutRequest) -> dict:
    completed_at = datetime.now(timezone.utc).isoformat()
    with connection() as db:
        cursor = db.execute(
            """INSERT INTO workouts(user_id, exercise, reps, form_score,
            duration_seconds, completed_at) VALUES (?, ?, ?, ?, ?, ?)""",
            (workout.user_id, workout.exercise, workout.reps, workout.form_score,
             workout.duration_seconds, completed_at),
        )
    return {"saved": True, "workout_id": cursor.lastrowid}


@app.get("/workouts/{user_id}")
def list_workouts(user_id: str) -> list[dict]:
    with connection() as db:
        rows = db.execute(
            "SELECT * FROM workouts WHERE user_id = ? ORDER BY id DESC", (user_id,)
        ).fetchall()
    return [dict(row) for row in rows]


@app.get("/analytics/{user_id}")
def analytics(user_id: str) -> dict:
    with connection() as db:
        row = db.execute(
            """SELECT COUNT(*) AS sessions, COALESCE(SUM(reps), 0) AS total_reps,
            COALESCE(ROUND(AVG(form_score)), 0) AS average_form_score,
            COALESCE(SUM(duration_seconds), 0) AS total_duration_seconds
            FROM workouts WHERE user_id = ?""",
            (user_id,),
        ).fetchone()
    return dict(row)

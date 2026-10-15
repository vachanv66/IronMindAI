"""IronMind AI — Demo Database Seeding Script

Populates the SQLite database (ironmind.db) with a demo user and sample workout records
for demonstration and evaluation.
"""
from datetime import datetime, timezone, timedelta
from pathlib import Path
import sqlite3
import hashlib
import os

DATABASE = Path(__file__).resolve().parent / "ironmind.db"


def seed():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()

    # Ensure tables exist
    cursor.executescript("""
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
        updated_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        exercise TEXT NOT NULL,
        reps INTEGER NOT NULL,
        form_score INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        completed_at TEXT NOT NULL
    );
    """)

    # Seed Demo User
    salt_bytes = os.urandom(16)
    pwd_hash = hashlib.pbkdf2_hmac('sha256', 'password123'.encode('utf-8'), salt_bytes, 100000).hex()
    now = datetime.now(timezone.utc)

    cursor.execute("""
    INSERT INTO users (user_id, email, name, password_hash, salt, fitness_level, goal, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(user_id) DO UPDATE SET name=excluded.name, fitness_level=excluded.fitness_level, goal=excluded.goal
    """, ("demo-user", "demo@ironmind.ai", "Demo Athlete", pwd_hash, salt_bytes.hex(), "Intermediate", "Build strength", now.isoformat()))

    cursor.execute("""
    INSERT INTO profiles (user_id, name, fitness_level, goal, updated_at)
    VALUES (?, ?, ?, ?, ?)
    ON CONFLICT(user_id) DO UPDATE SET name=excluded.name, fitness_level=excluded.fitness_level, goal=excluded.goal
    """, ("demo-user", "Demo Athlete", "Intermediate", "Build strength", now.isoformat()))

    # Sample workout sessions over the past few days
    samples = [
        ("Squats", 15, 94, 180, now - timedelta(days=3)),
        ("Push-ups", 12, 90, 150, now - timedelta(days=2, hours=4)),
        ("Lunges", 14, 88, 210, now - timedelta(days=1, hours=8)),
        ("Jumping Jacks", 25, 96, 120, now - timedelta(hours=14)),
        ("Plank", 45, 92, 45, now - timedelta(hours=2)),
    ]

    for ex, reps, score, secs, date in samples:
        cursor.execute("""
        INSERT INTO workouts (user_id, exercise, reps, form_score, duration_seconds, completed_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, ("demo-user", ex, reps, score, secs, date.isoformat()))

    conn.commit()
    conn.close()
    print("[SUCCESS] Database successfully initialized and seeded with sample workout data in ironmind.db!")


if __name__ == "__main__":
    seed()

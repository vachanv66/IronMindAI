"""IronMind AI — Database Viewer Script

Displays all registered users and workout records directly in the terminal.
"""
from pathlib import Path
import sqlite3

DATABASE = Path(__file__).resolve().parent / "ironmind.db"


def view_data():
    if not DATABASE.exists():
        print(f"[ERROR] Database file not found at: {DATABASE}")
        return

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()

    print("=" * 65)
    print("               IRONMIND AI — DATABASE VIEWER")
    print("=" * 65)

    # 1. Users Table
    print("\n--- [TABLE: users] ---")
    try:
        cursor.execute("SELECT user_id, email, name, fitness_level, goal, created_at FROM users")
        users = cursor.fetchall()
        if users:
            for u in users:
                print(f"User ID       : {u[0]}")
                print(f"Email         : {u[1]}")
                print(f"Name          : {u[2]}")
                print(f"Fitness Level : {u[3]}")
                print(f"Goal          : {u[4]}")
                print(f"Created At    : {u[5]}")
                print("-" * 40)
        else:
            print("No users found.")
    except Exception as e:
        print(f"Error querying users: {e}")

    # 2. Workouts Table
    print("\n--- [TABLE: workouts] ---")
    try:
        cursor.execute("SELECT id, user_id, exercise, reps, form_score, duration_seconds, completed_at FROM workouts ORDER BY id DESC")
        workouts = cursor.fetchall()
        if workouts:
            print(f"{'ID':<4} | {'User ID':<12} | {'Exercise':<15} | {'Reps':<5} | {'Score':<6} | {'Duration':<9} | {'Date'}")
            print("-" * 80)
            for w in workouts:
                print(f"{w[0]:<4} | {w[1]:<12} | {w[2]:<15} | {w[3]:<5} | {w[4]:<5}% | {w[5]}s{'':<5} | {w[6][:19]}")
        else:
            print("No workouts recorded yet.")
    except Exception as e:
        print(f"Error querying workouts: {e}")

    conn.close()
    print("\n" + "=" * 65)


if __name__ == "__main__":
    view_data()

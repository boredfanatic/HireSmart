"""
insert_skills.py — Insert parsed CV skills into the database for a candidate.

Usage:
    python insert_skills.py <candidate_id>

Steps:
    1. Reads data/parsed_cv.json (output of cv_parser.py)
    2. Ensures every skill exists in the Skills table (inserts if missing)
    3. Inserts/updates rows in CandidateSkills with proficiency levels:
         count >= 3  ->  proficiency 9
         count == 1 or 2  ->  proficiency 7
"""

import json
import sys
import mysql.connector

# -- DB config — update to match your XAMPP setup -------------------------
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",
    "password": "",
    "database": "HireSmart",
}
PARSED_CV_PATH = "data/parsed_cv.json"
# -------------------------------------------------------------------------


def load_parsed_cv(path):
    with open(path, "r") as f:
        data = json.load(f)
    skills = data.get("skills", {})
    if isinstance(skills, list):
        # backwards-compat: old format was a list, treat each as count=1
        skills = {s: 1 for s in skills}
    return skills  # {skill_name: count}


def load_skill_category_map(dictionary_path="python/skills_dictionary.json"):
    """Returns {skill_name_lower: (canonical_name, category)} from the dictionary."""
    with open(dictionary_path, "r") as f:
        data = json.load(f)
    mapping = {}
    for category, skill_list in data.items():
        for skill in skill_list:
            mapping[skill.lower()] = (skill, category)
    return mapping


def ensure_skill_exists(cursor, skill_name, category):
    """Insert skill if it doesn't exist; return its skill_id."""
    cursor.execute(
        "INSERT IGNORE INTO Skills (skill_name, category) VALUES (%s, %s)",
        (skill_name, category)
    )
    cursor.execute(
        "SELECT skill_id FROM Skills WHERE skill_name = %s",
        (skill_name,)
    )
    row = cursor.fetchone()
    return row[0] if row else None


def proficiency_from_count(count):
    return 9 if count >= 3 else 7


def insert_candidate_skills(candidate_id, skill_counts):
    skill_category_map = load_skill_category_map()

    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    inserted = 0
    skipped = 0

    try:
        for skill_name, count in skill_counts.items():
            lookup = skill_category_map.get(skill_name.lower())
            if lookup is None:
                print(f"  [skip] '{skill_name}' not in dictionary — skipping")
                skipped += 1
                continue

            canonical_name, category = lookup
            skill_id = ensure_skill_exists(cursor, canonical_name, category)
            if skill_id is None:
                print(f"  [error] Could not resolve skill_id for '{canonical_name}'")
                skipped += 1
                continue

            proficiency = proficiency_from_count(count)

            cursor.execute(
                """
                INSERT INTO CandidateSkills (candidate_id, skill_id, proficiency_level)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE proficiency_level = VALUES(proficiency_level)
                """,
                (candidate_id, skill_id, proficiency)
            )
            inserted += 1

        conn.commit()
        print(f"\nDone. {inserted} skill(s) inserted/updated, {skipped} skipped.")

    except mysql.connector.Error as e:
        conn.rollback()
        print(f"Database error: {e}")
        sys.exit(1)
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python insert_skills.py <candidate_id>")
        sys.exit(1)

    try:
        candidate_id = int(sys.argv[1])
    except ValueError:
        print("Error: candidate_id must be an integer.")
        sys.exit(1)

    print(f"Loading parsed CV from '{PARSED_CV_PATH}'...")
    skill_counts = load_parsed_cv(PARSED_CV_PATH)

    if not skill_counts:
        print("No skills found in parsed CV. Run cv_parser.py first.")
        sys.exit(0)

    print(f"Found {len(skill_counts)} skill(s). Inserting for candidate_id={candidate_id}...\n")
    insert_candidate_skills(candidate_id, skill_counts)
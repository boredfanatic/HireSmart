import pdfplumber
import json
import re

with open("python/skills_dictionary.json", "r") as f:
    skills_data = json.load(f)

all_skills = []
for category in skills_data.values():
    all_skills.extend(category)

skill_map = {skill.lower(): skill for skill in all_skills}
all_skills_lower = list(skill_map.keys())

def extract_text_from_pdf(file_path):
    text = ""
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            text += (page.extract_text() or "") + " "
    return text.lower()

def extract_skills(text, skills_list):
    skill_counts = {}

    for skill in skills_list:
        pattern = r'\b' + re.escape(skill) + r'\b'
        matches = re.findall(pattern, text)
        if matches:
            skill_counts[skill] = len(matches)

    return skill_counts

def parse_cv(file_path):
    text = extract_text_from_pdf(file_path)

    counts_lower = extract_skills(text, all_skills_lower)
    # map back to original casing and store counts
    skill_counts = {skill_map[s]: count for s, count in counts_lower.items()}

    result = {
        "skills": skill_counts
    }

    with open("data/parsed_cv.json", "w") as f:
        json.dump(result, f, indent=4)

    print("Parsing complete. Skills extracted:")
    print(list(skill_counts.keys()))

if __name__ == "__main__":
    file_path = "data/uploads/resume.pdf"  
    parse_cv(file_path)
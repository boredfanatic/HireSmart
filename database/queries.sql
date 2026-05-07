USE HireSmart;

SELECT * FROM Users;

SELECT c.candidate_id,c.full_name,u.email,c.phone
FROM Candidates c
INNER JOIN Users u ON c.user_id=u.user_id;

SELECT e.employer_id,e.company_name,e.company_description,u.email
FROM Employers e
INNER JOIN Users u ON e.user_id=u.user_id;

SELECT j.job_id,j.job_title,COUNT(js.skill_id) AS total_skills_required
FROM Jobs j
LEFT JOIN JobSkills js ON j.job_id=js.job_id
GROUP BY j.job_id,j.job_title;

SELECT s.skill_name,COUNT(js.job_id) AS demand_count
FROM Skills s
INNER JOIN JobSkills js ON s.skill_id=js.skill_id
GROUP BY s.skill_name
ORDER BY demand_count DESC;

SELECT c.full_name,u.email,s.skill_name,cs.proficiency_level
FROM Candidates c
INNER JOIN Users u ON c.user_id=u.user_id
INNER JOIN CandidateSkills cs ON c.candidate_id=cs.candidate_id
INNER JOIN Skills s ON cs.skill_id=s.skill_id
ORDER BY c.candidate_id;

SELECT c.full_name,COUNT(cs.skill_id) AS total_skills
FROM Candidates c
LEFT JOIN CandidateSkills cs ON c.candidate_id=cs.candidate_id
GROUP BY c.candidate_id;

SELECT a.application_id,c.full_name,j.job_title,e.company_name,a.match_score,a.status
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id=c.candidate_id
INNER JOIN Jobs j ON a.job_id=j.job_id
INNER JOIN Employers e ON j.employer_id=e.employer_id;

SELECT j.job_title,ROUND(AVG(a.match_score),2) AS avg_match_score
FROM Jobs j
LEFT JOIN Applications a ON j.job_id=a.job_id
GROUP BY j.job_id;

SELECT j.job_title,ROUND(AVG(a.match_score),2) AS avg_score
FROM Jobs j
INNER JOIN Applications a ON j.job_id=a.job_id
GROUP BY j.job_id
ORDER BY avg_score DESC;

SELECT a.job_id,c.full_name,a.match_score,
RANK() OVER(PARTITION BY a.job_id ORDER BY a.match_score DESC) AS job_rank
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id=c.candidate_id;

SELECT c.full_name,COUNT(js.skill_id) AS matching_skills
FROM Candidates c
INNER JOIN CandidateSkills cs ON c.candidate_id=cs.candidate_id
INNER JOIN JobSkills js ON cs.skill_id=js.skill_id
GROUP BY c.candidate_id
ORDER BY matching_skills DESC;

SELECT j.job_title,COUNT(a.application_id) AS applicants,COUNT(js.skill_id) AS required_skills
FROM Jobs j
LEFT JOIN Applications a ON j.job_id=a.job_id
LEFT JOIN JobSkills js ON j.job_id=js.job_id
GROUP BY j.job_id;

SELECT status,COUNT(*) AS total_jobs
FROM Jobs
GROUP BY status;

SELECT status,COUNT(*) AS total_applications
FROM Applications
GROUP BY status;

SELECT e.company_name,COUNT(j.job_id) AS jobs_posted
FROM Employers e
LEFT JOIN Jobs j ON e.employer_id=j.employer_id
GROUP BY e.employer_id
ORDER BY jobs_posted DESC;
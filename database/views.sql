CREATE VIEW CandidateProfileView AS
SELECT
    c.candidate_id,
    c.full_name,
    c.phone,
    c.resume_path,
    u.email,
    u.created_at        AS registered_at,
    s.skill_id,
    s.skill_name,
    s.category          AS skill_category,
    cs.proficiency_level
FROM Candidates c
INNER JOIN Users          u  ON c.user_id      = u.user_id
INNER JOIN CandidateSkills cs ON c.candidate_id = cs.candidate_id
INNER JOIN Skills          s  ON cs.skill_id    = s.skill_id;



CREATE VIEW OpenJobsWithSkillCountView AS
SELECT
    j.job_id,
    j.job_title,
    j.job_description,
    j.location,
    j.salary_range,
    j.status,
    j.application_limit,                        
    j.created_at,
    e.employer_id,
    e.company_name,
    e.company_description,
    COUNT(DISTINCT js.skill_id)      AS required_skill_count,
    COUNT(DISTINCT a.application_id) AS total_applicants
FROM Jobs j
INNER JOIN Employers   e  ON j.employer_id = e.employer_id
LEFT  JOIN JobSkills   js ON j.job_id      = js.job_id
LEFT  JOIN Applications a  ON j.job_id     = a.job_id
WHERE j.status = 'open'
GROUP BY
    j.job_id,
    j.job_title,
    j.job_description,
    j.location,
    j.salary_range,
    j.status,
    j.application_limit,                        -
    j.created_at,
    e.employer_id,
    e.company_name,
    e.company_description;


CREATE VIEW TopCandidatesView AS
SELECT
    a.application_id,
    a.match_score,
    a.status        AS application_status,
    a.applied_at,
    j.job_id,
    j.job_title,
    e.company_name,
    c.candidate_id,
    c.full_name,
    c.phone,
    u.email
FROM Applications a
INNER JOIN Jobs       j ON a.job_id       = j.job_id
INNER JOIN Employers  e ON j.employer_id  = e.employer_id
INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
INNER JOIN Users      u ON c.user_id      = u.user_id
ORDER BY j.job_id ASC, a.match_score DESC;



CREATE VIEW JobMatchSummaryView AS
SELECT
    j.job_id,
    j.job_title,
    j.status            AS job_status,
    j.application_limit,                        -- ← new column
    e.company_name,
    COUNT(a.application_id)                  AS total_applicants,
    ROUND(AVG(a.match_score), 2)             AS avg_match_score,
    MAX(a.match_score)                       AS highest_match_score,
    SUM(a.status = 'shortlisted')            AS shortlisted_count,
    SUM(a.status = 'interview_scheduled')    AS interviews_scheduled,
    SUM(a.status = 'rejected')               AS rejected_count,
    SUM(a.status = 'pending')                AS pending_count
FROM Jobs j
INNER JOIN Employers   e ON j.employer_id = e.employer_id
LEFT  JOIN Applications a ON j.job_id     = a.job_id
GROUP BY
    j.job_id,
    j.job_title,
    j.status,
    j.application_limit,                       
    e.company_name;


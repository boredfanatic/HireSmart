-- =============================================================
--  HireSmart — Advanced SQL Queries
--  Covers: Multi-table JOINs, Subqueries, Correlated Subqueries,
--          Aggregates, GROUP BY + HAVING, Window Functions,
--          LEFT/RIGHT JOINs, Complex WHERE, ORDER BY + LIMIT
-- =============================================================

USE HireSmart;

-- -------------------------------------------------------------
-- Q1: All users with their role
--     Basic lookup — foundation query
-- -------------------------------------------------------------
SELECT
    user_id,
    email,
    user_type,
    created_at
FROM Users
ORDER BY user_type, created_at;


-- -------------------------------------------------------------
-- Q2: Full candidate profiles with all their skills
--     Multi-table INNER JOIN across 4 tables
-- -------------------------------------------------------------
SELECT
    c.candidate_id,
    c.full_name,
    u.email,
    c.phone,
    s.skill_name,
    s.category        AS skill_category,
    cs.proficiency_level
FROM Candidates c
INNER JOIN Users           u  ON c.user_id      = u.user_id
INNER JOIN CandidateSkills cs ON c.candidate_id = cs.candidate_id
INNER JOIN Skills          s  ON cs.skill_id    = s.skill_id
ORDER BY c.candidate_id, cs.proficiency_level DESC;


-- -------------------------------------------------------------
-- Q3: Top 5 candidates for a specific job (job_id = 1)
--     Multi-table JOIN + ORDER BY + LIMIT
-- -------------------------------------------------------------
SELECT
    c.candidate_id,
    c.full_name,
    u.email,
    a.match_score,
    a.status,
    a.applied_at
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
INNER JOIN Users      u ON c.user_id      = u.user_id
WHERE a.job_id = 1
ORDER BY a.match_score DESC
LIMIT 5;


-- -------------------------------------------------------------
-- Q4: Most in-demand skills across all job postings
--     Aggregate + GROUP BY + ORDER BY
-- -------------------------------------------------------------
SELECT
    s.skill_name,
    s.category,
    COUNT(js.job_id)     AS demand_count,
    ROUND(AVG(js.weight), 2) AS avg_importance_weight
FROM Skills s
INNER JOIN JobSkills js ON s.skill_id = js.skill_id
GROUP BY s.skill_id, s.skill_name, s.category
ORDER BY demand_count DESC, avg_importance_weight DESC;


-- -------------------------------------------------------------
-- Q5: Jobs with NO applicants (using LEFT JOIN + NULL check)
--     Demonstrates LEFT JOIN for finding missing relationships
-- -------------------------------------------------------------
SELECT
    j.job_id,
    j.job_title,
    e.company_name,
    j.location,
    j.created_at
FROM Jobs j
INNER JOIN Employers  e ON j.employer_id  = e.employer_id
LEFT  JOIN Applications a ON j.job_id     = a.job_id
WHERE a.application_id IS NULL
  AND j.status = 'open';


-- -------------------------------------------------------------
-- Q6: Candidates who applied to MORE than one job
--     GROUP BY + HAVING (filters after aggregation)
-- -------------------------------------------------------------
SELECT
    c.candidate_id,
    c.full_name,
    u.email,
    COUNT(a.job_id)              AS jobs_applied,
    ROUND(AVG(a.match_score), 2) AS avg_match_score
FROM Candidates c
INNER JOIN Users         u ON c.user_id      = u.user_id
INNER JOIN Applications  a ON c.candidate_id = a.candidate_id
GROUP BY c.candidate_id, c.full_name, u.email
HAVING COUNT(a.job_id) > 1
ORDER BY jobs_applied DESC;


-- -------------------------------------------------------------
-- Q7: Skill gap analysis — skills required by jobs but owned
--     by fewer than 2 candidates (rare/hard-to-fill skills)
--     Nested subquery inside WHERE
-- -------------------------------------------------------------
SELECT
    s.skill_name,
    s.category,
    COUNT(DISTINCT js.job_id)  AS jobs_requiring_it,
    COUNT(DISTINCT cs.candidate_id) AS candidates_with_it
FROM Skills s
INNER JOIN JobSkills js ON s.skill_id = js.skill_id
LEFT  JOIN CandidateSkills cs ON s.skill_id = cs.skill_id
GROUP BY s.skill_id, s.skill_name, s.category
HAVING COUNT(DISTINCT cs.candidate_id) < 2
ORDER BY jobs_requiring_it DESC;


-- -------------------------------------------------------------
-- Q8: Candidates ranked per job using window function
--     RANK() OVER (PARTITION BY) — advanced window function
-- -------------------------------------------------------------
SELECT
    j.job_title,
    e.company_name,
    c.full_name,
    a.match_score,
    a.status,
    RANK() OVER (
        PARTITION BY a.job_id
        ORDER BY a.match_score DESC
    ) AS rank_in_job
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
INNER JOIN Jobs       j ON a.job_id       = j.job_id
INNER JOIN Employers  e ON j.employer_id  = e.employer_id
ORDER BY j.job_id, rank_in_job;


-- -------------------------------------------------------------
-- Q9: Under-qualified applicants (match score below 50%)
--     Complex WHERE condition + multi-table JOIN
-- -------------------------------------------------------------
SELECT
    c.full_name,
    u.email,
    j.job_title,
    e.company_name,
    a.match_score,
    a.status
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
INNER JOIN Users      u ON c.user_id      = u.user_id
INNER JOIN Jobs       j ON a.job_id       = j.job_id
INNER JOIN Employers  e ON j.employer_id  = e.employer_id
WHERE a.match_score < 50
   OR a.match_score IS NULL
ORDER BY a.match_score ASC;


-- -------------------------------------------------------------
-- Q10: Employers with the most active open job postings
--      RIGHT JOIN to include employers even with no jobs
--      GROUP BY + HAVING + ORDER BY
-- -------------------------------------------------------------
SELECT
    e.employer_id,
    e.company_name,
    u.email,
    COUNT(j.job_id)  AS total_jobs_posted,
    SUM(j.status = 'open') AS open_jobs
FROM Jobs j
RIGHT JOIN Employers e ON j.employer_id = e.employer_id
INNER JOIN Users     u ON e.user_id     = u.user_id
GROUP BY e.employer_id, e.company_name, u.email
HAVING open_jobs > 0
ORDER BY open_jobs DESC;


-- -------------------------------------------------------------
-- Q11: Interview conversion rate per company
--      (how many applications led to interviews)
--      Correlated subquery + aggregate
-- -------------------------------------------------------------
SELECT
    e.company_name,
    COUNT(DISTINCT a.application_id)  AS total_applications,
    COUNT(DISTINCT i.interview_id)    AS total_interviews,
    ROUND(
        COUNT(DISTINCT i.interview_id) * 100.0
        / NULLIF(COUNT(DISTINCT a.application_id), 0),
    2)                                AS conversion_rate_pct
FROM Employers e
INNER JOIN Jobs         j ON e.employer_id  = j.employer_id
INNER JOIN Applications a ON j.job_id       = a.job_id
LEFT  JOIN Interviews   i ON a.application_id = i.application_id
GROUP BY e.employer_id, e.company_name
ORDER BY conversion_rate_pct DESC;


-- -------------------------------------------------------------
-- Q12: Candidates whose match score is ABOVE the average
--      match score for that specific job (correlated subquery)
-- -------------------------------------------------------------
SELECT
    c.full_name,
    u.email,
    j.job_title,
    a.match_score,
    ROUND((
        SELECT AVG(a2.match_score)
        FROM   Applications a2
        WHERE  a2.job_id = a.job_id
    ), 2) AS job_avg_score
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
INNER JOIN Users      u ON c.user_id      = u.user_id
INNER JOIN Jobs       j ON a.job_id       = j.job_id
WHERE a.match_score > (
    SELECT AVG(a3.match_score)
    FROM   Applications a3
    WHERE  a3.job_id = a.job_id
)
ORDER BY j.job_id, a.match_score DESC;


-- -------------------------------------------------------------
-- Q13: Most proficient candidates per skill category
--      Aggregate + GROUP BY + subquery for top proficiency
-- -------------------------------------------------------------
SELECT
    s.category,
    s.skill_name,
    c.full_name,
    cs.proficiency_level
FROM CandidateSkills cs
INNER JOIN Skills     s ON cs.skill_id    = s.skill_id
INNER JOIN Candidates c ON cs.candidate_id = c.candidate_id
WHERE cs.proficiency_level = (
    SELECT MAX(cs2.proficiency_level)
    FROM   CandidateSkills cs2
    INNER JOIN Skills s2 ON cs2.skill_id = s2.skill_id
    WHERE  s2.category = s.category
)
ORDER BY s.category;


-- -------------------------------------------------------------
-- Q14: Full application pipeline view
--      All applications with job, company, candidate,
--      match score, status, and interview info
--      Multi-table JOIN across 6 tables
-- -------------------------------------------------------------
SELECT
    a.application_id,
    c.full_name        AS candidate,
    u.email,
    j.job_title,
    e.company_name,
    a.match_score,
    a.status           AS application_status,
    a.applied_at,
    i.interview_date,
    i.interview_mode,
    i.status           AS interview_status
FROM Applications a
INNER JOIN Candidates c ON a.candidate_id   = c.candidate_id
INNER JOIN Users      u ON c.user_id        = u.user_id
INNER JOIN Jobs       j ON a.job_id         = j.job_id
INNER JOIN Employers  e ON j.employer_id    = e.employer_id
LEFT  JOIN Interviews i ON a.application_id = i.application_id
ORDER BY a.applied_at DESC;


-- -------------------------------------------------------------
-- Q15: Jobs nearing their application limit (>= 80% filled)
--      Subquery inside HAVING — useful for employer alerts
-- -------------------------------------------------------------
SELECT
    j.job_id,
    j.job_title,
    e.company_name,
    j.application_limit,
    COUNT(a.application_id)  AS current_applications,
    ROUND(
        COUNT(a.application_id) * 100.0 / j.application_limit,
    1)                       AS fill_pct
FROM Jobs j
INNER JOIN Employers   e ON j.employer_id = e.employer_id
LEFT  JOIN Applications a ON j.job_id     = a.job_id
WHERE j.status = 'open'
GROUP BY j.job_id, j.job_title, e.company_name, j.application_limit
HAVING fill_pct >= 80
ORDER BY fill_pct DESC;
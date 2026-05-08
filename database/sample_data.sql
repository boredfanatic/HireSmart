-- =============================================================
--  HireSmart Sample Data
--  Run AFTER schema.sql, procedures.sql, and triggers.sql
-- =============================================================

USE HireSmart;

-- Clear all tables in reverse FK order so this file is safe to re-run
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Interviews;
TRUNCATE TABLE Applications;
TRUNCATE TABLE JobSkills;
TRUNCATE TABLE CandidateSkills;
TRUNCATE TABLE Jobs;
TRUNCATE TABLE Candidates;
TRUNCATE TABLE Employers;
TRUNCATE TABLE Skills;
TRUNCATE TABLE Users;
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------
-- 1. Skills  (only categories defined in the ENUM are used)
--    ENUM: programming | database | framework | cloud |
--          tools | data | web | soft | engineering | science | education
-- -------------------------------------------------------------
INSERT INTO Skills (skill_name, category) VALUES
-- Programming
('Python',              'programming'),
('Java',                'programming'),
('C++',                 'programming'),
('JavaScript',          'programming'),
('C#',                  'programming'),
('R',                   'programming'),
('Kotlin',              'programming'),
('Swift',               'programming'),

-- Database
('MySQL',               'database'),
('PostgreSQL',          'database'),
('MongoDB',             'database'),
('Oracle',              'database'),
('Redis',               'database'),

-- Framework
('React',               'framework'),
('Angular',             'framework'),
('Django',              'framework'),
('Flask',               'framework'),
('Spring Boot',         'framework'),
('Node.js',             'framework'),
('Vue.js',              'framework'),

-- Cloud / DevOps
('AWS',                 'cloud'),
('Azure',               'cloud'),
('Docker',              'cloud'),
('Kubernetes',          'cloud'),
('Google Cloud',        'cloud'),

-- Tools
('Git',                 'tools'),
('JIRA',                'tools'),
('VS Code',             'tools'),
('Postman',             'tools'),
('Linux',               'tools'),

-- Data / Analytics
('Machine Learning',    'data'),
('Data Analysis',       'data'),
('Tableau',             'data'),
('Power BI',            'data'),
('TensorFlow',          'data'),
('Pandas',              'data'),
('Deep Learning',       'data'),

-- Web / Design
('HTML',                'web'),
('CSS',                 'web'),
('UI/UX',               'web'),
('Figma',               'web'),
('REST API',            'web'),
('GraphQL',             'web'),

-- Soft Skills
('Communication',       'soft'),
('Leadership',          'soft'),
('Teamwork',            'soft'),
('Recruitment',         'soft'),
('Sales',               'soft'),
('Marketing',           'soft'),
('Accounting',          'soft'),
('Project Management',  'soft'),
('Problem Solving',     'soft'),
('Time Management',     'soft'),

-- Engineering
('AutoCAD',             'engineering'),
('SolidWorks',          'engineering'),
('Embedded Systems',    'engineering'),
('Circuit Design',      'engineering'),

-- Education
('Teaching',            'education');


-- -------------------------------------------------------------
-- 2. Users
-- -------------------------------------------------------------
INSERT INTO Users (email, password_hash, user_type) VALUES
('alice@mail.com',   'pass', 'candidate'),
('bob@mail.com',     'pass', 'candidate'),
('charlie@mail.com', 'pass', 'candidate'),
('david@mail.com',   'pass', 'candidate'),
('eva@mail.com',     'pass', 'candidate'),
('frank@mail.com',   'pass', 'candidate'),
('grace@mail.com',   'pass', 'candidate'),
('e1@mail.com',      'pass', 'employer'),
('e2@mail.com',      'pass', 'employer'),
('e3@mail.com',      'pass', 'employer');


-- -------------------------------------------------------------
-- 3. Candidates
-- -------------------------------------------------------------
INSERT INTO Candidates (user_id, full_name, phone, resume_path)
SELECT user_id, 'Alice',   '1111111111', '/data/uploads/alice.pdf'   FROM Users WHERE email = 'alice@mail.com'   UNION ALL
SELECT user_id, 'Bob',     '2222222222', '/data/uploads/bob.pdf'     FROM Users WHERE email = 'bob@mail.com'     UNION ALL
SELECT user_id, 'Charlie', '3333333333', '/data/uploads/charlie.pdf' FROM Users WHERE email = 'charlie@mail.com' UNION ALL
SELECT user_id, 'David',   '4444444444', '/data/uploads/david.pdf'   FROM Users WHERE email = 'david@mail.com'   UNION ALL
SELECT user_id, 'Eva',     '5555555555', '/data/uploads/eva.pdf'     FROM Users WHERE email = 'eva@mail.com'     UNION ALL
SELECT user_id, 'Frank',   '6666666666', '/data/uploads/frank.pdf'   FROM Users WHERE email = 'frank@mail.com'   UNION ALL
SELECT user_id, 'Grace',   '7777777777', '/data/uploads/grace.pdf'   FROM Users WHERE email = 'grace@mail.com';


-- -------------------------------------------------------------
-- 4. Employers
-- -------------------------------------------------------------
INSERT INTO Employers (user_id, company_name, company_description)
SELECT user_id, 'TechCorp', 'Software and cloud solutions company'    FROM Users WHERE email = 'e1@mail.com' UNION ALL
SELECT user_id, 'BuildIt',  'Engineering and infrastructure firm'     FROM Users WHERE email = 'e2@mail.com' UNION ALL
SELECT user_id, 'EduPlus',  'Online education and learning platform'  FROM Users WHERE email = 'e3@mail.com';


-- -------------------------------------------------------------
-- 5. Jobs  (application_limit shown explicitly on a few jobs
--           to demonstrate the configurable feature;
--           others fall back to DEFAULT 50)
-- -------------------------------------------------------------
INSERT INTO Jobs (employer_id, job_title, job_description, location, salary_range, status, application_limit)
VALUES
((SELECT employer_id FROM Employers WHERE company_name = 'TechCorp'),
 'Software Engineer',          'Develop scalable backend systems',      'Mumbai',    '10-15 LPA', 'open', 50),

((SELECT employer_id FROM Employers WHERE company_name = 'TechCorp'),
 'HR Manager',                 'Manage hiring and recruitment',          'Delhi',     '8-12 LPA',  'open', 30),

((SELECT employer_id FROM Employers WHERE company_name = 'TechCorp'),
 'Digital Marketing Executive','Run digital campaigns and SEO',          'Delhi',     '5-9 LPA',   'open', 40),

((SELECT employer_id FROM Employers WHERE company_name = 'BuildIt'),
 'Data Analyst',               'Analyze business datasets',             'Bangalore', '7-12 LPA',  'open', 50),

((SELECT employer_id FROM Employers WHERE company_name = 'BuildIt'),
 'Mechanical Engineer',        'Design and test mechanical systems',     'Pune',      '6-10 LPA',  'open', 25),

((SELECT employer_id FROM Employers WHERE company_name = 'BuildIt'),
 'Embedded Systems Engineer',  'Work on microcontrollers and firmware',  'Bangalore', '10-16 LPA', 'open', 20),

((SELECT employer_id FROM Employers WHERE company_name = 'EduPlus'),
 'Frontend Developer',         'Build responsive UI applications',       'Hyderabad', '9-14 LPA',  'open', 50),

((SELECT employer_id FROM Employers WHERE company_name = 'EduPlus'),
 'UI UX Designer',             'Design intuitive user interfaces',       'Remote',    '8-14 LPA',  'open', 35),

((SELECT employer_id FROM Employers WHERE company_name = 'EduPlus'),
 'Teacher',                    'Teach and mentor students online',       'Pune',      '4-8 LPA',   'open', 60),

((SELECT employer_id FROM Employers WHERE company_name = 'TechCorp'),
 'Full Stack Developer',        'Build end-to-end web applications',     'Mumbai',    '12-18 LPA', 'open', 50);


-- -------------------------------------------------------------
-- 6. CandidateSkills
-- -------------------------------------------------------------
-- Helper: candidate IDs by email
-- Alice=c1, Bob=c2, Charlie=c3, David=c4, Eva=c5, Frank=c6, Grace=c7

INSERT INTO CandidateSkills (candidate_id, skill_id, proficiency_level) VALUES

-- Alice: Python developer
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Python'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='MySQL'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Django'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Git'), 8),

-- Bob: Java + Data
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Java'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Data Analysis'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Tableau'), 6),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='PostgreSQL'), 7),

-- Charlie: Frontend
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='React'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='JavaScript'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='HTML'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='CSS'), 8),

-- David: Engineering
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='AutoCAD'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='SolidWorks'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Embedded Systems'), 6),

-- Eva: Designer
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Figma'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='UI/UX'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='CSS'), 7),

-- Frank: Marketing + Soft skills
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Marketing'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Sales'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Communication'), 9),

-- Grace: Teacher + HR
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Teaching'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Recruitment'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='Communication'), 8);


-- -------------------------------------------------------------
-- 7. JobSkills  (required skills + importance weights per job)
-- -------------------------------------------------------------
INSERT INTO JobSkills (job_id, skill_id, weight) VALUES

-- Software Engineer
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Python'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='MySQL'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Git'), 7),

-- Full Stack Developer
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='JavaScript'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='React'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Node.js'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='MySQL'), 6),

-- HR Manager
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='Recruitment'), 9),
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='Communication'), 8),
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='Leadership'), 7),

-- Data Analyst
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='Data Analysis'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='Tableau'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='Python'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='PostgreSQL'), 6),

-- Frontend Developer
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='React'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='JavaScript'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='HTML'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='CSS'), 7),

-- Mechanical Engineer
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='SolidWorks'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='AutoCAD'), 8),

-- Embedded Systems Engineer
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Embedded Systems'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Circuit Design'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='C++'), 7),

-- UI UX Designer
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='UI/UX'), 9),
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='Figma'), 9),
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='CSS'), 6),

-- Teacher
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT skill_id FROM Skills WHERE skill_name='Teaching'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT skill_id FROM Skills WHERE skill_name='Communication'), 8),

-- Digital Marketing Executive
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='Marketing'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='Sales'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='Communication'), 6);


-- -------------------------------------------------------------
-- 8. Applications
--    DO NOT pass match_score — trg_calc_match_on_apply
--    calculates and fills it automatically on INSERT.
-- -------------------------------------------------------------
INSERT INTO Applications (job_id, candidate_id, status) VALUES

-- Alice → Software Engineer (good match: Python+MySQL+Git)
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'shortlisted'),

-- Alice → Data Analyst (partial match: Python)
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'pending'),

-- Bob → Data Analyst (good match: Data Analysis+Tableau+PostgreSQL)
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 'shortlisted'),

-- Bob → Software Engineer (partial match: Java only)
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 'pending'),

-- Charlie → Frontend Developer (strong match: React+JS+HTML+CSS)
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 'shortlisted'),

-- Charlie → Full Stack Developer (partial: React+JS)
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 'pending'),

-- David → Mechanical Engineer (good: SolidWorks+AutoCAD)
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 'shortlisted'),

-- David → Embedded Systems Engineer (partial: Embedded Systems)
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 'pending'),

-- Eva → UI UX Designer (strong: UI/UX+Figma+CSS)
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 'shortlisted'),

-- Eva → Frontend Developer (partial: CSS)
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 'pending'),

-- Frank → Digital Marketing Executive (strong: Marketing+Sales+Communication)
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 'shortlisted'),

-- Frank → HR Manager (partial: Communication)
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 'pending'),

-- Grace → Teacher (strong: Teaching+Communication)
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 'shortlisted'),

-- Grace → HR Manager (good: Recruitment+Communication)
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 'shortlisted'),

-- Alice → Full Stack Developer (partial: Python+MySQL)
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'rejected');


-- -------------------------------------------------------------
-- 9. Interviews
--    Pre-resolve application_ids into @variables so the INSERT
--    does not read Applications while trg_update_status_on_interview
--    is updating it (avoids MySQL Error 1442).
-- -------------------------------------------------------------
SET @app_alice_se = (
    SELECT a.application_id FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    JOIN Candidates c ON a.candidate_id = c.candidate_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE j.job_title = 'Software Engineer' AND u.email = 'alice@mail.com'
);

SET @app_bob_da = (
    SELECT a.application_id FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    JOIN Candidates c ON a.candidate_id = c.candidate_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE j.job_title = 'Data Analyst' AND u.email = 'bob@mail.com'
);

SET @app_charlie_fd = (
    SELECT a.application_id FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    JOIN Candidates c ON a.candidate_id = c.candidate_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE j.job_title = 'Frontend Developer' AND u.email = 'charlie@mail.com'
);

SET @app_grace_hr = (
    SELECT a.application_id FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    JOIN Candidates c ON a.candidate_id = c.candidate_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE j.job_title = 'HR Manager' AND u.email = 'grace@mail.com'
);

SET @app_eva_ux = (
    SELECT a.application_id FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    JOIN Candidates c ON a.candidate_id = c.candidate_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE j.job_title = 'UI UX Designer' AND u.email = 'eva@mail.com'
);

INSERT INTO Interviews (application_id, round_number, interview_date, interview_mode, status, notes)
VALUES
(@app_alice_se,   1, DATE_ADD(NOW(), INTERVAL 3 DAY), 'online',    'scheduled', 'Technical screening round'),
(@app_bob_da,     1, DATE_ADD(NOW(), INTERVAL 5 DAY), 'online',    'scheduled', 'Case study presentation'),
(@app_charlie_fd, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 'online',    'scheduled', 'UI coding challenge'),
(@app_grace_hr,   1, DATE_ADD(NOW(), INTERVAL 4 DAY), 'in_person', 'scheduled', 'HR behavioural interview'),
(@app_eva_ux,     1, DATE_ADD(NOW(), INTERVAL 6 DAY), 'online',    'scheduled', 'Portfolio review');


SELECT 'HireSmart sample data inserted successfully.' AS result;

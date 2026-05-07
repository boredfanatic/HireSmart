-- =============================================================
--  HireSmart Sample Data
--  Run AFTER schema.sql and triggers.sql
-- =============================================================

USE HireSmart;

-- -------------------------------------------------------------
-- 1. Skills  (only categories defined in the ENUM are used)
--    ENUM: programming | database | framework | cloud |
--          tools | data | web | soft
-- -------------------------------------------------------------
INSERT INTO Skills (skill_name, category) VALUES
-- Programming
('python',              'programming'),
('java',                'programming'),
('c++',                 'programming'),
('javascript',          'programming'),
('c#',                  'programming'),
('r',                   'programming'),
('kotlin',              'programming'),
('swift',               'programming'),

-- Database
('mysql',               'database'),
('postgresql',          'database'),
('mongodb',             'database'),
('oracle',              'database'),
('redis',               'database'),

-- Framework
('react',               'framework'),
('angular',             'framework'),
('django',              'framework'),
('flask',               'framework'),
('spring boot',         'framework'),
('node.js',             'framework'),
('vue.js',              'framework'),

-- Cloud / DevOps
('aws',                 'cloud'),
('azure',               'cloud'),
('docker',              'cloud'),
('kubernetes',          'cloud'),
('gcp',                 'cloud'),

-- Tools
('git',                 'tools'),
('jira',                'tools'),
('vs code',             'tools'),
('postman',             'tools'),
('linux',               'tools'),

-- Data / Analytics
('machine learning',    'data'),
('data analysis',       'data'),
('tableau',             'data'),
('power bi',            'data'),
('tensorflow',          'data'),
('pandas',              'data'),
('deep learning',       'data'),

-- Web / Design
('html',                'web'),
('css',                 'web'),
('ui ux',               'web'),
('figma',               'web'),
('rest api',            'web'),
('graphql',             'web'),

-- Soft Skills
-- (autocad, solidworks, embedded systems, biology, teaching, etc.
--  are mapped to the closest ENUM category or kept as soft skills
--  since the schema has no engineering/science/education category)
('communication',       'soft'),
('leadership',          'soft'),
('teamwork',            'soft'),
('recruitment',         'soft'),
('sales',               'soft'),
('marketing',           'soft'),
('accounting',          'soft'),
('project management',  'soft'),
('problem solving',     'soft'),
('time management',     'soft'),
('teaching',            'soft'),
('autocad',             'tools'),
('solidworks',          'tools'),
('embedded systems',    'tools'),
('circuit design',      'tools');


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
 (SELECT skill_id FROM Skills WHERE skill_name='python'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='mysql'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='django'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='git'), 8),

-- Bob: Java + Data
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='java'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='data analysis'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='tableau'), 6),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='postgresql'), 7),

-- Charlie: Frontend
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='react'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='javascript'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='html'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='css'), 8),

-- David: Engineering
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='autocad'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='solidworks'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='embedded systems'), 6),

-- Eva: Designer
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='figma'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='ui ux'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='css'), 7),

-- Frank: Marketing + Soft skills
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='marketing'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='sales'), 7),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='communication'), 9),

-- Grace: Teacher + HR
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='teaching'), 9),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='recruitment'), 8),
((SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='communication'), 8);


-- -------------------------------------------------------------
-- 7. JobSkills  (required skills + importance weights per job)
-- -------------------------------------------------------------
INSERT INTO JobSkills (job_id, skill_id, weight) VALUES

-- Software Engineer
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='python'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='mysql'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='git'), 7),

-- Full Stack Developer
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='javascript'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='react'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='node.js'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='mysql'), 6),

-- HR Manager
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='recruitment'), 9),
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='communication'), 8),
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT skill_id FROM Skills WHERE skill_name='leadership'), 7),

-- Data Analyst
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='data analysis'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='tableau'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='python'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT skill_id FROM Skills WHERE skill_name='postgresql'), 6),

-- Frontend Developer
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='react'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='javascript'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='html'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT skill_id FROM Skills WHERE skill_name='css'), 7),

-- Mechanical Engineer
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='solidworks'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='autocad'), 8),

-- Embedded Systems Engineer
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='embedded systems'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='circuit design'), 8),
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT skill_id FROM Skills WHERE skill_name='c++'), 7),

-- UI UX Designer
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='ui ux'), 9),
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='figma'), 9),
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT skill_id FROM Skills WHERE skill_name='css'), 6),

-- Teacher
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT skill_id FROM Skills WHERE skill_name='teaching'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT skill_id FROM Skills WHERE skill_name='communication'), 8),

-- Digital Marketing Executive
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='marketing'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='sales'), 7),
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT skill_id FROM Skills WHERE skill_name='communication'), 6);


-- -------------------------------------------------------------
-- 8. Applications
--    DO NOT pass match_score — trg_calc_match_on_apply
--    calculates and fills it automatically on INSERT.
-- -------------------------------------------------------------
INSERT INTO Applications (job_id, candidate_id, status) VALUES

-- Alice → Software Engineer (good match: python+mysql+git)
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'shortlisted'),

-- Alice → Data Analyst (partial match: python)
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'pending'),

-- Bob → Data Analyst (good match: data analysis+tableau+postgresql)
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 'shortlisted'),

-- Bob → Software Engineer (partial match: java only)
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='bob@mail.com'),
 'pending'),

-- Charlie → Frontend Developer (strong match: react+js+html+css)
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 'shortlisted'),

-- Charlie → Full Stack Developer (partial: react+js)
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='charlie@mail.com'),
 'pending'),

-- David → Mechanical Engineer (good: solidworks+autocad)
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 'shortlisted'),

-- David → Embedded Systems Engineer (partial: embedded systems)
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='david@mail.com'),
 'pending'),

-- Eva → UI UX Designer (strong: ui ux+figma+css)
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 'shortlisted'),

-- Eva → Frontend Developer (partial: css)
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='eva@mail.com'),
 'pending'),

-- Frank → Digital Marketing Executive (strong: marketing+sales+communication)
((SELECT job_id FROM Jobs WHERE job_title='Digital Marketing Executive'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 'shortlisted'),

-- Frank → HR Manager (partial: communication)
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='frank@mail.com'),
 'pending'),

-- Grace → Teacher (strong: teaching+communication)
((SELECT job_id FROM Jobs WHERE job_title='Teacher'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 'shortlisted'),

-- Grace → HR Manager (good: recruitment+communication)
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='grace@mail.com'),
 'shortlisted'),

-- Alice → Full Stack Developer (partial: python+mysql)
((SELECT job_id FROM Jobs WHERE job_title='Full Stack Developer'),
 (SELECT c.candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='alice@mail.com'),
 'rejected');


-- -------------------------------------------------------------
-- 9. Interviews
--    Reference application_id by job+candidate to avoid
--    fragile LIMIT 1 lookups.
-- -------------------------------------------------------------
INSERT INTO Interviews (application_id, round_number, interview_date, interview_mode, status, notes)
VALUES

-- Alice / Software Engineer — Round 1
((SELECT a.application_id FROM Applications a
  JOIN Jobs j ON a.job_id = j.job_id
  JOIN Candidates c ON a.candidate_id = c.candidate_id
  JOIN Users u ON c.user_id = u.user_id
  WHERE j.job_title = 'Software Engineer' AND u.email = 'alice@mail.com'),
 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 'online', 'scheduled', 'Technical screening round'),

-- Bob / Data Analyst — Round 1
((SELECT a.application_id FROM Applications a
  JOIN Jobs j ON a.job_id = j.job_id
  JOIN Candidates c ON a.candidate_id = c.candidate_id
  JOIN Users u ON c.user_id = u.user_id
  WHERE j.job_title = 'Data Analyst' AND u.email = 'bob@mail.com'),
 1, DATE_ADD(NOW(), INTERVAL 5 DAY), 'online', 'scheduled', 'Case study presentation'),

-- Charlie / Frontend Developer — Round 1
((SELECT a.application_id FROM Applications a
  JOIN Jobs j ON a.job_id = j.job_id
  JOIN Candidates c ON a.candidate_id = c.candidate_id
  JOIN Users u ON c.user_id = u.user_id
  WHERE j.job_title = 'Frontend Developer' AND u.email = 'charlie@mail.com'),
 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 'online', 'scheduled', 'UI coding challenge'),

-- Grace / HR Manager — Round 1
((SELECT a.application_id FROM Applications a
  JOIN Jobs j ON a.job_id = j.job_id
  JOIN Candidates c ON a.candidate_id = c.candidate_id
  JOIN Users u ON c.user_id = u.user_id
  WHERE j.job_title = 'HR Manager' AND u.email = 'grace@mail.com'),
 1, DATE_ADD(NOW(), INTERVAL 4 DAY), 'in_person', 'scheduled', 'HR behavioural interview'),

-- Eva / UI UX Designer — Round 1
((SELECT a.application_id FROM Applications a
  JOIN Jobs j ON a.job_id = j.job_id
  JOIN Candidates c ON a.candidate_id = c.candidate_id
  JOIN Users u ON c.user_id = u.user_id
  WHERE j.job_title = 'UI UX Designer' AND u.email = 'eva@mail.com'),
 1, DATE_ADD(NOW(), INTERVAL 6 DAY), 'online', 'scheduled', 'Portfolio review');


SELECT 'HireSmart sample data inserted successfully.' AS result;
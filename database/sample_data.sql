USE hiresmart;

INSERT INTO Skills (skill_name, category) VALUES
('python','programming'),
('java','programming'),
('c++','programming'),
('javascript','programming'),
('c#','programming'),
('mysql','database'),
('postgresql','database'),
('mongodb','database'),
('react','framework'),
('angular','framework'),
('django','framework'),
('flask','framework'),
('aws','cloud'),
('docker','tools'),
('git','tools'),
('machine learning','data'),
('data analysis','data'),
('tableau','data'),
('power bi','data'),
('html','web'),
('css','web'),
('ui ux','web'),
('figma','web'),
('communication','soft'),
('leadership','soft'),
('teamwork','soft'),
('recruitment','soft'),
('sales','soft'),
('marketing','soft'),
('accounting','soft'),
('project management','soft'),
('autocad','engineering'),
('solidworks','engineering'),
('embedded systems','engineering'),
('circuit design','engineering'),
('thermodynamics','engineering'),
('biology','science'),
('chemistry','science'),
('teaching','education');

INSERT INTO Users (email, password_hash, user_type) VALUES
('c1@mail.com','pass','candidate'),
('c2@mail.com','pass','candidate'),
('c3@mail.com','pass','candidate'),
('c4@mail.com','pass','candidate'),
('c5@mail.com','pass','candidate'),
('e1@mail.com','pass','employer'),
('e2@mail.com','pass','employer'),
('e3@mail.com','pass','employer');

INSERT INTO Candidates (user_id, full_name, phone, resume_path)
SELECT user_id, 'Alice','1111111111','/data/uploads/resume.pdf' FROM Users WHERE email='c1@mail.com'
UNION ALL
SELECT user_id, 'Bob','2222222222','/data/uploads/resume.pdf' FROM Users WHERE email='c2@mail.com'
UNION ALL
SELECT user_id, 'Charlie','3333333333','/data/uploads/resume.pdf' FROM Users WHERE email='c3@mail.com'
UNION ALL
SELECT user_id, 'David','4444444444','/data/uploads/resume.pdf' FROM Users WHERE email='c4@mail.com'
UNION ALL
SELECT user_id, 'Eva','5555555555','/data/uploads/resume.pdf' FROM Users WHERE email='c5@mail.com';

INSERT INTO Employers (user_id, company_name, company_description)
SELECT user_id, 'TechCorp','Software company' FROM Users WHERE email='e1@mail.com'
UNION ALL
SELECT user_id, 'BuildIt','Engineering firm' FROM Users WHERE email='e2@mail.com'
UNION ALL
SELECT user_id, 'EduPlus','Education platform' FROM Users WHERE email='e3@mail.com';

INSERT INTO Jobs (employer_id, job_title, job_description, location, salary_range, status)
VALUES
((SELECT employer_id FROM Employers WHERE company_name='TechCorp'), 'Software Engineer','Develop scalable systems','Mumbai','10-15 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='TechCorp'), 'HR Manager','Manage recruitment','Delhi','8-12 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='BuildIt'), 'Data Analyst','Analyze datasets','Bangalore','7-12 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='BuildIt'), 'Mechanical Engineer','Design mechanical systems','Pune','6-10 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='EduPlus'), 'Frontend Developer','Build UI applications','Hyderabad','9-14 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='EduPlus'), 'Teacher','Teach students','Pune','4-8 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='TechCorp'), 'Digital Marketing Executive','Run campaigns','Delhi','5-9 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='BuildIt'), 'Embedded Systems Engineer','Work on hardware systems','Bangalore','10-16 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='EduPlus'), 'UI UX Designer','Design interfaces','Remote','8-14 LPA','open'),
((SELECT employer_id FROM Employers WHERE company_name='TechCorp'), 'Civil Engineer','Construction planning','Chennai','6-11 LPA','open');

INSERT INTO CandidateSkills (candidate_id, skill_id, proficiency_level)
VALUES
((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c1@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='python'), 8),

((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c1@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='mysql'), 7),

((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c2@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='java'), 7),

((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c3@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='react'), 8),

((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c4@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='autocad'), 8),

((SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c5@mail.com'),
 (SELECT skill_id FROM Skills WHERE skill_name='figma'), 7);

INSERT INTO JobSkills (job_id, skill_id, weight)
VALUES
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'), (SELECT skill_id FROM Skills WHERE skill_name='python'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Software Engineer'), (SELECT skill_id FROM Skills WHERE skill_name='mysql'), 8),
((SELECT job_id FROM Jobs WHERE job_title='HR Manager'), (SELECT skill_id FROM Skills WHERE skill_name='recruitment'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Data Analyst'), (SELECT skill_id FROM Skills WHERE skill_name='data analysis'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'), (SELECT skill_id FROM Skills WHERE skill_name='react'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Mechanical Engineer'), (SELECT skill_id FROM Skills WHERE skill_name='solidworks'), 9),
((SELECT job_id FROM Jobs WHERE job_title='UI UX Designer'), (SELECT skill_id FROM Skills WHERE skill_name='ui ux'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Embedded Systems Engineer'), (SELECT skill_id FROM Skills WHERE skill_name='embedded systems'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Civil Engineer'), (SELECT skill_id FROM Skills WHERE skill_name='autocad'), 9),
((SELECT job_id FROM Jobs WHERE job_title='Teacher'), (SELECT skill_id FROM Skills WHERE skill_name='teaching'), 9);

INSERT INTO Applications (job_id, candidate_id, match_score, status)
VALUES
(
 (SELECT job_id FROM Jobs WHERE job_title='Software Engineer'),
 (SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c1@mail.com'),
 85,'pending'
),
(
 (SELECT job_id FROM Jobs WHERE job_title='Data Analyst'),
 (SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c2@mail.com'),
 88,'pending'
),
(
 (SELECT job_id FROM Jobs WHERE job_title='Frontend Developer'),
 (SELECT candidate_id FROM Candidates c JOIN Users u ON c.user_id=u.user_id WHERE u.email='c3@mail.com'),
 90,'pending'
);

INSERT INTO Interviews (application_id, round_number, interview_date, interview_mode, status, notes)
VALUES
((SELECT application_id FROM Applications LIMIT 1),
1,NOW(),'online','scheduled','First round');
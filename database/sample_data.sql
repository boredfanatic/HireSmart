USE hiresmart;

INSERT INTO Skills (skill_name, category) VALUES
('python','programming'),
('java','programming'),
('c++','programming'),
('javascript','programming'),
('c#','programming'),
('go','programming'),
('ruby','programming'),
('php','programming'),
('swift','programming'),
('kotlin','programming'),
('mysql','database'),
('postgresql','database'),
('mongodb','database'),
('oracle','database'),
('sql server','database'),
('firebase','database'),
('redis','database'),
('react','framework'),
('angular','framework'),
('vue','framework'),
('django','framework'),
('flask','framework'),
('spring','framework'),
('node.js','framework'),
('express','framework'),
('laravel','framework'),
('bootstrap','framework'),
('tailwind','framework'),
('aws','cloud'),
('azure','cloud'),
('google cloud','cloud'),
('docker','tools'),
('kubernetes','tools'),
('git','tools'),
('jira','tools'),
('linux','tools'),
('machine learning','data'),
('deep learning','data'),
('data analysis','data'),
('pandas','data'),
('numpy','data'),
('tensorflow','data'),
('statistics','data'),
('r','data'),
('tableau','data'),
('power bi','data'),
('html','web'),
('css','web'),
('rest api','web'),
('ui ux','web'),
('figma','web'),
('wireframing','web'),
('communication','soft'),
('leadership','soft'),
('problem solving','soft'),
('teamwork','soft'),
('time management','soft'),
('public speaking','soft'),
('negotiation','soft'),
('recruitment','soft'),
('training','soft'),
('payroll','soft'),
('sales','soft'),
('marketing','soft'),
('customer service','soft');

INSERT INTO Users (email, password_hash, user_type) VALUES
('c1@mail.com','pass','candidate'),
('c2@mail.com','pass','candidate'),
('c3@mail.com','pass','candidate'),
('c4@mail.com','pass','candidate'),
('c5@mail.com','pass','candidate'),
('e1@mail.com','pass','employer'),
('e2@mail.com','pass','employer'),
('e3@mail.com','pass','employer');

INSERT INTO Candidates (user_id, full_name, phone, resume_path) VALUES
(1,'Alice','1111111111','/data/uploads/a.pdf'),
(2,'Bob','2222222222','/data/uploads/b.pdf'),
(3,'Charlie','3333333333','/data/uploads/c.pdf'),
(4,'David','4444444444','/data/uploads/d.pdf'),
(5,'Eva','5555555555','/data/uploads/e.pdf');

INSERT INTO Employers (user_id, company_name, company_description) VALUES
(6,'TechCorp','Software company'),
(7,'DataWorks','Analytics company'),
(8,'BuildIt','Engineering firm');

INSERT INTO Jobs (employer_id, job_title, job_description, location, salary_range, status) VALUES
(1,'Software Engineer','Develop applications','Mumbai','10-15 LPA','open'),
(2,'Data Analyst','Analyze datasets','Delhi','8-12 LPA','open'),
(3,'Frontend Developer','Build UI','Bangalore','9-14 LPA','open');

INSERT INTO CandidateSkills (candidate_id, skill_id, proficiency_level) VALUES
(1,1,8),(1,11,7),(1,29,6),
(2,2,7),(2,12,6),(2,37,8),
(3,3,6),(3,37,7),(3,43,8),
(4,4,7),(4,22,6),(4,53,9),
(5,5,6),(5,54,8),(5,55,7);

INSERT INTO JobSkills (job_id, skill_id, weight) VALUES
(1,1,9),(1,18,8),(1,29,7),
(2,37,9),(2,45,8),(2,46,7),
(3,4,9),(3,27,8),(3,47,7);

INSERT INTO Applications (job_id, candidate_id, match_score, status) VALUES
(1,1,85,'pending'),
(1,2,70,'pending'),
(2,2,88,'pending'),
(2,3,75,'pending'),
(3,3,90,'pending'),
(3,4,65,'pending');

INSERT INTO Interviews (application_id, round_number, interview_date, interview_mode, status, notes) VALUES
(1,1,NOW(),'online','scheduled','First round'),
(3,1,NOW(),'online','scheduled','First round'),
(5,1,NOW(),'in_person','scheduled','Technical round');
USE HireSmart;

DELIMITER $$

CREATE FUNCTION CalculateMatchScore(
    p_candidate_id INT,
    p_job_id INT
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_weight DECIMAL(10,2) DEFAULT 0;
    DECLARE v_earned_points DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(js.weight),0)
    INTO v_total_weight
    FROM JobSkills js
    WHERE js.job_id = p_job_id;

    IF v_total_weight = 0 THEN
        RETURN 0.00;
    END IF;

    SELECT COALESCE(SUM((cs.proficiency_level/10.0)*js.weight),0)
    INTO v_earned_points
    FROM JobSkills js
    INNER JOIN CandidateSkills cs
        ON cs.skill_id = js.skill_id
       AND cs.candidate_id = p_candidate_id
    WHERE js.job_id = p_job_id;

    RETURN ROUND((v_earned_points/v_total_weight)*100,2);
END$$


CREATE PROCEDURE ApplyForJob(
    IN p_job_id INT,
    IN p_candidate_id INT
)
BEGIN
    DECLARE v_match_score DECIMAL(5,2);
    DECLARE v_job_status VARCHAR(20);

    IF NOT EXISTS (SELECT 1 FROM Jobs WHERE job_id = p_job_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid job_id';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Candidates WHERE candidate_id = p_candidate_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid candidate_id';
    END IF;

    SELECT status INTO v_job_status
    FROM Jobs
    WHERE job_id = p_job_id;

    IF v_job_status <> 'open' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job is closed';
    END IF;

    SET v_match_score = CalculateMatchScore(p_candidate_id,p_job_id);

    START TRANSACTION;

    INSERT INTO Applications(job_id,candidate_id,match_score,status)
    VALUES(p_job_id,p_candidate_id,v_match_score,'pending');

    COMMIT;
END$$


CREATE PROCEDURE ScheduleInterview(
    IN p_application_id INT,
    IN p_round_number INT,
    IN p_interview_date DATETIME,
    IN p_interview_mode VARCHAR(20),
    IN p_notes TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Applications WHERE application_id = p_application_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Invalid application_id';
    END IF;

    IF EXISTS (
        SELECT 1 FROM Interviews WHERE application_id = p_application_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Interview already scheduled for this application';
    END IF;

    START TRANSACTION;

    INSERT INTO Interviews(application_id,round_number,interview_date,interview_mode,status,notes)
    VALUES(p_application_id,p_round_number,p_interview_date,p_interview_mode,'scheduled',p_notes);

    UPDATE Applications
    SET status='interview_scheduled'
    WHERE application_id=p_application_id;

    COMMIT;
END$$


CREATE PROCEDURE CloseJobIfLimitReached(
    IN p_job_id INT
)
BEGIN
    DECLARE v_total INT;
    DECLARE v_limit INT;

    SELECT COUNT(*) INTO v_total
    FROM Applications
    WHERE job_id=p_job_id;

    SELECT application_limit INTO v_limit
    FROM Jobs
    WHERE job_id=p_job_id;

    IF v_total >= v_limit THEN
        UPDATE Jobs
        SET status='closed'
        WHERE job_id=p_job_id;
    END IF;
END$$


CREATE PROCEDURE GetTopCandidatesForJob(
    IN p_job_id INT
)
BEGIN
    SELECT c.candidate_id,c.full_name,u.email,a.match_score,a.status
    FROM Applications a
    INNER JOIN Candidates c ON a.candidate_id=c.candidate_id
    INNER JOIN Users u ON c.user_id=u.user_id
    WHERE a.job_id=p_job_id
    ORDER BY a.match_score DESC;
END$$


CREATE PROCEDURE UpdateApplicationStatus(
    IN p_application_id INT,
    IN p_new_status VARCHAR(30)
)
BEGIN
    UPDATE Applications
    SET status=p_new_status
    WHERE application_id=p_application_id;
END$$


CREATE PROCEDURE GetJobStats(
    IN p_job_id INT
)
BEGIN
    SELECT j.job_id,j.job_title,
    COUNT(a.application_id) AS total_applicants,
    ROUND(AVG(a.match_score),2) AS avg_score,
    MAX(a.match_score) AS highest_score,
    SUM(a.status='shortlisted') AS shortlisted,
    SUM(a.status='rejected') AS rejected
    FROM Jobs j
    LEFT JOIN Applications a ON j.job_id=a.job_id
    WHERE j.job_id=p_job_id
    GROUP BY j.job_id,j.job_title;
END$$

DELIMITER ;
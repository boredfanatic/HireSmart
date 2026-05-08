-- =============================================================
-- FUNCTION: CalculateMatchScore
--   Input : p_candidate_id, p_job_id
--   Output: DECIMAL(5,2) weighted match percentage (0–100)
--
--   Logic:
--     For every skill the job requires (weight 1–10),
--     check if the candidate has that skill.
--     Earned = SUM(proficiency/10 * weight) for matched skills
--     Score  = (earned / total_weight) * 100
-- =============================================================
DELIMITER $$

CREATE FUNCTION CalculateMatchScore(
    p_candidate_id INT,
    p_job_id       INT
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_weight  DECIMAL(10,2) DEFAULT 0;
    DECLARE v_earned_points DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(js.weight), 0)
    INTO   v_total_weight
    FROM   JobSkills js
    WHERE  js.job_id = p_job_id;

    -- Avoid division by zero if job has no skills defined
    IF v_total_weight = 0 THEN
        RETURN 0.00;
    END IF;

    SELECT COALESCE(SUM((cs.proficiency_level / 10.0) * js.weight), 0)
    INTO   v_earned_points
    FROM   JobSkills js
    INNER JOIN CandidateSkills cs
           ON  cs.skill_id     = js.skill_id
           AND cs.candidate_id = p_candidate_id
    WHERE  js.job_id = p_job_id;

    RETURN ROUND((v_earned_points / v_total_weight) * 100, 2);
END$$
DELIMITER ;


-- =============================================================
-- PROCEDURE: ApplyForJob
--   Input : p_job_id, p_candidate_id
--   Action: Validates job + candidate, checks job is open,
--           then inserts application.
--
--   NOTE: match_score is NOT set here manually.
--         trg_calc_match_on_apply fires AFTER INSERT and
--         fills match_score automatically.
--         trg_auto_close_job also fires AFTER INSERT and
--         closes the job if application_limit is reached.
--         trg_prevent_duplicate_application fires BEFORE
--         INSERT and blocks duplicate applications.
-- =============================================================
DELIMITER $$

CREATE PROCEDURE ApplyForJob(
    IN p_job_id       INT,
    IN p_candidate_id INT
)
BEGIN
    DECLARE v_job_status VARCHAR(20);

    -- Validate job exists
    IF NOT EXISTS (SELECT 1 FROM Jobs WHERE job_id = p_job_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid job_id: job does not exist.';
    END IF;

    -- Validate candidate exists
    IF NOT EXISTS (SELECT 1 FROM Candidates WHERE candidate_id = p_candidate_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid candidate_id: candidate does not exist.';
    END IF;

    -- Check job is still open
    SELECT status INTO v_job_status
    FROM   Jobs
    WHERE  job_id = p_job_id;

    IF v_job_status <> 'open' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This job is no longer accepting applications.';
    END IF;

    -- Insert application — triggers handle match_score,
    -- duplicate check, and auto-close automatically
    START TRANSACTION;

        INSERT INTO Applications (job_id, candidate_id, status)
        VALUES (p_job_id, p_candidate_id, 'pending');

    COMMIT;
END$$
DELIMITER ;


-- =============================================================
-- PROCEDURE: ScheduleInterview
--   Input : p_application_id, p_round_number, p_interview_date,
--           p_interview_mode, p_notes
--   Action: Schedules an interview round for an application.
--           Blocks duplicate rounds (same application + round).
--           Allows multiple rounds per application.
--
--   NOTE: trg_update_status_on_interview fires AFTER INSERT
--         to Interviews and updates Application status to
--         'interview_scheduled' automatically — no manual
--         UPDATE needed here.
-- =============================================================
DELIMITER $$

CREATE PROCEDURE ScheduleInterview(
    IN p_application_id  INT,
    IN p_round_number    INT,
    IN p_interview_date  DATETIME,
    IN p_interview_mode  VARCHAR(20),
    IN p_notes           TEXT
)
BEGIN
    -- Validate application exists
    IF NOT EXISTS (
        SELECT 1 FROM Applications
        WHERE  application_id = p_application_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid application_id: application does not exist.';
    END IF;

    -- Block duplicate round (same application + same round number)
    -- Multiple rounds for the same application are allowed
    IF EXISTS (
        SELECT 1 FROM Interviews
        WHERE  application_id = p_application_id
          AND  round_number   = p_round_number
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This interview round is already scheduled for this application.';
    END IF;

    -- Insert interview — trg_update_status_on_interview
    -- updates Application status automatically
    START TRANSACTION;

        INSERT INTO Interviews (
            application_id,
            round_number,
            interview_date,
            interview_mode,
            status,
            notes
        )
        VALUES (
            p_application_id,
            p_round_number,
            p_interview_date,
            p_interview_mode,
            'scheduled',
            p_notes
        );

    COMMIT;
END$$
DELIMITER ;


-- =============================================================
-- PROCEDURE: GetTopCandidatesForJob
--   Input : p_job_id
--   Output: All candidates who applied, sorted by match_score DESC
--   Use   : Employer dashboard — ranked applicant list
-- =============================================================
DELIMITER $$

CREATE PROCEDURE GetTopCandidatesForJob(
    IN p_job_id INT
)
BEGIN
    SELECT
        c.candidate_id,
        c.full_name,
        c.phone,
        u.email,
        a.application_id,
        a.match_score,
        a.status,
        a.applied_at
    FROM   Applications a
    INNER JOIN Candidates c ON a.candidate_id = c.candidate_id
    INNER JOIN Users      u ON c.user_id      = u.user_id
    WHERE  a.job_id = p_job_id
    ORDER  BY a.match_score DESC;
END$$

DELIMITER ;

-- =============================================================
-- PROCEDURE: UpdateApplicationStatus
--   Input : p_application_id, p_new_status
--   Action: Manually update an application's status.
--   Use   : Employer shortlisting or rejecting candidates.
--
--   Valid statuses: pending | shortlisted | rejected |
--                   interview_scheduled
-- =============================================================
DELIMITER $$

CREATE PROCEDURE UpdateApplicationStatus(
    IN p_application_id INT,
    IN p_new_status     VARCHAR(30)
)
BEGIN
    -- Validate application exists
    IF NOT EXISTS (
        SELECT 1 FROM Applications
        WHERE  application_id = p_application_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid application_id: application does not exist.';
    END IF;

    -- Validate status value
    IF p_new_status NOT IN ('pending', 'shortlisted', 'rejected', 'interview_scheduled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid status. Use: pending, shortlisted, rejected, or interview_scheduled.';
    END IF;

    UPDATE Applications
    SET    status = p_new_status
    WHERE  application_id = p_application_id;
END$$
DELIMITER ;


-- =============================================================
-- PROCEDURE: GetJobStats
--   Input : p_job_id
--   Output: Summary statistics for a specific job posting
--   Use   : Employer dashboard — hiring pipeline overview
-- =============================================================
DELIMITER $$

CREATE PROCEDURE GetJobStats(
    IN p_job_id INT
)
BEGIN
    SELECT
        j.job_id,
        j.job_title,
        j.status             AS job_status,
        j.application_limit,
        COUNT(a.application_id)               AS total_applicants,
        ROUND(AVG(a.match_score), 2)          AS avg_score,
        MAX(a.match_score)                    AS highest_score,
        MIN(a.match_score)                    AS lowest_score,
        SUM(a.status = 'shortlisted')         AS shortlisted,
        SUM(a.status = 'interview_scheduled') AS interviews_scheduled,
        SUM(a.status = 'rejected')            AS rejected,
        SUM(a.status = 'pending')             AS pending
    FROM  Jobs j
    LEFT JOIN Applications a ON j.job_id = a.job_id
    WHERE j.job_id = p_job_id
    GROUP BY
        j.job_id,
        j.job_title,
        j.status,
        j.application_limit;
END$$

DELIMITER ;

-- =============================================================
-- PROCEDURE: CloseJobIfLimitReached
--   Input : p_job_id
--   Action: Manually trigger job closure check.
--           (trg_auto_close_job handles this automatically
--            on every application INSERT — this procedure
--            exists for manual/admin use only.)
-- =============================================================
DELIMITER $$

CREATE PROCEDURE CloseJobIfLimitReached(
    IN p_job_id INT
)
BEGIN
    DECLARE v_total INT;
    DECLARE v_limit INT;
    DECLARE v_status VARCHAR(10);

    SELECT COUNT(*), j.application_limit, j.status
    INTO   v_total, v_limit, v_status
    FROM   Jobs j
    LEFT JOIN Applications a ON j.job_id = a.job_id
    WHERE  j.job_id = p_job_id
    GROUP  BY j.job_id;

    IF v_status = 'open' AND v_total >= v_limit THEN
        UPDATE Jobs
        SET    status = 'closed'
        WHERE  job_id = p_job_id;

        SELECT CONCAT('Job ', p_job_id, ' closed. Applications: ', v_total, '/', v_limit) AS result;
    ELSE
        SELECT CONCAT('Job ', p_job_id, ' remains open. Applications: ', v_total, '/', v_limit) AS result;
    END IF;
END$$


DELIMITER ;
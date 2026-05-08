-- =============================================================
-- TRIGGER 1: trg_calc_match_on_apply
--   Fires  : AFTER INSERT on Applications
--   Action : Calculates match score using CalculateMatchScore()
--            and writes it back into the new row.
-- =============================================================
DELIMITER $$

CREATE TRIGGER trg_calc_match_on_apply
AFTER INSERT ON Applications
FOR EACH ROW
BEGIN
    UPDATE Applications
    SET    match_score = CalculateMatchScore(NEW.candidate_id, NEW.job_id)
    WHERE  application_id = NEW.application_id;
END$$

DELIMITER ;

-- =============================================================
-- TRIGGER 2: trg_update_status_on_interview
--   Fires  : AFTER INSERT on Interviews
--   Action : Sets the linked Application status to
--            'interview_scheduled' automatically.
-- =============================================================
DELIMITER $$

CREATE TRIGGER trg_update_status_on_interview
AFTER INSERT ON Interviews
FOR EACH ROW
BEGIN
    UPDATE Applications
    SET    status = 'interview_scheduled'
    WHERE  application_id = NEW.application_id;
END$$
DELIMITER ;


-- =============================================================
-- TRIGGER 3: trg_prevent_duplicate_application
--   Fires  : BEFORE INSERT on Applications
--   Action : Raises a user-friendly error if the candidate
--            has already applied to the same job.
--            (The UNIQUE KEY handles correctness; this trigger
--             makes the error readable for the frontend.)
-- =============================================================
DELIMITER $$

CREATE TRIGGER trg_prevent_duplicate_application
BEFORE INSERT ON Applications
FOR EACH ROW
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*)
    INTO   v_exists
    FROM   Applications
    WHERE  job_id       = NEW.job_id
      AND  candidate_id = NEW.candidate_id;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have already applied to this job.';
    END IF;
END$$

DELIMITER ;

-- =============================================================
-- TRIGGER 4: trg_auto_close_job
--   Fires  : AFTER INSERT on Applications
--   Action : Counts total applications for the job.
--            If the count reaches or exceeds the job's
--            application_limit, the job status is set to
--            'closed' automatically.
--
--   Note   : application_limit defaults to 50 but the employer
--            can update it at any time via the backend.
-- =============================================================
DELIMITER $$
CREATE TRIGGER trg_auto_close_job
AFTER INSERT ON Applications
FOR EACH ROW
BEGIN
    DECLARE v_app_count INT     DEFAULT 0;
    DECLARE v_app_limit INT     DEFAULT 50;
    DECLARE v_job_status VARCHAR(10);

    -- Only proceed if the job is still open
    SELECT status, application_limit
    INTO   v_job_status, v_app_limit
    FROM   Jobs
    WHERE  job_id = NEW.job_id;

    IF v_job_status = 'open' THEN

        SELECT COUNT(*)
        INTO   v_app_count
        FROM   Applications
        WHERE  job_id = NEW.job_id;

        IF v_app_count >= v_app_limit THEN
            UPDATE Jobs
            SET    status = 'closed'
            WHERE  job_id = NEW.job_id;
        END IF;

    END IF;
END$$


DELIMITER ;
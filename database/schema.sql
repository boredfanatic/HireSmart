create database HireSmart;
use HireSmart;
CREATE TABLE Users (
    user_id       INT            NOT NULL AUTO_INCREMENT,
    email         VARCHAR(255)   NOT NULL,
    password_hash VARCHAR(255)   NOT NULL,
    user_type     ENUM('candidate', 'employer') NOT NULL,
    created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                 ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE  KEY uq_users_email (email),
    INDEX   idx_users_type    (user_type)
);

CREATE TABLE Candidates (
    candidate_id INT          NOT NULL AUTO_INCREMENT,
    user_id      INT          NOT NULL,
    full_name    VARCHAR(255) NOT NULL,
    phone        VARCHAR(20)           DEFAULT NULL,
    resume_path  VARCHAR(500)          DEFAULT NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (candidate_id),
    UNIQUE  KEY uq_candidates_user (user_id),
    INDEX   idx_candidates_name    (full_name),

    CONSTRAINT fk_candidates_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Employers (
    employer_id         INT          NOT NULL AUTO_INCREMENT,
    user_id             INT          NOT NULL,
    company_name        VARCHAR(255) NOT NULL,
    company_description TEXT                  DEFAULT NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (employer_id),
    UNIQUE  KEY uq_employers_user    (user_id),
    INDEX   idx_employers_company    (company_name),

    CONSTRAINT fk_employers_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Skills (
    skill_id   INT          NOT NULL AUTO_INCREMENT,
    skill_name VARCHAR(100) NOT NULL,
    category   ENUM(
        'programming',
        'database',
        'framework',
        'cloud',
        'tools',
        'data',
        'web',
        'soft',
        'engineering',
        'science',
        'education'
    ) NOT NULL,

    PRIMARY KEY (skill_id),
    UNIQUE KEY uq_skills_name   (skill_name),
    INDEX  idx_skills_category  (category)
);

CREATE TABLE CandidateSkills (
    candidate_skill_id INT     NOT NULL AUTO_INCREMENT,
    candidate_id       INT     NOT NULL,
    skill_id           INT     NOT NULL,
    proficiency_level  TINYINT NOT NULL DEFAULT 5,

    PRIMARY KEY (candidate_skill_id),
    UNIQUE KEY uq_candidate_skill (candidate_id, skill_id),
    INDEX  idx_cs_skill_id        (skill_id),

    CONSTRAINT chk_cs_proficiency
        CHECK (proficiency_level BETWEEN 1 AND 10),

    CONSTRAINT fk_cs_candidate
        FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cs_skill
        FOREIGN KEY (skill_id)     REFERENCES Skills(skill_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Jobs (
    job_id            INT          NOT NULL AUTO_INCREMENT,
    employer_id       INT          NOT NULL,
    job_title         VARCHAR(255) NOT NULL,
    job_description   TEXT                  DEFAULT NULL,
    location          VARCHAR(255)          DEFAULT NULL,
    salary_range      VARCHAR(100)          DEFAULT NULL,
    status            ENUM('open', 'closed') NOT NULL DEFAULT 'open',
    application_limit INT          NOT NULL DEFAULT 50
                                   COMMENT 'Max applications before job auto-closes. Employer can update this.',
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (job_id),
    INDEX idx_jobs_employer (employer_id),
    INDEX idx_jobs_status   (status),
    INDEX idx_jobs_title    (job_title),

    CONSTRAINT chk_jobs_app_limit
        CHECK (application_limit > 0),

    CONSTRAINT fk_jobs_employer
        FOREIGN KEY (employer_id) REFERENCES Employers(employer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE JobSkills (
    job_skill_id INT     NOT NULL AUTO_INCREMENT,
    job_id       INT     NOT NULL,
    skill_id     INT     NOT NULL,
    weight       TINYINT NOT NULL DEFAULT 5,

    PRIMARY KEY (job_skill_id),
    UNIQUE KEY uq_job_skill (job_id, skill_id),
    INDEX  idx_js_skill_id  (skill_id),

    CONSTRAINT chk_js_weight
        CHECK (weight BETWEEN 1 AND 10),

    CONSTRAINT fk_js_job
        FOREIGN KEY (job_id)   REFERENCES Jobs(job_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_js_skill
        FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Applications (
    application_id INT           NOT NULL AUTO_INCREMENT,
    job_id         INT           NOT NULL,
    candidate_id   INT           NOT NULL,
    match_score    DECIMAL(5, 2)          DEFAULT NULL
        COMMENT 'Auto-filled by trigger trg_calc_match_on_apply',
    status         ENUM(
        'pending',
        'shortlisted',
        'rejected',
        'interview_scheduled'
    ) NOT NULL DEFAULT 'pending',
    applied_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (application_id),
    UNIQUE KEY uq_application   (job_id, candidate_id),
    INDEX  idx_app_candidate    (candidate_id),
    INDEX  idx_app_status       (status),
    INDEX idx_app_job_candidate (job_id, candidate_id),

    CONSTRAINT fk_app_job
        FOREIGN KEY (job_id)       REFERENCES Jobs(job_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_app_candidate
        FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Interviews (
    interview_id   INT     NOT NULL AUTO_INCREMENT,
    application_id INT     NOT NULL,
    round_number   TINYINT NOT NULL DEFAULT 1,
    interview_date DATETIME         DEFAULT NULL,
    interview_mode ENUM('online', 'in_person') NOT NULL DEFAULT 'online',
    status         ENUM('scheduled', 'completed', 'cancelled')
                           NOT NULL DEFAULT 'scheduled',
    notes          TEXT             DEFAULT NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (interview_id),
    INDEX idx_iv_application (application_id),
    INDEX idx_iv_date        (interview_date),

    CONSTRAINT fk_iv_application
        FOREIGN KEY (application_id) REFERENCES Applications(application_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT 'HireSmart schema created successfully.' AS result;
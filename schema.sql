DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;
CREATE SCHEMA lab_tracker_group_16;
set search_path TO lab_tracker_group_16;

-- Drop tables before definition
DROP TABLE IF EXISTS progress_change_log CASCADE;
DROP TABLE IF EXISTS progress CASCADE;
DROP TABLE IF EXISTS lab_event CASCADE;
DROP TABLE IF EXISTS lab_assignment CASCADE;
DROP TABLE IF EXISTS section CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS set CASCADE;
DROP TABLE IF EXISTS term CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

-- Create tables
CREATE TABLE "user"(
    user_id                     VARCHAR(20) PRIMARY KEY,
    first_name                  VARCHAR(50) NOT NULL,
    last_name                   VARCHAR(50) NOT NULL,
    email                       VARCHAR(50) NOT NULL,
    role                        VARCHAR(50) NOT NULL,

    CONSTRAINT unique_email_chk UNIQUE(email),
    CONSTRAINT user_role_chk CHECK (role IN ('instructor', 'system', 'ta', 'student'))
);

CREATE TABLE course (
    course_code                 CHAR(8) PRIMARY KEY,
    title                       VARCHAR(50) NOT NULL,
    credits                     INTEGER NOT NULL,

    CONSTRAINT course_credits_chk CHECK (credits > 0)
);

CREATE TABLE term (
    term_code                   VARCHAR(10) PRIMARY KEY,
    name                        VARCHAR(20) NOT NULL,
    start_date                  DATE NOT NULL,
    end_date                    DATE NOT NULL,

    CONSTRAINT term_dates_chk CHECK (end_date > start_date)
);

CREATE TABLE set (
    set_code                    CHAR(1) PRIMARY KEY,
    campus                      VARCHAR(50) NOT NULL
);

CREATE TABLE student (
    student_id                  CHAR(20) PRIMARY KEY,
    set_code                    CHAR(1) NOT NULL,

    FOREIGN KEY (student_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    FOREIGN KEY (set_code) REFERENCES set(set_code)
);

CREATE TABLE section (
    section_code                VARCHAR(20) PRIMARY KEY,
    course_code                 CHAR(8) NOT NULL REFERENCES course(course_code),
    term_code                   VARCHAR(10) REFERENCES term(term_code),
    set_code                    CHAR(1) REFERENCES set(set_code),
    type                        VARCHAR(10) CHECK (type IN ('LAB')),
    day_of_week                 VARCHAR(10),
    start_time                  TIME,
    end_time                    TIME,
    location                    VARCHAR(50),


    FOREIGN KEY (course_code) REFERENCES course(course_code),
    FOREIGN KEY (term_code) REFERENCES term(term_code),
    FOREIGN KEY (set_code) REFERENCES set(set_code),

    CONSTRAINT section_unique UNIQUE (course_code, term_code, set_code),
    CONSTRAINT section_type_chk CHECK (type IN ('LAB')),
    CONSTRAINT section_times_chk CHECK (start_time IS NULL OR end_time IS NULL OR start_time < end_time)
);

CREATE TABLE lab_assignment (
    assignment_id               CHAR(6) PRIMARY KEY,
    course_code                 CHAR(8) NOT NULL,
    term_code                   VARCHAR(10) NOT NULL,
    lab_number                  CHAR(2) NOT NULL,
    title                       VARCHAR(50),

    FOREIGN KEY (course_code) REFERENCES course(course_code),
    FOREIGN KEY (term_code) REFERENCES term(term_code),

    CONSTRAINT lab_number_unq UNIQUE (lab_number),
    CONSTRAINT lab_per_term_unq UNIQUE (course_code, term_code, lab_number)
);


CREATE TABLE lab_event (
    event_id                    CHAR(7) PRIMARY KEY,
    section_code                VARCHAR(20) NOT NULL,
    course_code                 CHAR(8) NOT NULL,
    term_code                   VARCHAR(10) NOT NULL,
    lab_number                  CHAR(2) NOT NULL,
    start_datetime              TIMESTAMP NOT NULL,
    end_datetime                TIMESTAMP NOT NULL,
    due_datetime                TIMESTAMP NOT NULL,
    location                    VARCHAR(50),

    FOREIGN KEY (section_code) REFERENCES section(section_code),
    FOREIGN KEY (course_code) REFERENCES course(course_code),
    FOREIGN KEY (term_code) REFERENCES term(term_code),
    FOREIGN KEY (lab_number) REFERENCES lab_assignment(lab_number),

    CONSTRAINT event_times_chk CHECK (start_datetime < end_datetime AND end_datetime <= due_datetime)
);

CREATE TABLE progress (
    progress_id                 VARCHAR(20) PRIMARY KEY,
    student_id                  CHAR(20) NOT NULL,
    event_id                    CHAR(7) NOT NULL,
    lab_number                  CHAR(2) NOT NULL,
    status                      VARCHAR(20),
    prepared                    BOOLEAN,
    attendance                  VARCHAR(20),
    inlab_submitted_at          TIMESTAMP,
    inlab_submission_link       VARCHAR(255),
    polished_submitted_at       TIMESTAMP,
    polished_submission_link    VARCHAR(255),
    instructor_assessment       DECIMAL(4,2),
    self_assessment             DECIMAL(4,2),
    late                        BOOLEAN,

    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (event_id) REFERENCES lab_event(event_id),
    FOREIGN KEY (lab_number) REFERENCES lab_assignment(lab_number),

    CONSTRAINT progress_student_event_unq UNIQUE (student_id, event_id),
    CONSTRAINT progress_status_chk CHECK (status IN ('Submitted', 'In Progress', 'Missing')),
    CONSTRAINT progress_attendance_chk CHECK (attendance IN ('Present', 'Absent', 'Late')),
    CONSTRAINT progress_instructor_score_chk CHECK (instructor_assessment IS NULL OR instructor_assessment BETWEEN 0 AND 100),
    CONSTRAINT progress_self_score_chk CHECK (self_assessment IS NULL OR self_assessment BETWEEN 0 AND 100),
    CONSTRAINT progress_submission_order_chk CHECK (polished_submitted_at IS NULL OR inlab_submitted_at IS NULL OR polished_submitted_at >= inlab_submitted_at)
);

CREATE TABLE progress_change_log (
    change_id                   CHAR(5) PRIMARY KEY,
    progress_id                 VARCHAR(20) NOT NULL,
    changed_by                  VARCHAR(20) NOT NULL,
    changed_at                  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    field                       VARCHAR(50) NOT NULL,
    old_value                   VARCHAR(100),
    new_value                   VARCHAR(100),
    reason                      VARCHAR(255),

    FOREIGN KEY (progress_id) REFERENCES progress(progress_id),
    FOREIGN KEY (changed_by) REFERENCES "user"(user_id)
);


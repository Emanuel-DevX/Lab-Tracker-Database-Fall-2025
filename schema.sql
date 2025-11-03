DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;
CREATE SCHEMA lab_tracker_group_16;
set search_path TO lab_tracker_group_16;

--Drop tables before definition

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

CREATE TABLE "user"(
    user_id VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(50),
    role VARCHAR(50) CHECK(role IN ('instructor', 'system', 'ta')),
    email VARCHAR(50)

);

CREATE TABLE course (
    course_code CHAR(8) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL,

    --Constraints
    CONSTRAINT course_credits_chk CHECK (credits > 0)
);

CREATE TABLE set (
    set_code CHAR(1) PRIMARY KEY,
    campus VARCHAR(50) NOT NULL
);

CREATE TABLE student (
    student_id CHAR(9) PRIMARY KEY,
    set_code CHAR(1) NOT NULL REFERENCES set(set_code),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL

);

CREATE TABLE term (
    term_code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL

);

CREATE TABLE section (
    section_code VARCHAR(20) PRIMARY KEY,
    course_code CHAR(8) NOT NULL REFERENCES course(course_code),
    term_code VARCHAR(10) REFERENCES term(term_code),
    set_code    CHAR(1) REFERENCES set(set_code),
    type VARCHAR(10) CHECK (type IN ('LAB')),
    day_of_week VARCHAR(10),
    start_time TIME,
    end_time TIME,
    location VARCHAR(50)
);

CREATE TABLE lab_assignment (
assignment_id CHAR(6) PRIMARY KEY,
course_code CHAR(8) NOT NULL REFERENCES course(course_code),
term_code VARCHAR(10) REFERENCES term(term_code),
lab_number CHAR(2) UNIQUE NOT NULL,
title VARCHAR(50)
CONSTRAINT unique_lab UNIQUE (course_code, term_code, lab_number)
);


CREATE TABLE lab_event (
    event_id CHAR(7) PRIMARY KEY,
    section_code VARCHAR(20) NOT NULL REFERENCES section(section_code),
    course_code CHAR(8) NOT NULL REFERENCES course(course_code),
    term_code VARCHAR(10) NOT NULL REFERENCES term(term_code),
    lab_number CHAR(2) NOT NULL REFERENCES lab_assignment(lab_number),
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    due_datetime TIMESTAMP,
    location VARCHAR(50)
);

CREATE TABLE progress (
    progress_id              VARCHAR(20) PRIMARY KEY,
    student_id               CHAR(9) NOT NULL REFERENCES student(student_id),
    event_id                 CHAR(7) NOT NULL REFERENCES lab_event(event_id),
    lab_number               CHAR(2) NOT NULL REFERENCES lab_assignment(lab_number),
    status                   VARCHAR(20) CHECK (status IN ('Submitted', 'In progress', 'Missing')),
    prepared                 BOOLEAN,
    attendance               VARCHAR(20) CHECK (attendance IN ('Present', 'Absent', 'Late')),
    inlab_submitted_at       TIMESTAMP,
    inlab_submission_link    VARCHAR(255),
    polished_submitted_at    TIMESTAMP,
    polished_submission_link VARCHAR(255),
    instructor_assessment    DECIMAL(4,2),
    self_assessment          DECIMAL(4,2),
    late                     BOOLEAN,

    CONSTRAINT student_event UNIQUE (student_id, event_id)
);

CREATE TABLE progress_change_log (
    change_id CHAR(5) PRIMARY KEY,
    progress_id VARCHAR(20)  NOT NULL REFERENCES progress(progress_id),
    changed_by VARCHAR(20) NOT NULL REFERENCES "user"(user_id),
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    field VARCHAR(50) NOT NULL,
    old_value VARCHAR(100),
    new_value VARCHAR(100),
    reason VARCHAR(255)
);


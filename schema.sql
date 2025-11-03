DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;
CREATE SCHEMA lab_tracker_group_16;
SET search_path TO lab_tracker_group_16;

--Drop tables before definition

DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Set CASCADE;
DROP TABLE IF EXISTS Student CASCADE;
DROP TABLE IF EXISTS Term CASCADE;
DROP TABLE IF EXISTS Section CASCADE;
DROP TABLE IF EXISTS lab_Assignment CASCADE;
DROP TABLE IF EXISTS lab_event CASCADE;


CREATE TABLE Course (
    course_code CHAR(8) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL,

    --Constraints
    CONSTRAINT course_credits_chk CHECK (credits > 0)
);

CREATE TABLE Set (
    set_code CHAR(1) PRIMARY KEY,
    campus VARCHAR(50) NOT NULL
);

CREATE TABLE Student (
    student_id CHAR(9) PRIMARY KEY,
    set_code CHAR(1) REFERENCES Set NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50)

);

CREATE TABLE Term (
    term_code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL

);

CREATE TABLE Section (
    section_code VARCHAR(20) PRIMARY KEY,
    course_code CHAR(8) NOT NULL REFERENCES Course(course_code),
    term_code VARCHAR(10) REFERENCES Term(term_code),
    type VARCHAR(10) CHECK (type IN ('Lab')),
    day_of_week VARCHAR(10),
    start_time TIME,
    end_time TIME,
    location VARCHAR(50)
);

CREATE TABLE lab_assignment (
assignment_id CHAR(6) PRIMARY KEY,
course_code CHAR(8) REFERENCES set NOT NULL,
term_code VARCHAR(10),
lab_number CHAR(2) UNIQUE NOT NULL,
title VARCHAR(50)
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


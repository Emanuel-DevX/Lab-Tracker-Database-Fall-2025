DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;
CREATE SCHEMA lab_tracker_group_16;
SET search_path TO lab_tracker_group_16;

--Drop tables before definition

DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Set CASCADE;
DROP TABLE IF EXISTS Student CASCADE;
DROP TABLE IF EXISTS Term CASCADE;

CREATE TABLE Course (
    course_code CHAR(8) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL

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
    term_code INTEGER PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL

);


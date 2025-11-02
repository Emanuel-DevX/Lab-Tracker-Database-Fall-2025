DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;
CREATE SCHEMA lab_tracker_group_16;
SET search_path TO lab_tracker_group_16;

--Drop tables before definition

DROP TABLE IF EXISTS Course CASCADE;

CREATE TABLE Course (
    course_code CHAR(8) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL

);

-- ============================================================
-- Lab Tracker - Seed Data (csv) Import Script
-- ============================================================

SET search_path TO lab_tracker_group_16;

-- ctrl+f '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025'
-- change to your path

---------------------------------------------------------------
-- No dependency tables
---------------------------------------------------------------
-- Users
COPY "user"
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/users.csv'
DELIMITER ',' CSV HEADER;

-- Courses
COPY course
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/courses.csv'
DELIMITER ',' CSV HEADER;

-- Terms
COPY term
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/terms.csv'
DELIMITER ',' CSV HEADER;

-- Sets
COPY set
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/sets.csv'
DELIMITER ',' CSV HEADER;

---------------------------------------------------------------
-- Students (via staging table)
---------------------------------------------------------------
DROP TABLE IF EXISTS staging_student_csv;

CREATE TABLE staging_student_csv (
    student_id  CHAR(20),
    set_code    CHAR(1),
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(50)
);

COPY staging_student_csv
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/students.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO "user" (user_id, first_name, last_name, email, role)
SELECT
    student_id,
    first_name,
    last_name,
    email,
    'student'
FROM staging_student_csv;

INSERT INTO student (student_id, set_code)
SELECT
    student_id,
    set_code
FROM staging_student_csv;

DROP TABLE staging_student_csv;

---------------------------------------------------------------
-- Sections
---------------------------------------------------------------
COPY section
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/sections.csv'
DELIMITER ',' CSV HEADER;

---------------------------------------------------------------
-- Lab Assignments
---------------------------------------------------------------
COPY lab_assignment
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/lab_assignments.csv'
DELIMITER ',' CSV HEADER;

---------------------------------------------------------------
-- Lab Events
---------------------------------------------------------------
COPY lab_event
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/lab_events.csv'
DELIMITER ',' CSV HEADER;

---------------------------------------------------------------
-- Progress
---------------------------------------------------------------
COPY progress
FROM '/Users/jimmycho/Desktop/JC/cst/T2/2714/pj/LabTracker/Lab-Tracker-Database-Fall-2025/progress.csv'
DELIMITER ',' CSV HEADER;

---------------------------------------------------------------
-- Progress Change Log
---------------------------------------------------------------
-- not importing seed data for change log
SET search_path TO lab_tracker_group_16;


-- Clear existing data in all tables (in dependency order)
TRUNCATE TABLE
    progress_change_log,
    progress,
    lab_event,
    lab_assignment,
    section,
    student,
    set,
    term,
    course,
    "user"
CASCADE;

INSERT INTO course (course_code, title, credits) VALUES
('COMP2714','Relational Database Systems',3);


INSERT INTO term (term_code, name, start_date, end_date) VALUES
('202510', 'Winter 2025', '2025-01-06', '2025-04-11'),
('202520', 'Spring/Summer 2025', '2025-04-28', '2025-08-08'),
('202530', 'Fall 2025', '2025-09-02', '2025-12-12');

SELECT * FROM term;


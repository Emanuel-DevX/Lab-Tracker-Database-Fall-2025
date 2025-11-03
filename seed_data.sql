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

SELECT * FROM course;

INSERT INTO set (set_code, campus) VALUES ('A', 'Burnaby');
INSERT INTO set (set_code, campus) VALUES ('B', 'Burnaby');
INSERT INTO set (set_code, campus) VALUES ('C', 'Burnaby');
INSERT INTO set (set_code, campus) VALUES ('D', 'Burnaby');
INSERT INTO set (set_code, campus) VALUES ('E', 'Downtown');
INSERT INTO set (set_code, campus) VALUES ('F', 'Downtown');

SELECT * FROM set;
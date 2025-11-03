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

-- Insert sample users
INSERT INTO "user" (user_id, first_name, last_name, role, email) VALUES
('u_instructor', 'Maryam', 'Khezrzadeh', 'instructor', 'mkhezrzadeh@bcit.ca'),
('u_ta1', 'Daniel', 'Saavedra', 'ta', 'dsaavedra@bcit.ca'),
('u_system', 'Lab Tracker', 'System', 'system', 'noreply@labtracker.local');

-- Insert user records for students (supertype of student)
INSERT INTO "user" (user_id, first_name, last_name, email, role) VALUES
('A001', 'Ava', 'Nguyen', 'ava.nguyen@my.bcit.ca', 'student'),
('A002', 'Noah', 'Kim', 'noah.kim@my.bcit.ca', 'student'),
('A003', 'Oliver', 'Singh', 'oliver.singh@my.bcit.ca', 'student'),
('B001', 'Maya', 'Fischer', 'maya.fischer@my.bcit.ca', 'student'),
('B002', 'Leo', 'Park', 'leo.park@my.bcit.ca', 'student'),
('B003', 'Zoé', 'Martin', 'zoe.martin@my.bcit.ca', 'student'),
('C001', 'Sofia', 'Chen', 'sofia.chen@my.bcit.ca', 'student'),
('C002', 'Arjun', 'Patel', 'arjun.patel@my.bcit.ca', 'student'),
('C003', 'Liam', 'O''Reilly', 'liam.oreilly@my.bcit.ca', 'student'),
('D001', 'Layla', 'Haddad', 'layla.haddad@my.bcit.ca', 'student'),
('D002', 'Ethan', 'Wong', 'ethan.wong@my.bcit.ca', 'student'),
('D003', 'Nora', 'Iverson', 'nora.iverson@my.bcit.ca', 'student'),
('E001', 'Diego', 'Alvarez', 'diego.alvarez@my.bcit.ca', 'student'),
('E002', 'Hana', 'Yamamoto', 'hana.yamamoto@my.bcit.ca', 'student'),
('E003', 'Farah', 'Rahimi', 'farah.rahimi@my.bcit.ca', 'student'),
('F001', 'Marco', 'Russo', 'marco.russo@my.bcit.ca', 'student'),
('F002', 'Amir', 'Kazemi', 'amir.kazemi@my.bcit.ca', 'student'),
('F003', 'Chloe', 'Dubois', 'chloe.dubois@my.bcit.ca', 'student');


-- Insert available courses
INSERT INTO course (course_code, title, credits) VALUES
('COMP2714','Relational Database Systems',3);

-- Insert terms
INSERT INTO term (term_code, name, start_date, end_date) VALUES
('202510', 'Winter 2025', '2025-01-06', '2025-04-11'),
('202520', 'Spring/Summer 2025', '2025-04-28', '2025-08-08'),
('202530', 'Fall 2025', '2025-09-02', '2025-12-12');

-- Insert available sets
INSERT INTO set(set_code, campus) VALUES
('A', 'Burnaby'),
('B', 'Burnaby'),
('C', 'Burnaby'),
('D', 'Burnaby'),
('E', 'Downtown'),
('F', 'Downtown');

-- Insert students (subtype of "user")
INSERT INTO student (student_id, set_code) VALUES
('A001', 'A'),
('A002', 'A'),
('A003', 'A'),
('B001', 'B'),
('B002', 'B'),
('B003', 'B'),
('C001', 'C'),
('C002', 'C'),
('C003', 'C'),
('D001', 'D'),
('D002', 'D'),
('D003', 'D'),
('E001', 'E'),
('E002', 'E'),
('E003', 'E'),
('F001', 'F'),
('F002', 'F'),
('F003', 'F');


-- Insert available sections
INSERT INTO section 
(section_code, course_code, term_code, set_code, type, day_of_week, start_time, end_time, location) VALUES
('L01', 'COMP2714', '202530', 'A', 'LAB', 'Mon', '09:30', '11:20', 'BBY-SW01-3460'),
('L02', 'COMP2714', '202530', 'B', 'LAB', 'Mon', '13:30', '15:20', 'BBY-SW01-3465'),
('L03', 'COMP2714', '202530', 'C', 'LAB', 'Tue', '18:30', '20:20', 'BBY-SW03-2605'),
('L04', 'COMP2714', '202530', 'D', 'LAB', 'Wed', '09:30', '11:20', 'BBY-SE12-101'),
('L05', 'COMP2714', '202530', 'E', 'LAB', 'Wed', '13:30', '15:20', 'DTC-310'),
('L06', 'COMP2714', '202530', 'F', 'LAB', 'Thu', '18:30', '20:20', 'DTC-318');

-- Insert lab assignments 
INSERT INTO lab_assignment
(assignment_id, course_code, term_code, lab_number, title) VALUES
('LAB01', 'COMP2714', '202530', '1', 'Environment Setup & Intro SQL'),
('LAB02', 'COMP2714', '202530', '2', 'Conceptual → Logical Mapping'),
('LAB03', 'COMP2714', '202530', '3', 'Logical ERD & Constraints'),
('LAB04', 'COMP2714', '202530', '4', 'Normalization to 3NF'),
('LAB05', 'COMP2714', '202530', '5', 'DDL Implementation'),
('LAB06', 'COMP2714', '202530', '6', 'DML: INSERT/UPDATE/DELETE'),
('LAB07', 'COMP2714', '202530', '7', 'SELECT & JOIN Practice'),
('LAB08', 'COMP2714', '202530', '8', 'Views & Indexes');

-- Insert lab event details
INSERT INTO lab_event (
    event_id, section_code, course_code, term_code, lab_number,
    start_datetime, end_datetime, due_datetime, location
) VALUES
('L01-L01', 'L01', 'COMP2714', '202530', '1', '2025-09-08 09:30', '2025-09-08 11:20', '2025-09-14 23:59', 'BBY-SW01-3460'),
('L01-L02', 'L01', 'COMP2714', '202530', '2', '2025-09-15 09:30', '2025-09-15 11:20', '2025-09-21 23:59', 'BBY-SW01-3460'),
('L01-L03', 'L01', 'COMP2714', '202530', '3', '2025-09-22 09:30', '2025-09-22 11:20', '2025-09-28 23:59', 'BBY-SW01-3460'),
('L02-L01', 'L02', 'COMP2714', '202530', '1', '2025-09-08 13:30', '2025-09-08 15:20', '2025-09-14 23:59', 'BBY-SW01-3465'),
('L02-L02', 'L02', 'COMP2714', '202530', '2', '2025-09-15 13:30', '2025-09-15 15:20', '2025-09-21 23:59', 'BBY-SW01-3465'),
('L02-L03', 'L02', 'COMP2714', '202530', '3', '2025-09-22 13:30', '2025-09-22 15:20', '2025-09-28 23:59', 'BBY-SW01-3465'),
('L03-L01', 'L03', 'COMP2714', '202530', '1', '2025-09-09 18:30', '2025-09-09 20:20', '2025-09-14 23:59', 'BBY-SW03-2605'),
('L03-L02', 'L03', 'COMP2714', '202530', '2', '2025-09-16 18:30', '2025-09-16 20:20', '2025-09-21 23:59', 'BBY-SW03-2605'),
('L03-L03', 'L03', 'COMP2714', '202530', '3', '2025-09-23 18:30', '2025-09-23 20:20', '2025-09-28 23:59', 'BBY-SW03-2605'),
('L04-L01', 'L04', 'COMP2714', '202530', '1', '2025-09-10 09:30', '2025-09-10 11:20', '2025-09-14 23:59', 'BBY-SE12-101'),
('L04-L02', 'L04', 'COMP2714', '202530', '2', '2025-09-17 09:30', '2025-09-17 11:20', '2025-09-21 23:59', 'BBY-SE12-101'),
('L04-L03', 'L04', 'COMP2714', '202530', '3', '2025-09-24 09:30', '2025-09-24 11:20', '2025-09-28 23:59', 'BBY-SE12-101'),
('L05-L01', 'L05', 'COMP2714', '202530', '1', '2025-09-10 13:30', '2025-09-10 15:20', '2025-09-15 09:00', 'DTC-310'),
('L05-L02', 'L05', 'COMP2714', '202530', '2', '2025-09-17 13:30', '2025-09-17 15:20', '2025-09-22 09:00', 'DTC-310'),
('L05-L03', 'L05', 'COMP2714', '202530', '3', '2025-09-24 13:30', '2025-09-24 15:20', '2025-09-29 09:00', 'DTC-310'),
('L06-L01', 'L06', 'COMP2714', '202530', '1', '2025-09-11 18:30', '2025-09-11 20:20', '2025-09-15 09:00', 'DTC-318'),
('L06-L02', 'L06', 'COMP2714', '202530', '2', '2025-09-18 18:30', '2025-09-18 20:20', '2025-09-22 09:00', 'DTC-318'),
('L06-L03', 'L06', 'COMP2714', '202530', '3', '2025-09-25 18:30', '2025-09-25 20:20', '2025-09-29 09:00', 'DTC-318');

-- Insert student progress
INSERT INTO progress (
    progress_id, student_id, event_id, lab_number, status, prepared, 
    attendance, inlab_submitted_at, inlab_submission_link, polished_submitted_at, 
    polished_submission_link, instructor_assessment, self_assessment, late
) VALUES
('A001-L01-L01','A001','L01-L01','1','Submitted',TRUE,'Present','2025-09-08 10:45','https://submit.bcit.ca/comp2714/inlab/A001-L01-L01.pdf','2025-09-09 12:45','https://submit.bcit.ca/comp2714/polished/A001-L01-L01.pdf',8.5,8.2,FALSE),
('A001-L01-L02','A001','L01-L02','2','Submitted',TRUE,'Present','2025-09-15 10:35','https://submit.bcit.ca/comp2714/inlab/A001-L01-L02.pdf','2025-09-17 11:35','https://submit.bcit.ca/comp2714/polished/A001-L01-L02.pdf',7.0,6.7,FALSE),
('A002-L01-L01','A002','L01-L01','1','Submitted',TRUE,'Present','2025-09-08 10:45','https://submit.bcit.ca/comp2714/inlab/A002-L01-L01.pdf','2025-09-09 12:45','https://submit.bcit.ca/comp2714/polished/A002-L01-L01.pdf',8.5,8.2,FALSE),
('A002-L01-L02','A002','L01-L02','2','In Progress',TRUE,'Present','2025-09-15 10:40','https://submit.bcit.ca/comp2714/inlab/A002-L01-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('A003-L01-L01','A003','L01-L01','1','Submitted',TRUE,'Present','2025-09-08 10:45','https://submit.bcit.ca/comp2714/inlab/A003-L01-L01.pdf','2025-09-09 12:45','https://submit.bcit.ca/comp2714/polished/A003-L01-L01.pdf',8.5,8.2,FALSE),
('A003-L01-L02','A003','L01-L02','2','Submitted',FALSE,'Present','2025-09-15 10:35','https://submit.bcit.ca/comp2714/inlab/A003-L01-L02.pdf','2025-09-17 11:35','https://submit.bcit.ca/comp2714/polished/A003-L01-L02.pdf',7.0,6.7,FALSE),
('B001-L02-L01','B001','L02-L01','1','Submitted',TRUE,'Present','2025-09-08 14:45','https://submit.bcit.ca/comp2714/inlab/B001-L02-L01.pdf','2025-09-09 16:45','https://submit.bcit.ca/comp2714/polished/B001-L02-L01.pdf',8.5,8.2,FALSE),
('B001-L02-L02','B001','L02-L02','2','Submitted',TRUE,'Present','2025-09-15 14:35','https://submit.bcit.ca/comp2714/inlab/B001-L02-L02.pdf','2025-09-17 15:35','https://submit.bcit.ca/comp2714/polished/B001-L02-L02.pdf',7.0,6.7,FALSE),
('B002-L02-L01','B002','L02-L01','1','Submitted',TRUE,'Present','2025-09-08 14:45','https://submit.bcit.ca/comp2714/inlab/B002-L02-L01.pdf','2025-09-09 16:45','https://submit.bcit.ca/comp2714/polished/B002-L02-L01.pdf',8.5,8.2,FALSE),
('B002-L02-L02','B002','L02-L02','2','In Progress',TRUE,'Present','2025-09-15 14:40','https://submit.bcit.ca/comp2714/inlab/B002-L02-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('B003-L02-L01','B003','L02-L01','1','Submitted',TRUE,'Present','2025-09-08 14:45','https://submit.bcit.ca/comp2714/inlab/B003-L02-L01.pdf','2025-09-09 16:45','https://submit.bcit.ca/comp2714/polished/B003-L02-L01.pdf',8.5,8.2,FALSE),
('B003-L02-L02','B003','L02-L02','2','Submitted',FALSE,'Present','2025-09-15 14:35','https://submit.bcit.ca/comp2714/inlab/B003-L02-L02.pdf','2025-09-17 15:35','https://submit.bcit.ca/comp2714/polished/B003-L02-L02.pdf',7.0,6.7,FALSE),
('C001-L03-L01','C001','L03-L01','1','Submitted',TRUE,'Present','2025-09-09 19:45','https://submit.bcit.ca/comp2714/inlab/C001-L03-L01.pdf','2025-09-10 21:45','https://submit.bcit.ca/comp2714/polished/C001-L03-L01.pdf',8.5,8.2,FALSE),
('C001-L03-L02','C001','L03-L02','2','Submitted',TRUE,'Present','2025-09-16 19:35','https://submit.bcit.ca/comp2714/inlab/C001-L03-L02.pdf','2025-09-18 20:35','https://submit.bcit.ca/comp2714/polished/C001-L03-L02.pdf',7.0,6.7,FALSE),
('C002-L03-L01','C002','L03-L01','1','Submitted',TRUE,'Present','2025-09-09 19:45','https://submit.bcit.ca/comp2714/inlab/C002-L03-L01.pdf','2025-09-10 21:45','https://submit.bcit.ca/comp2714/polished/C002-L03-L01.pdf',8.5,8.2,FALSE),
('C002-L03-L02','C002','L03-L02','2','In Progress',TRUE,'Present','2025-09-16 19:40','https://submit.bcit.ca/comp2714/inlab/C002-L03-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('C003-L03-L01','C003','L03-L01','1','Submitted',TRUE,'Present','2025-09-09 19:45','https://submit.bcit.ca/comp2714/inlab/C003-L03-L01.pdf','2025-09-10 21:45','https://submit.bcit.ca/comp2714/polished/C003-L03-L01.pdf',8.5,8.2,FALSE),
('C003-L03-L02','C003','L03-L02','2','Submitted',FALSE,'Present','2025-09-16 19:35','https://submit.bcit.ca/comp2714/inlab/C003-L03-L02.pdf','2025-09-18 20:35','https://submit.bcit.ca/comp2714/polished/C003-L03-L02.pdf',7.0,6.7,FALSE),
('D001-L04-L01','D001','L04-L01','1','Submitted',TRUE,'Present','2025-09-10 10:45','https://submit.bcit.ca/comp2714/inlab/D001-L04-L01.pdf','2025-09-11 12:45','https://submit.bcit.ca/comp2714/polished/D001-L04-L01.pdf',8.5,8.2,FALSE),
('D001-L04-L02','D001','L04-L02','2','Submitted',TRUE,'Present','2025-09-17 10:35','https://submit.bcit.ca/comp2714/inlab/D001-L04-L02.pdf','2025-09-19 11:35','https://submit.bcit.ca/comp2714/polished/D001-L04-L02.pdf',7.0,6.7,FALSE),
('D002-L04-L01','D002','L04-L01','1','Submitted',TRUE,'Present','2025-09-10 10:45','https://submit.bcit.ca/comp2714/inlab/D002-L04-L01.pdf','2025-09-11 12:45','https://submit.bcit.ca/comp2714/polished/D002-L04-L01.pdf',8.5,8.2,FALSE),
('D002-L04-L02','D002','L04-L02','2','In Progress',TRUE,'Present','2025-09-17 10:40','https://submit.bcit.ca/comp2714/inlab/D002-L04-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('D003-L04-L01','D003','L04-L01','1','Submitted',TRUE,'Present','2025-09-10 10:45','https://submit.bcit.ca/comp2714/inlab/D003-L04-L01.pdf','2025-09-11 12:45','https://submit.bcit.ca/comp2714/polished/D003-L04-L01.pdf',8.5,8.2,FALSE),
('D003-L04-L02','D003','L04-L02','2','Submitted',FALSE,'Present','2025-09-17 10:35','https://submit.bcit.ca/comp2714/inlab/D003-L04-L02.pdf','2025-09-19 11:35','https://submit.bcit.ca/comp2714/polished/D003-L04-L02.pdf',7.0,6.7,FALSE),
('E001-L05-L01','E001','L05-L01','1','Submitted',TRUE,'Present','2025-09-11 14:45','https://submit.bcit.ca/comp2714/inlab/E001-L05-L01.pdf','2025-09-12 16:45','https://submit.bcit.ca/comp2714/polished/E001-L05-L01.pdf',8.5,8.2,FALSE),
('E001-L05-L02','E001','L05-L02','2','Submitted',TRUE,'Present','2025-09-18 14:35','https://submit.bcit.ca/comp2714/inlab/E001-L05-L02.pdf','2025-09-20 15:35','https://submit.bcit.ca/comp2714/polished/E001-L05-L02.pdf',7.0,6.7,FALSE),
('E002-L05-L01','E002','L05-L01','1','Submitted',TRUE,'Present','2025-09-11 14:45','https://submit.bcit.ca/comp2714/inlab/E002-L05-L01.pdf','2025-09-12 16:45','https://submit.bcit.ca/comp2714/polished/E002-L05-L01.pdf',8.5,8.2,FALSE),
('E002-L05-L02','E002','L05-L02','2','In Progress',TRUE,'Present','2025-09-18 14:40','https://submit.bcit.ca/comp2714/inlab/E002-L05-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('E003-L05-L01','E003','L05-L01','1','Submitted',TRUE,'Present','2025-09-11 14:45','https://submit.bcit.ca/comp2714/inlab/E003-L05-L01.pdf','2025-09-12 16:45','https://submit.bcit.ca/comp2714/polished/E003-L05-L01.pdf',8.5,8.2,FALSE),
('E003-L05-L02','E003','L05-L02','2','Submitted',FALSE,'Present','2025-09-18 14:35','https://submit.bcit.ca/comp2714/inlab/E003-L05-L02.pdf','2025-09-20 15:35','https://submit.bcit.ca/comp2714/polished/E003-L05-L02.pdf',7.0,6.7,FALSE),
('F001-L06-L01','F001','L06-L01','1','Submitted',TRUE,'Present','2025-09-12 19:45','https://submit.bcit.ca/comp2714/inlab/F001-L06-L01.pdf','2025-09-13 21:45','https://submit.bcit.ca/comp2714/polished/F001-L06-L01.pdf',8.5,8.2,FALSE),
('F001-L06-L02','F001','L06-L02','2','Submitted',TRUE,'Present','2025-09-19 19:35','https://submit.bcit.ca/comp2714/inlab/F001-L06-L02.pdf','2025-09-21 20:35','https://submit.bcit.ca/comp2714/polished/F001-L06-L02.pdf',7.0,6.7,FALSE),
('F002-L06-L01','F002','L06-L01','1','Submitted',TRUE,'Present','2025-09-12 19:45','https://submit.bcit.ca/comp2714/inlab/F002-L06-L01.pdf','2025-09-13 21:45','https://submit.bcit.ca/comp2714/polished/F002-L06-L01.pdf',8.5,8.2,FALSE),
('F002-L06-L02','F002','L06-L02','2','In Progress',TRUE,'Present','2025-09-19 19:40','https://submit.bcit.ca/comp2714/inlab/F002-L06-L02.pdf',NULL,NULL,NULL,NULL,FALSE),
('F003-L06-L01','F003','L06-L01','1','Submitted',TRUE,'Present','2025-09-12 19:45','https://submit.bcit.ca/comp2714/inlab/F003-L06-L01.pdf','2025-09-13 21:45','https://submit.bcit.ca/comp2714/polished/F003-L06-L01.pdf',8.5,8.2,FALSE),
('F003-L06-L02','F003','L06-L02','2','Submitted',FALSE,'Present','2025-09-19 19:35','https://submit.bcit.ca/comp2714/inlab/F003-L06-L02.pdf','2025-09-21 20:35','https://submit.bcit.ca/comp2714/polished/F003-L06-L02.pdf',7.0,6.7,FALSE);


-- Insert student progress change logs
INSERT INTO progress_change_log (change_id, progress_id, changed_by, changed_at, field, old_value, new_value, reason) VALUES
('chg1', 'A001-L01-L01', 'u_instructor', '2025-09-09 12:10', 'instructor_assessment', '8.0', '8.5', 'Regraded after resubmission'),

('chg2', 'A003-L01-L02', 'u_ta1', '2025-09-16 20:45', 'status', 'In progress', 'Submitted', 'Student submitted during lab; TA marked as submitted'),

('chg3', 'B003-L02-L01', 'u_system', '2025-09-23 23:59', 'late', 'False', 'True', 'Auto-flagged after set-specific due time');

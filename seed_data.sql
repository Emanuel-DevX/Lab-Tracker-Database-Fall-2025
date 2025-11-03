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


INSERT INTO set(set_code, campus) VALUES
('A', 'Burnaby'),
('B', 'Burnaby'),
('C', 'Burnaby'),
('D', 'Burnaby'),
('E', 'Downtown'),
('F', 'Downtown');

-- Insert student records
INSERT INTO student (student_id, set_code, first_name, last_name, email) VALUES
('A001', 'A', 'Ava', 'Nguyen', 'ava.nguyen@my.bcit.ca'),
('A002', 'A', 'Noah', 'Kim', 'noah.kim@my.bcit.ca'),
('A003', 'A', 'Oliver', 'Singh', 'oliver.singh@my.bcit.ca'),
('B001', 'B', 'Maya', 'Fischer', 'maya.fischer@my.bcit.ca'),
('B002', 'B', 'Leo', 'Park', 'leo.park@my.bcit.ca'),
('B003', 'B', 'Zoé', 'Martin', 'zoe.martin@my.bcit.ca'),
('C001', 'C', 'Sofia', 'Chen', 'sofia.chen@my.bcit.ca'),
('C002', 'C', 'Arjun', 'Patel', 'arjun.patel@my.bcit.ca'),
('C003', 'C', 'Liam', 'O''Reilly', 'liam.oreilly@my.bcit.ca'),
('D001', 'D', 'Layla', 'Haddad', 'layla.haddad@my.bcit.ca'),
('D002', 'D', 'Ethan', 'Wong', 'ethan.wong@my.bcit.ca'),
('D003', 'D', 'Nora', 'Iverson', 'nora.iverson@my.bcit.ca'),
('E001', 'E', 'Diego', 'Alvarez', 'diego.alvarez@my.bcit.ca'),
('E002', 'E', 'Hana', 'Yamamoto', 'hana.yamamoto@my.bcit.ca'),
('E003', 'E', 'Farah', 'Rahimi', 'farah.rahimi@my.bcit.ca'),
('F001', 'F', 'Marco', 'Russo', 'marco.russo@my.bcit.ca'),
('F002', 'F', 'Amir', 'Kazemi', 'amir.kazemi@my.bcit.ca'),
('F003', 'F', 'Chloe', 'Dubois', 'chloe.dubois@my.bcit.ca');


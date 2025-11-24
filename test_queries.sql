-------------------------------------------------------------------
-- Lab Tracker Group 16 - Integrity Verification Queries
-- Author: Group 16
-- Date: November 2, 2025
-- Purpose: Validate DDL and seed data consistency
-------------------------------------------------------------------

-- Use the correct schema
SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- 1. Existence checks (should return at least a few rows each)
-------------------------------------------------------------------

SELECT * FROM course LIMIT 5;
SELECT * FROM student LIMIT 5;
SELECT * FROM term LIMIT 5;
SELECT * FROM section LIMIT 5;
SELECT * FROM lab_assignment LIMIT 5;
SELECT * FROM lab_event LIMIT 5;
SELECT * FROM progress LIMIT 5;
SELECT * FROM change_log LIMIT 5;
SELECT * FROM "user" LIMIT 5;

-------------------------------------------------------------------
-- 2. Referential integrity tests (joins that should succeed)
-------------------------------------------------------------------

-- Verify every Section links to a valid Course, Term, and Set
SELECT s.section_code, s.course_code, s.term_code, s.set_code
FROM section s
LEFT JOIN course c ON s.course_code = c.course_code
LEFT JOIN term t ON s.term_code = t.term_code
LEFT JOIN set ss ON s.set_code = ss.set_code
WHERE c.course_code IS NULL OR t.term_code IS NULL OR ss.set_code IS NULL;

-- Expect: 0 rows (means all foreign keys valid)

-------------------------------------------------------------------
-- 3. Lab Events correctly link to Sections, Courses, Terms, and Labs
-------------------------------------------------------------------

SELECT e.event_id, e.section_code, e.course_code, e.term_code, e.lab_number
FROM lab_event e
LEFT JOIN section s ON e.section_code = s.section_code
LEFT JOIN course c ON e.course_code = c.course_code
LEFT JOIN term t ON e.term_code = t.term_code
LEFT JOIN lab_assignment la ON e.lab_number = la.lab_number
WHERE s.section_code IS NULL OR c.course_code IS NULL OR t.term_code IS NULL OR la.lab_number IS NULL;

-- Expect: 0 rows

-------------------------------------------------------------------
-- 4. Progress rows link to valid Student, Event, and Lab Assignment
-------------------------------------------------------------------

SELECT p.progress_id, p.student_id, p.event_id, p.lab_number
FROM progress p
LEFT JOIN student s ON p.student_id = s.student_id
LEFT JOIN lab_event e ON p.event_id = e.event_id
LEFT JOIN lab_assignment la ON p.lab_number = la.lab_number
WHERE s.student_id IS NULL OR e.event_id IS NULL OR la.lab_number IS NULL;

-- Expect: 0 rows

-------------------------------------------------------------------
-- 5. Change log links to valid Progress records
-------------------------------------------------------------------

SELECT c.change_id, c.progress_id
FROM change_log c
LEFT JOIN progress p ON c.progress_id = p.progress_id
WHERE p.progress_id IS NULL;

-- Expect: 0 rows

-------------------------------------------------------------------
-- 6. Business rule checks
-------------------------------------------------------------------

-- Each Section belongs to exactly one Course, one Term, and one Set
SELECT section_code, COUNT(DISTINCT course_code) AS course_count,
       COUNT(DISTINCT term_code) AS term_count,
       COUNT(DISTINCT set_code) AS set_count
FROM section
GROUP BY section_code
HAVING COUNT(DISTINCT course_code) != 1
   OR COUNT(DISTINCT term_code) != 1
   OR COUNT(DISTINCT set_code) != 1;

-- Expect: 0 rows

-- Every Progress record should have a valid status value
SELECT DISTINCT status FROM progress;
-- Expect only: 'Submitted', 'In progress', 'Missing'

-- Attendance should be one of the allowed values
SELECT DISTINCT attendance FROM progress;
-- Expect only: 'Present', 'Absent', 'Late'

-------------------------------------------------------------------
-- 7. Data consistency / sanity checks
-------------------------------------------------------------------

-- Check duplicate student emails (should be unique)
SELECT email, COUNT(*)
FROM student s
JOIn "user" u ON u.user_id = s.student_id
GROUP BY email
HAVING COUNT(*) > 1;

-- Expect: 0 rows

-- Check that lab_event.due_datetime is always after start_datetime
SELECT event_id, start_datetime, due_datetime
FROM lab_event
WHERE due_datetime < start_datetime;

-- Expect: 0 rows

-- Check that instructor_assessment and self_assessment are within 0–100
SELECT progress_id, instructor_assessment, self_assessment
FROM progress
WHERE instructor_assessment NOT BETWEEN 0 AND 100
   OR self_assessment NOT BETWEEN 0 AND 100;

-- Expect: 0 rows

-------------------------------------------------------------------
-- 8. Join examples (verification of relationships)
-------------------------------------------------------------------

-- Example: Students with their course and lab event info
SELECT s.student_id, u.first_name, u.last_name,
       c.course_code, e.event_id, e.start_datetime, p.status
FROM student s
JOIN "user" u ON u.user_id = s.student_id
JOIN progress p ON s.student_id = p.student_id
JOIN lab_event e ON p.event_id = e.event_id
JOIN course c ON e.course_code = c.course_code
ORDER BY s.student_id, e.event_id;

-- Example: Change history summary
SELECT p.progress_id, COUNT(c.change_id) AS change_count,
       STRING_AGG(c.field || ' (' || c.old_value || '→' || c.new_value || ')', '; ') AS changes
FROM progress p
LEFT JOIN change_log c ON p.progress_id = c.progress_id
GROUP BY p.progress_id
ORDER BY change_count DESC;

-------------------------------------------------------------------
-- 9. Idempotency check (re-run safety)
-------------------------------------------------------------------

-- Verify schema re-runs without duplicate errors
-- Expected: No conflicts when you DROP + CREATE schema again
SELECT 'Re-run schema successfully to confirm idempotency' AS message;


--Test to insert a non-existent student
--INSERT INTO progress(progress_id, student_id, event_id, lab_number)
--VALUES ('A001-L01-L03', '123456789', 'L01-L01', '1');
-- ERROR:  insert or update on table "progress" violates foreign key constraint "progress_student_id_fkey"
--Key (student_id)=(123456789) is not present in table "student".
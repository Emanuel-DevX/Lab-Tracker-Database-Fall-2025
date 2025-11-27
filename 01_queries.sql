-- =============================================
-- Author: Group 16
-- Create date: 2025-11-20
-- Description: Part 1 - Guided Core Queries
-- =============================================

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- 1. Upcoming Lab Events – term 202530 (Fall 2025)
-- List all lab_event rows for term 202530, showing: section_id, set name, course code, lab_assignment title, lab_event date.
-------------------------------------------------------------------

SELECT
    le.section_code section_id,
    sec.set_code set_name,
    le.course_code course_code,
    la.title lab_assignment_title,
    le.start_datetime lab_event_date
FROM lab_event le
JOIN section sec
ON le.section_code = sec.section_code
JOIN lab_assignment la
ON la.lab_number  = le.lab_number
AND la.course_code = le.course_code
AND la.term_code   = le.term_code
WHERE le.term_code = '202530'

-------------------------------------------------------------------
-- 2. Student Participation Summary
-- For each student, show how many lab events they attended (attendance = 'Present') based on progress.
-------------------------------------------------------------------

SELECT
    s.student_id,
    u.first_name student_first_name,
    u.last_name student_last_name,
    COUNT(*)
FROM student s
JOIN "user" u
ON u.user_id = s.student_id
LEFT JOIN progress p
ON p.student_id = s.student_id
WHERE p.attendance = 'Present'
GROUP BY s.student_id, u.first_name, u.last_name

-------------------------------------------------------------------
-- 3. Late Submissions
-- List students who submitted late at least once (late = TRUE), showing their set, section, and count of late submissions.
-------------------------------------------------------------------

SELECT
    s.student_id,
    u.first_name student_first_name,
	u.last_name student_last_name,
    s.set_code,
    le.section_code,
    COUNT(*) late_submission_count
FROM progress p
JOIN student s
ON p.student_id = s.student_id
JOIN "user" u
ON u.user_id = s.student_id
JOIN lab_event le
ON p.event_id = le.event_id
WHERE p.late = TRUE
GROUP BY
    s.student_id,
    u.first_name, u.last_name,
    s.set_code,
    le.section_code
HAVING COUNT(*) > 0

-------------------------------------------------------------------
-- 4. Instructor Assessment Report
-- For each section, show the average instructor_assessment score across all progress records tied to that section’s lab events.
-------------------------------------------------------------------

SELECT
    c.course_code course,
    s.section_code "section",
    ROUND(AVG(p.instructor_assessment), 2) AS avg_instructor_assessment
FROM course c
JOIN section s
ON s.course_code = c.course_code
LEFT JOIN lab_event le
ON le.section_code = s.section_code
LEFT JOIN progress p
ON p.event_id = le.event_id
GROUP BY s.section_code, c.course_code
ORDER BY s.section_code

-------------------------------------------------------------------
-- 5. Unassessed Progress
-- List progress rows where instructor_assessment IS NULL or self_assessment IS NULL, including student name, section, and lab_event.
-------------------------------------------------------------------

SELECT
    p.progress_id,
    p.student_id,
    u.first_name student_first_name,
    u.last_name student_last_name,
    le.section_code "section",
    le.event_id lab_assignment_id,
    la.title lab_assignment_title,
    p.instructor_assessment,
    p.self_assessment
FROM progress p
JOIN student s
ON s.student_id = p.student_id
JOIN "user" u
ON u.user_id = s.student_id
JOIN lab_event le
ON le.event_id = p.event_id
JOIN lab_assignment la
ON la.lab_number  = p.lab_number
AND la.course_code = le.course_code
AND la.term_code   = le.term_code
WHERE p.instructor_assessment IS NULL
OR p.self_assessment IS NULL

-------------------------------------------------------------------
-- 6. Top Performers
-- Find top students whose average instructor_assessment is ≥ 4.5, including their set and course/section info.
-- Our seed data has student scores out of 10, so their score is divided by 2 to get a score out of 5.
-------------------------------------------------------------------

SELECT
    s.student_id,
    u.first_name student_first_name,
	u.last_name student_last_name,
    s.set_code,
    ROUND(AVG(p.instructor_assessment) / 2, 2) AS avg_instructor_assessment,
    e.course_code,
    e.section_code
FROM student s
JOIN "user" u
ON u.user_id = s.student_id
JOIN progress p
ON p.student_id = s.student_id
JOIN lab_event e
ON e.event_id = p.event_id
WHERE p.instructor_assessment IS NOT NULL
GROUP BY
    s.student_id,
    u.first_name,
    u.last_name,
    s.set_code,
    e.course_code,
    e.section_code
HAVING AVG(p.instructor_assessment) / 2 >= 4.5
ORDER BY avg_instructor_assessment DESC

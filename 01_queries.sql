-------------------------------------------------------------------
-- 01_queries.sql
-- Lab Tracker Group 16 – Core Reporting Queries (Part 1)
-- Schema: lab_tracker_group_16
-------------------------------------------------------------------

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- 1. Upcoming Lab Events – term 202530 (Fall 2025)
-- Question:
--  "List all lab_event rows for term 202530, showing:
--   section_id, set name, course code, lab_assignment title, lab_event date."
-------------------------------------------------------------------

SELECT 
    le.section_code AS section_id,
    sec.set_code    AS set_name,
    le.course_code,
    la.title        AS lab_assignment_title,
    le.start_datetime::date AS lab_event_date
FROM lab_event      AS le
JOIN section        AS sec
  ON le.section_code = sec.section_code
JOIN lab_assignment AS la
  ON la.lab_number  = le.lab_number
 AND la.course_code = le.course_code
 AND la.term_code   = le.term_code
WHERE le.term_code = '202530'
ORDER BY le.section_code, le.start_datetime;

-------------------------------------------------------------------
-- 2. Student Participation Summary
-- Question:
--  "For each student, show how many lab events they attended
--   (attendance = 'Present') based on progress."
-------------------------------------------------------------------

SELECT 
    s.student_id,
    u.first_name || ' ' || u.last_name AS student_full_name,
    COUNT(*) FILTER (WHERE p.attendance = 'Present') AS attended_events,
    COUNT(p.progress_id) AS total_events
FROM student s
JOIN "user" u
  ON u.user_id = s.student_id
LEFT JOIN progress p
  ON p.student_id = s.student_id
GROUP BY s.student_id, u.first_name, u.last_name
ORDER BY attended_events DESC, s.student_id;

-------------------------------------------------------------------
-- 3. Late Submissions
-- Question:
--  "List students who submitted late at least once (late = TRUE),
--   showing their set, section, and count of late submissions."
-------------------------------------------------------------------

SELECT 
    s.student_id,
    u.first_name || ' ' || u.last_name AS student_full_name,
    s.set_code,
    le.section_code,
    COUNT(*) AS late_submission_count
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
ORDER BY late_submission_count DESC, s.student_id;

-------------------------------------------------------------------
-- 4. Instructor Assessment Report
-- Question:
--  "For each section, show the average instructor_assessment score
--   across all progress records tied to that section’s lab events."
-------------------------------------------------------------------

SELECT 
    sec.section_code,
    t.term_code,
    c.course_code,
    COUNT(p.progress_id) AS total_submissions,
    ROUND(AVG(p.instructor_assessment), 2) AS avg_instructor_assessment,
    MIN(p.instructor_assessment) AS lowest_score,
    MAX(p.instructor_assessment) AS highest_score
FROM section sec
JOIN course c
  ON sec.course_code = c.course_code
JOIN term t
  ON sec.term_code = t.term_code
LEFT JOIN lab_event le
  ON le.section_code = sec.section_code
LEFT JOIN progress p
  ON p.event_id = le.event_id
GROUP BY sec.section_code, t.term_code, c.course_code
ORDER BY avg_instructor_assessment DESC NULLS LAST;

-------------------------------------------------------------------
-- 5. Unassessed Progress
-- Question:
--  "List progress rows where instructor_assessment IS NULL
--   or self_assessment IS NULL, including student name,
--   section, and lab_event."
-------------------------------------------------------------------

SELECT 
    p.progress_id,
    p.student_id,
    u.first_name || ' ' || u.last_name AS student_full_name,
    le.section_code,
    le.event_id,
    la.title AS lab_assignment_title,
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
   OR p.self_assessment      IS NULL
ORDER BY le.start_datetime DESC, p.student_id;

-------------------------------------------------------------------
-- 6. Top Performers
-- Question:
--  "Find top students whose average instructor_assessment is ≥ 4.5,
--   including their set and course/section info."
--
-- Approach:
--   1) Compute overall average per student in a CTE.
--   2) Filter to avg >= 4.5 (top students).
--   3) Join to lab_event + section to list sections/courses
--      where those top students appear.
-------------------------------------------------------------------

WITH student_avgs AS (
    SELECT
        s.student_id,
        u.first_name || ' ' || u.last_name AS student_full_name,
        s.set_code,
        AVG(p.instructor_assessment) AS avg_instructor_assessment
    FROM student s
    JOIN "user" u
      ON u.user_id = s.student_id
    JOIN progress p
      ON p.student_id = s.student_id
    WHERE p.instructor_assessment IS NOT NULL
    GROUP BY s.student_id, u.first_name, u.last_name, s.set_code
    HAVING AVG(p.instructor_assessment) >= 4.5
)
SELECT DISTINCT
    sa.student_id,
    sa.student_full_name,
    sa.set_code,
    ROUND(sa.avg_instructor_assessment, 2) AS avg_instructor_assessment,
    e.course_code,
    e.section_code
FROM student_avgs sa
JOIN progress p
  ON p.student_id = sa.student_id
JOIN lab_event e
  ON e.event_id = p.event_id
ORDER BY avg_instructor_assessment DESC,
         sa.student_id,
         e.course_code,
         e.section_code;

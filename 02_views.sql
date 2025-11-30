-- =============================================
-- Author: Group 16
-- Create date: 2025-11-20
-- Description: Part 2 - Views for Role-Based Access
-- =============================================

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- TA View – v_ta_progress_summary
-------------------------------------------------------------------

DROP VIEW IF EXISTS v_ta_progress_summary CASCADE;

CREATE VIEW v_ta_progress_summary AS
SELECT
    le.section_code section_id,
    le.event_id lab_event_id,
    p.student_id,
    u.first_name student_first_name,
    u.last_name student_last_name,
    p.attendance,
    p.inlab_submission_link in_lab_submission_link,
    p.instructor_assessment
FROM progress p
JOIN lab_event le
ON p.event_id = le.event_id
JOIN student s
ON p.student_id = s.student_id
JOIN "user" u
ON u.user_id = s.student_id;

-- Example SELECT 1: 10 sample rows
SELECT *
FROM v_ta_progress_summary
LIMIT 10;

-- Example SELECT 2: view for one section
SELECT *
FROM v_ta_progress_summary
WHERE section_id = 'L01';

-------------------------------------------------------------------
-- Reporting View – v_section_overview
-------------------------------------------------------------------

DROP VIEW IF EXISTS v_section_overview CASCADE;

CREATE VIEW v_section_overview AS
SELECT
    t.term_code,
    sec.set_code set_name,
    sec.course_code,
    sec.section_code section_id,
    COUNT(DISTINCT le.event_id) total_events,
    ROUND(AVG(p.instructor_assessment), 2) avg_instructor_assessment
FROM section sec
JOIN term t
ON t.term_code = sec.term_code
JOIN set st
ON st.set_code = sec.set_code
LEFT JOIN lab_event le
ON le.section_code = sec.section_code
LEFT JOIN progress p
ON p.event_id = le.event_id
GROUP BY
    t.term_code,
    sec.set_code,
    sec.course_code,
    sec.section_code;

-- Example SELECT 1: all sections
SELECT *
FROM v_section_overview
ORDER BY term_code, set_name, section_id;

-- Example SELECT 2: just Fall 2025 sections
SELECT *
FROM v_section_overview
WHERE term_code = '202530'
ORDER BY set_name, section_id;

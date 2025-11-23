-------------------------------------------------------------------
-- 02_views.sql
-- Lab Tracker Group 16 – Views for Role-Based Access (Part 2)
-------------------------------------------------------------------

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- View 1: v_ta_progress_summary
--
-- Required columns:
--   section_id,
--   lab_event_id,
--   student_id,
--   student_full_name,
--   attendance,
--   in_lab_submission_link,
--   instructor_assessment
--
-- Purpose:
--   TAs can see current progress without seeing more sensitive
--   columns like self_assessment or polished_submission_link.
-------------------------------------------------------------------

DROP VIEW IF EXISTS v_ta_progress_summary CASCADE;

CREATE VIEW v_ta_progress_summary AS
SELECT 
    le.section_code AS section_id,
    le.event_id     AS lab_event_id,
    p.student_id,
    u.first_name || ' ' || u.last_name AS student_full_name,
    p.attendance,
    p.inlab_submission_link AS in_lab_submission_link,
    p.instructor_assessment
FROM progress p
JOIN lab_event le
  ON p.event_id = le.event_id
JOIN student s
  ON p.student_id = s.student_id
JOIN "user" u
  ON u.user_id = s.student_id;

-- Example SELECT 1: sample rows
SELECT *
FROM v_ta_progress_summary
ORDER BY section_id, lab_event_id, student_id
LIMIT 10;

-- Example SELECT 2: TA view for one section
SELECT *
FROM v_ta_progress_summary
WHERE section_id = 'L01'
ORDER BY lab_event_id, student_id;

-------------------------------------------------------------------
-- View 2: v_section_overview
--
-- Required columns:
--   term_code,
--   set_name,
--   course_code,
--   section_id,
--   total_events,
--   avg_instructor_assessment
--
-- Purpose:
--   Reporting view that aggregates per section across its lab_events
--   and progress rows.
-------------------------------------------------------------------

DROP VIEW IF EXISTS v_section_overview CASCADE;

CREATE VIEW v_section_overview AS
SELECT
    t.term_code,
    sec.set_code     AS set_name,
    sec.course_code,
    sec.section_code AS section_id,
    COUNT(DISTINCT le.event_id) AS total_events,
    AVG(p.instructor_assessment) AS avg_instructor_assessment
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

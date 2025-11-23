-------------------------------------------------------------------
-- 04_procedural.sql
-- Lab Tracker Group 16 – Procedural Automation (Part 4)
-------------------------------------------------------------------

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- 4A. Trigger – Log Changes to progress (student_progress)
--
-- Spec table name: change_log
-- Our schema:
--   - progress.progress_id is VARCHAR(20)
--   - we already have progress_change_log; we LEAVE IT ALONE
--   - new change_log is specifically for this milestone trigger
-------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS change_log (
    change_id SERIAL PRIMARY KEY,
    progress_id VARCHAR(20) NOT NULL,
    changed_by TEXT,
    action TEXT NOT NULL,  -- e.g. 'INSERT', 'UPDATE'
    old_instructor_assessment NUMERIC,
    new_instructor_assessment NUMERIC,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_change_progress
        FOREIGN KEY (progress_id)
        REFERENCES progress(progress_id)
);

-------------------------------------------------------------------
-- Trigger function: fn_log_progress_change
-- Behavior:
--   - On INSERT: log a row with action = 'INSERT'
--   - On UPDATE: log only if instructor_assessment actually changed,
--                with action = 'UPDATE'
--   - changed_by uses current_user to capture DB user.
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_log_progress_change() CASCADE;

CREATE FUNCTION fn_log_progress_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO change_log(
            progress_id,
            changed_by,
            action,
            old_instructor_assessment,
            new_instructor_assessment,
            changed_at
        )
        VALUES (
            NEW.progress_id,
            current_user,
            'INSERT',
            NULL,
            NEW.instructor_assessment,
            CURRENT_TIMESTAMP
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.instructor_assessment IS DISTINCT FROM OLD.instructor_assessment THEN
            INSERT INTO change_log(
                progress_id,
                changed_by,
                action,
                old_instructor_assessment,
                new_instructor_assessment,
                changed_at
            )
            VALUES (
                NEW.progress_id,
                current_user,
                'UPDATE',
                OLD.instructor_assessment,
                NEW.instructor_assessment,
                CURRENT_TIMESTAMP
            );
        END IF;
        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$;

-------------------------------------------------------------------
-- Attach trigger to progress table
-------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_log_progress_change ON progress;

CREATE TRIGGER trg_log_progress_change
AFTER INSERT OR UPDATE ON progress
FOR EACH ROW
EXECUTE FUNCTION fn_log_progress_change();

-------------------------------------------------------------------
-- Test block for 4A (commented to keep script idempotent)
--
-- -- Clear previous logs (optional during testing)
-- TRUNCATE TABLE change_log;
--
-- -- Insert new progress row → should log INSERT
-- INSERT INTO progress (
--     progress_id, student_id, event_id, lab_number,
--     status, prepared, attendance, instructor_assessment
-- )
-- VALUES (
--     'TEST-PROG-01', 'A001', 'L01-L01', '1',
--     'Submitted', TRUE, 'Present', 7.5
-- );
--
-- -- Update assessment → should log UPDATE
-- UPDATE progress
-- SET instructor_assessment = 8.5
-- WHERE progress_id = 'TEST-PROG-01';
--
-- SELECT * FROM change_log
-- WHERE progress_id = 'TEST-PROG-01'
-- ORDER BY changed_at;
--
-- -- Cleanup
-- DELETE FROM progress    WHERE progress_id = 'TEST-PROG-01';
-- DELETE FROM change_log  WHERE progress_id = 'TEST-PROG-01';
-------------------------------------------------------------------


-------------------------------------------------------------------
-- 4B. Stored Function – Create Lab Event and Precreate Progress
--
-- Function: fn_create_lab_event_for_section
--
-- Inputs:
--   p_section_code    VARCHAR    e.g. 'L01'
--   p_assignment_id   CHAR(6)    e.g. 'LAB04'
--   p_start_datetime  TIMESTAMP  actual lab start
--   p_end_datetime    TIMESTAMP  actual lab end
--   p_due_datetime    TIMESTAMP  due date/time
--
-- Behavior:
--   1) Look up course_code, term_code, lab_number from lab_assignment.
--   2) Look up set_code and location from section (by section_code).
--   3) Build event_id as section_code || '-' || lab_number
--      e.g. 'L01-04' for section L01, lab_number '4'.
--   4) Insert into lab_event (if not already there).
--   5) For each student in that set_code, insert a progress row
--      with default values:
--        - status = 'In Progress'
--        - prepared = FALSE
--        - attendance = 'Absent'
--        - late = FALSE
--        - all links and assessments = NULL
--   6) Return the new event_id (CHAR(7)) to the caller.
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_create_lab_event_for_section(
    VARCHAR, CHAR(6), TIMESTAMP, TIMESTAMP, TIMESTAMP
) CASCADE;

CREATE FUNCTION fn_create_lab_event_for_section(
    p_section_code     VARCHAR,
    p_assignment_id    CHAR(6),
    p_start_datetime   TIMESTAMP,
    p_end_datetime     TIMESTAMP,
    p_due_datetime     TIMESTAMP
)
RETURNS CHAR(7)
LANGUAGE plpgsql
AS $$
DECLARE
    v_course_code   CHAR(8);
    v_term_code     VARCHAR(10);
    v_lab_number    CHAR(2);
    v_location      VARCHAR(50);
    v_set_code      CHAR(1);
    v_event_id      CHAR(7);
    v_student_id    CHAR(20);
BEGIN
    -- 1) Get info from lab_assignment
    SELECT course_code, term_code, lab_number
    INTO v_course_code, v_term_code, v_lab_number
    FROM lab_assignment
    WHERE assignment_id = p_assignment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lab assignment % does not exist', p_assignment_id;
    END IF;

    -- 2) Get section info (set + location)
    SELECT set_code, location
    INTO v_set_code, v_location
    FROM section
    WHERE section_code = p_section_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Section % does not exist', p_section_code;
    END IF;

    -- 3) Build event_id like existing pattern: 'L01-01', 'L01-02', ...
    v_event_id := p_section_code || '-' || v_lab_number;

    -- 4) Insert lab_event row (idempotent)
    INSERT INTO lab_event (
        event_id,
        section_code,
        course_code,
        term_code,
        lab_number,
        start_datetime,
        end_datetime,
        due_datetime,
        location
    )
    VALUES (
        v_event_id,
        p_section_code,
        v_course_code,
        v_term_code,
        v_lab_number,
        p_start_datetime,
        p_end_datetime,
        p_due_datetime,
        v_location
    )
    ON CONFLICT (event_id) DO NOTHING;

    -- 5) Pre-create progress rows for all students in that set
    FOR v_student_id IN
        SELECT student_id
        FROM student
        WHERE set_code = v_set_code
    LOOP
        INSERT INTO progress (
            progress_id,
            student_id,
            event_id,
            lab_number,
            status,
            prepared,
            attendance,
            inlab_submitted_at,
            inlab_submission_link,
            polished_submitted_at,
            polished_submission_link,
            instructor_assessment,
            self_assessment,
            late
        )
        VALUES (
            v_student_id || '-' || v_event_id,
            v_student_id,
            v_event_id,
            v_lab_number,
            'In Progress',
            FALSE,
            'Absent',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            FALSE
        )
        ON CONFLICT (student_id, event_id) DO NOTHING;
    END LOOP;

    RETURN v_event_id;
END;
$$;

-------------------------------------------------------------------
-- Test block for 4B (commented)
--
-- -- Example: create a LAB04 event for section L01 (Fall 2025)
-- SELECT fn_create_lab_event_for_section(
--     'L01',
--     'LAB04',
--     TIMESTAMP '2025-10-06 09:30',
--     TIMESTAMP '2025-10-06 11:20',
--     TIMESTAMP '2025-10-12 23:59'
-- );
--
-- -- Verify lab_event row:
-- SELECT * FROM lab_event
-- WHERE section_code = 'L01' AND lab_number = '4';
--
-- -- Verify progress rows:
-- SELECT *
-- FROM progress
-- WHERE event_id LIKE 'L01-%' AND lab_number = '4'
-- ORDER BY student_id;
-------------------------------------------------------------------

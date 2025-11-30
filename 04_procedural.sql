-- =============================================
-- Author: Group 16
-- Create date: 2025-11-20
-- Description: Part 4 – Procedural Automation
-- =============================================

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- 4A. Trigger – Log Changes to progress (student_progress)
-------------------------------------------------------------------
-------------------------------------------------------------------
-- 1. Create table change_log if it does not exist
--
-- Current schema already has progress_change_log table
-- New change_log table created specifically for this trigger demonstration
-------------------------------------------------------------------

DROP TABLE IF EXISTS change_log CASCADE;

CREATE TABLE change_log (
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
-- 2. Create a trigger function fn_log_progress_change()
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
-- 3. Create a trigger trg_log_progress_change on student_progress
-------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_log_progress_change ON progress;

CREATE TRIGGER trg_log_progress_change
AFTER INSERT OR UPDATE ON progress
FOR EACH ROW
EXECUTE FUNCTION fn_log_progress_change();

-------------------------------------------------------------------
-- 4. Testing for 4A
-------------------------------------------------------------------

TRUNCATE TABLE change_log;

INSERT INTO progress (
    progress_id, student_id, event_id, lab_number,
    status, prepared, attendance, instructor_assessment
)
VALUES (
    'TEST-PROG-01', 'A001', 'L06-L01', '1',
    'Submitted', TRUE, 'Present', 7.5
);

UPDATE progress
SET instructor_assessment = 8.5
WHERE progress_id = 'TEST-PROG-01';

SELECT * FROM change_log
WHERE progress_id = 'TEST-PROG-01'
ORDER BY changed_at;

DELETE FROM change_log  WHERE progress_id = 'TEST-PROG-01';
DELETE FROM progress    WHERE progress_id = 'TEST-PROG-01';

-------------------------------------------------------------------
-- 4B. Stored Function – Create Lab Event and Precreate Progress
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Inserts a new row into lab_event for that section and lab assignment and captures lab_event_id.
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS fn_create_lab_event_for_section(VARCHAR, CHAR(6), TIMESTAMP, TIMESTAMP, TIMESTAMP) CASCADE;

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
    -- Get info from lab_assignment
    SELECT course_code, term_code, lab_number
    INTO v_course_code, v_term_code, v_lab_number
    FROM lab_assignment
    WHERE assignment_id = p_assignment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lab assignment % does not exist', p_assignment_id;
    END IF;

    -- Get section info
    SELECT set_code, location
    INTO v_set_code, v_location
    FROM section
    WHERE section_code = p_section_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Section % does not exist', p_section_code;
    END IF;

    -- Build event_id like 'L01-01', 'L01-02', etc.
    v_event_id := p_section_code || '-' || v_lab_number;

    -- Insert lab_event row
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

    -- Create progress rows for all students in that set
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
    -- Returns the new lab_event_id.
    RETURN v_event_id;
END;
$$;

-------------------------------------------------------------------
-- Testing for 4B
-------------------------------------------------------------------

SELECT fn_create_lab_event_for_section(
    'L01',
    'LAB04',
    TIMESTAMP '2025-10-06 09:30',
    TIMESTAMP '2025-10-06 11:20',
    TIMESTAMP '2025-10-12 23:59'
);

SELECT * FROM lab_event
WHERE section_code = 'L01' AND lab_number = '4';

SELECT *
FROM progress
WHERE event_id LIKE 'L01-%' AND lab_number = '4'
ORDER BY student_id;

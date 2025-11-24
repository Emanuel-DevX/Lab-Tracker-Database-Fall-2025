-------------------------------------------------------------------
-- 05_transaction_demo.sql
-- Lab Tracker Group 16 – Transaction Demo (Part 5)
-------------------------------------------------------------------

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- Successful transaction
--
-- Scenario:
--   Student submits work (updates links) and instructor assigns
--   a grade. We want both updates to succeed together or not at all.
-------------------------------------------------------------------

BEGIN;

UPDATE progress
SET inlab_submission_link    = 'https://example.com/submissions/A001-L01-L01',
    polished_submission_link = 'https://example.com/submissions/A001-L01-L01-polished'
WHERE progress_id = 'A001-L01-L01';

UPDATE progress
SET instructor_assessment = 9.5
WHERE progress_id = 'A001-L01-L01';

COMMIT;

-- Verification:
-- SELECT progress_id, inlab_submission_link,
--        polished_submission_link, instructor_assessment
-- FROM progress
-- WHERE progress_id = 'A001-L01-L01';

-------------------------------------------------------------------
-- Failing transaction
--
-- Scenario 1 (demonstrating constraint failure):
--   Attempt to insert a change_log row that violates the FK
--   (non-existent progress_id). Postgres will raise an error,
--   and we ROLLBACK.
-------------------------------------------------------------------

BEGIN;

-- This will fail because 'NON_EXISTENT_PROG' is not a valid progress_id:
INSERT INTO change_log (
    progress_id,
    changed_by,
    action,
    old_instructor_assessment,
    new_instructor_assessment
)
VALUES (
    'NON_EXISTENT_PROG',
    current_user,
    'UPDATE',
    8.0,
    9.0
);

-- On error, the transaction is marked aborted and we must ROLLBACK.
ROLLBACK;

-- Verification: should return 0 rows
-- SELECT *
-- FROM change_log
-- WHERE progress_id = 'NON_EXISTENT_PROG';

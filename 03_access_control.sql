-------------------------------------------------------------------
-- 03_access_control.sql
-- Lab Tracker Group 16 – Access Control (Part 3)
--
-- NOTE:
--   On the shared BCIT Postgres server, CREATE ROLE / CREATE USER
--   may fail with "permission denied". Keep these statements anyway.
-------------------------------------------------------------------

SET search_path TO lab_tracker_group_16;


-------------------------------------------------------------------
-- Create TA role if it does not already exist
-------------------------------------------------------------------

-- DROP ROLE IF EXISTS ta_role;

-- CREATE ROLE ta_role;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'ta_role'
    ) THEN
        CREATE ROLE ta_role;
    END IF;
END;
$$;


-------------------------------------------------------------------
-- Grant SELECT on reporting views to TA role
-------------------------------------------------------------------

GRANT SELECT ON v_ta_progress_summary TO ta_role;
GRANT SELECT ON v_section_overview    TO ta_role;

-------------------------------------------------------------------
-- Sample TA user (may fail on shared server)
-------------------------------------------------------------------

-- These lines may error if you cannot create users; that is expected.
DO $$
BEGIN
    BEGIN
        CREATE USER ta_demo WITH PASSWORD 'ta_demo123';
    EXCEPTION WHEN duplicate_object THEN
        -- user already exists, ignore
        NULL;
    END;
END;
$$;

GRANT ta_role TO ta_demo;

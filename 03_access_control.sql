-- =============================================
-- Author: Group 16
-- Create date: 2025-11-20
-- Description: Part 3 – Access Control
-- =============================================

SET search_path TO lab_tracker_group_16;

-------------------------------------------------------------------
-- Create a TA role
-------------------------------------------------------------------

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
-- Grant SELECT ON v_ta_progress_summary, v_section_overview TO ta_role;
-------------------------------------------------------------------

GRANT SELECT ON v_ta_progress_summary TO ta_role;
GRANT SELECT ON v_section_overview TO ta_role;

-------------------------------------------------------------------
-- Create user ta_demo with password 'ta_demo123' (must be allowed on server)
-------------------------------------------------------------------

DO $$
BEGIN
    BEGIN
        CREATE USER ta_demo WITH PASSWORD 'ta_demo123';
    EXCEPTION WHEN duplicate_object THEN
        -- if user already exists, ignore
        NULL;
    END;
END;
$$;

-------------------------------------------------------------------
-- Grant ta_role to ta_demo;
-------------------------------------------------------------------

GRANT ta_role TO ta_demo;

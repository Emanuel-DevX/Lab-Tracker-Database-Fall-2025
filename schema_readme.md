# Lab Tracker Database – Fall 2025  
**Group 16:** Jimmy Cho, Emanuel Molla, Anthony Herradura, Allen Rosales  
**Course:** COMP 2714 – Relational Database Systems  

---

## Purpose
This database implements the **Lab Tracker** logical model in PostgreSQL.  
It stores information about courses, terms, student sets, sections, lab assignments, lab events, student progress, and audit logs.  
The schema validates all key relationships and supports future milestones involving queries, views, and transactions.

---

## Scope & Entities
- **User** – All actors (students, instructors, TAs, system).  
- **Student** – Subtype of User linked to a Set (A–F).  
- **Set** – Cohort of students per campus.  
- **Course** – Course code, title, credits.  
- **Term** – Semester identifier and dates.  
- **Section** – Lab section for one course, term, and set.  
- **Lab Assignment** – Reusable lab definitions.  
- **Lab Event** – Scheduled session with timestamps and location.  
- **Progress** – Student’s status per event (submission, attendance, grades).  
- **Progress Change Log** – Audit trail recording who changed what and when.

---

## Design Summary
- **Primary Keys:**  
  Natural codes used (e.g., `course_code`, `term_code`, `section_code`);  
  surrogate IDs (`progress_id`, `change_id`) where needed.  
- **Foreign Keys:**  
  Enforce 1-to-many and subtype links (`student.student_id → user.user_id`).  
  `ON DELETE CASCADE` used only where child data should auto-remove.  
- **Constraints:**  
  - `CHECK` for valid status and attendance values.  
  - `UNIQUE` on emails and `(student_id, event_id)` pairs.  
  - `NOT NULL` on required attributes.  
- **Data Types:**  
  `VARCHAR` for codes/text, `BOOLEAN` for flags, `DECIMAL(4,2)` for grades, `TIMESTAMP` for dates/times.  
- **Normalization:**  
  Fully 3NF; redundancy removed by treating Student as User subtype.

---

## Referential Integrity
- Each Section → exactly one Course, Term, and Set.  
- Each Lab Event → exactly one Section (and thus one Set).  
- Each Progress → existing Student and Event.  
- Each Change Log → existing Progress and User.  

---

## Idempotency & Testing
Schema rebuilds safely via:  
`DROP SCHEMA IF EXISTS lab_tracker_group_16 CASCADE;`  
Sample data (5–10 rows per table) validates FKs and constraints.  
Test queries confirm no orphans and proper key enforcement.

---

## Tools & Environment
PostgreSQL 16 • pgAdmin ERD • VS Code SQL Tools Extension  

---

# Lab-Tracker-Database-Fall-2025-
by Jimmy Cho, Emanuel Molla, 

## The database keeps track of:
### - Course
### - Student
### - Set 
(A–F cohort of students)
### - Term 
(e.g., 202530 for Fall 2025)
### - Section of a course 
(Lab sections only; each Lab Section is for exactly one Set)
### - Lab Assignments
### - Lab Events 
(scheduled meetings for a specific Section)
### - Student Progress per Lab Event 
(preparedness, attendance, in‑lab submission timestamp/link, polished submission timestamp/link, instructor_assessment, self_assessment, late flag)
### - Change Log for progress records 
(who changed what and when)

## Key business rules:
- Every Lab Section belongs to exactly one Course, one Term, and exactly one Set.
- Every Lab Event belongs to exactly one Lab Section (and therefore to one Set indirectly).
- Progress references an existing Student and Lab Event.
- Change Log references an existing Progress and User (the actor making the change).

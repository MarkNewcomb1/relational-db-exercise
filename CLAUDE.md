# Westfield University — SQL Learning Project

## Project purpose

This is a local PostgreSQL learning project. The goal is to build and query a realistic relational database for a mock university, focusing on understanding many-to-many relationships, JOIN patterns, aggregation, subqueries, and window functions. There is also a minimal frontend for visual exploration.

---

## What to build

### Database: Westfield University

Five tables with the following relationships:

- A **department** has many professors and many courses
- A **professor** belongs to one department and teaches many courses
- A **course** belongs to one department and has exactly one professor
- A **student** enrolls in many courses via the **enrollments** junction table
- A **professor** therefore has many students (indirectly, through courses)
- A **student** can have the same professor more than once across different courses

### Tables

```
departments
  id, name, code

professors
  id, first_name, last_name, email, department_id (FK), tenure_status

students
  id, first_name, last_name, email, major, enrollment_year, gpa

courses
  id, course_code, title, credits, department_id (FK), professor_id (FK), semester, max_capacity

enrollments  <-- junction table (many-to-many bridge)
  id, student_id (FK), course_id (FK), grade, enrolled_at
  UNIQUE(student_id, course_id)
```

---

## Files to generate

### `migration.sql`

PostgreSQL schema file. Should:

- Drop tables in safe order (enrollments first, then courses, then professors/students, then departments) using `CASCADE`
- Create all five tables with proper data types, constraints, and foreign keys
- Add indexes on all FK columns for query performance
- Be safe to re-run (idempotent)

### `seed.sql`

Mock data file. Should be run after `migration.sql`. Populate with:

- 5 departments: Computer Science, Mathematics, English Literature, Psychology, History
- 12 professors spread across departments, mix of tenured / tenure-track / adjunct
- 20 students with realistic names, declared majors, enrollment years, and GPAs
- 18 courses across two semesters (Fall 2024, Spring 2025)
- ~100 enrollments with grades

**Important:** seed the enrollments so that some students have the same professor more than once via different courses. This makes certain queries non-trivial and interesting. For example:
- A CS student enrolled in both CS301 and CS401, both taught by the same professor
- A Math student enrolled in MATH101 and MATH201, both taught by the same professor
- A Psychology student enrolled in PSYC101 and PSYC360, both taught by the same professor

Also seed some students who cross department lines (e.g. a CS major taking a History course).

### `frontend/` (optional, lightweight)

A minimal read-only frontend for browsing and querying the database. Keep it simple — the learning happens in SQL, not in the UI. Options:

- A single `index.html` with a query input and table output (no framework required)
- Or a small Node/Express app that proxies queries to Postgres and renders results
- Keep the color scheme simple: black text on a white background with the option of a Dark mode toggle that toggles the text and background colors

If building a frontend, enforce read-only access: block any query containing `ALTER`, `DROP`, `CREATE`, `INSERT`, `UPDATE`, `DELETE`, or `TRUNCATE`.

---

## SQL concepts to practice

Generate these as a `QUERIES.md` reference file alongside the SQL files. Each query should have a plain-English description and the SQL below it.

### Basic retrieval
- List all students ordered by GPA descending
- List all courses with their professor's name and department
- List all professors with their department name

### Single-hop joins
- All students enrolled in a specific course (e.g. CS301)
- All courses a specific student is enrolled in
- All courses taught by a specific professor

### Multi-hop joins (the interesting ones)
- All students a given professor has — directly or across multiple courses
- All professors a given student has had
- Whether a student has had the same professor more than once

### Aggregation
- How many students does each professor have? (`COUNT(DISTINCT student_id)`)
- How many courses is each student enrolled in?
- Average GPA by major
- Total enrollment count per department

### HAVING / filtering on aggregates
- Which students have had the same professor more than once? (GROUP BY student_id, professor_id HAVING COUNT(*) > 1)
- Which professors teach more than one course?
- Which courses have more than 10 enrolled students?

### Subqueries
- Students who are enrolled in at least one course outside their declared major's department
- Students who share at least one course with a given student

### Window functions
- Rank students by GPA within their major using `RANK() OVER (PARTITION BY major ORDER BY gpa DESC)`
- Running enrollment count per semester

---

## Running locally

```bash
# Create the database
createdb westfield

# Run migration
psql -d westfield -f migration.sql

# Seed data
psql -d westfield -f seed.sql

# Open psql to query interactively
psql -d westfield
```

---

## Notes and constraints

- Target PostgreSQL 14 or later
- Use `SERIAL` for primary keys (or `INTEGER GENERATED ALWAYS AS IDENTITY` — either is fine)
- Foreign key constraints should be enforced (no `DEFERRABLE` unless needed)
- The frontend, if built, should connect via a read-only Postgres role — create one in the migration or in a separate `setup_roles.sql`
- Keep the seed data realistic enough to make queries meaningful but small enough to read in full (20 students, 12 professors, 18 courses is the right scale)

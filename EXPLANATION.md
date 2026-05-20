# SQL Query Explanations

This file walks through every query in `QUERIES.md` and explains what it does, why it's written the way it is, and what database concepts it illustrates. The goal is not just to tell you what each query returns — it's to explain the reasoning so you can adapt the same patterns to new problems.

---

## A note on how relational databases work before we start

A relational database stores data split across multiple tables to avoid repetition. Instead of storing a professor's name in every row of the `courses` table, we store a `professor_id` that points to the `professors` table. This is called **normalization**, and it keeps data consistent — if a professor changes their name, you update one row, not hundreds.

The tradeoff is that to read a "complete" picture of something — a course with its professor's name and department — you have to *recombine* the tables at query time. That recombination is what JOINs do.

---

## Basic Retrieval

### List all students ordered by GPA descending

```sql
SELECT first_name, last_name, major, gpa
FROM students
ORDER BY gpa DESC;
```

**What it does:** Reads four columns from the `students` table and sorts the results highest-GPA-first.

**Why it's written this way:**

`SELECT` tells the database which columns you want back. Listing specific columns (`first_name, last_name, major, gpa`) rather than using `SELECT *` is a good habit — it makes the query's intent clear, avoids returning data you don't need, and protects against breakage if the table schema changes.

`ORDER BY gpa DESC` sorts the result set. `DESC` means descending (highest first). The default sort direction is `ASC` (ascending), so without it you'd get lowest GPA first.

**No JOIN needed here** because everything we want lives in one table.

---

### List all courses with their professor's name and department

```sql
SELECT
    c.course_code,
    c.title,
    c.semester,
    c.credits,
    p.first_name || ' ' || p.last_name AS professor,
    d.name AS department
FROM courses c
JOIN professors p ON c.professor_id = p.id
JOIN departments d ON c.department_id = d.id
ORDER BY d.name, c.course_code;
```

**What it does:** Returns a list of courses, each row enriched with the professor's full name and the department name.

**Why it's written this way:**

The `courses` table only stores `professor_id` and `department_id` — integer foreign keys. To get the human-readable name for either, you need to look them up in the `professors` and `departments` tables. That's what the two JOINs do.

`JOIN professors p ON c.professor_id = p.id` — for each course row, find the professors row where the professor's `id` matches the course's `professor_id`. The `p` and `c` are **aliases** — shorthand so you don't have to type the full table name every time you reference a column.

`JOIN departments d ON c.department_id = d.id` — same idea, but for the department.

`p.first_name || ' ' || p.last_name AS professor` — the `||` operator concatenates strings in PostgreSQL. This glues first name, a space, and last name together into a single column. `AS professor` gives the result a readable column name in the output.

The two JOINs here are **independent** — they don't chain off each other, they both extend the same base `courses` row. This is common when a table has multiple foreign keys.

---

### List all professors with their department name

```sql
SELECT
    p.first_name || ' ' || p.last_name AS professor,
    p.tenure_status,
    d.name AS department
FROM professors p
JOIN departments d ON p.department_id = d.id
ORDER BY d.name, p.last_name;
```

**What it does:** Lists every professor alongside their department name, sorted by department then last name.

**Why it's written this way:**

This is the simplest possible JOIN pattern — one table (professors) joined to one lookup table (departments). Each professor belongs to exactly one department, so each professor row produces exactly one output row.

`ORDER BY d.name, p.last_name` sorts on two columns. The first column (`d.name`) is the primary sort key; `p.last_name` is the tiebreaker within each department. This produces grouped, alphabetical output without needing a `GROUP BY`.

---

## Single-Hop Joins

A "single hop" means the relationship between the two things you care about is direct — one JOIN bridges them. These queries all go through the `enrollments` junction table, which is the bridge between students and courses.

### All students enrolled in a specific course (CS301)

```sql
SELECT
    s.first_name || ' ' || s.last_name AS student,
    s.major,
    e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c  ON e.course_id  = c.id
WHERE c.course_code = 'CS301'
ORDER BY s.last_name;
```

**What it does:** Returns every student in CS301 along with their major and grade.

**Why it's written this way:**

The `enrollments` table is the many-to-many bridge between students and courses. You can't go directly from `courses` to `students` — the relationship only exists through `enrollments`.

The query starts `FROM enrollments e` because that's where the relationship lives. It then JOINs outward in both directions: to `students` (to get names) and to `courses` (to filter by course code).

Notice that we join to `courses` even though we could theoretically filter by `course_id` directly (since we know CS301's ID). Filtering by `course_code` is safer and more readable — IDs are implementation details that can change; the course code is the meaningful identifier. The JOIN to `courses` exists purely to support that `WHERE` clause.

`WHERE c.course_code = 'CS301'` runs *after* the JOINs are computed. The database first builds the combined rows (enrollments + students + courses), then discards every row that isn't CS301.

---

### All courses a specific student is enrolled in

```sql
SELECT
    c.course_code,
    c.title,
    c.semester,
    e.grade
FROM enrollments e
JOIN courses c ON e.course_id = c.id
WHERE e.student_id = 1
ORDER BY c.semester, c.course_code;
```

**What it does:** Returns every course that student #1 (Jordan Lee) is enrolled in, with their grade.

**Why it's written this way:**

This is the mirror of the previous query — same junction table, opposite direction. Here we start from `enrollments`, join to `courses` to get course details, and filter by `student_id`.

We don't need to JOIN to `students` at all because we already know which student we want (their ID is in the `WHERE` clause), and we're not returning any columns from the `students` table.

This is an important habit: **only JOIN tables you need columns from or need to filter on**. Unnecessary JOINs slow down queries and add noise.

---

### All courses taught by a specific professor

```sql
SELECT
    c.course_code,
    c.title,
    c.semester,
    c.max_capacity
FROM courses c
WHERE c.professor_id = 1
ORDER BY c.semester, c.course_code;
```

**What it does:** Returns all courses taught by professor #1 (Alan Torres).

**Why no JOIN?** The `courses` table already has a `professor_id` column. Because each course has exactly one professor and that relationship is stored directly in `courses`, we can filter without joining. If we wanted the professor's name in the output, we'd need a JOIN — but since we already know who we're looking for, it's unnecessary here.

This illustrates an important principle: **the number of JOINs should match the number of tables you need to read data from**, not the number of relationships that exist.

---

## Multi-Hop Joins

Multi-hop queries cross three or more tables to answer a question where the relationship isn't direct. These are the most interesting and most instructive queries in the set.

### All students a given professor has — across all their courses

```sql
SELECT DISTINCT
    s.first_name || ' ' || s.last_name AS student,
    s.major
FROM professors p
JOIN courses     c ON c.professor_id = p.id
JOIN enrollments e ON e.course_id    = c.id
JOIN students    s ON s.id           = e.student_id
WHERE p.id = 1
ORDER BY s.last_name;
```

**What it does:** Finds every student who has ever taken a course with professor Torres.

**Why it's written this way:**

There's no direct link between professors and students in the schema. To find a professor's students, you have to traverse three relationships:

```
professors → courses → enrollments → students
```

Each JOIN extends the chain one step. Read it left to right: "start with a professor, find all their courses, find all enrollments in those courses, find the students behind those enrollments."

**Why `DISTINCT`?** Without it, if a student enrolled in two of Torres's courses, they'd appear twice in the output (once per enrollment row). `DISTINCT` collapses duplicate result rows. An alternative would be `GROUP BY s.id`, but `DISTINCT` is cleaner here since we don't need aggregation.

This four-table join is the core pattern for any "what is the indirect relationship between X and Y" question in a relational database.

---

### All professors a given student has had

```sql
SELECT DISTINCT
    p.first_name || ' ' || p.last_name AS professor,
    p.tenure_status,
    d.name AS department
FROM enrollments e
JOIN courses     c ON c.id            = e.course_id
JOIN professors  p ON p.id            = c.professor_id
JOIN departments d ON d.id            = p.department_id
WHERE e.student_id = 1
ORDER BY p.last_name;
```

**What it does:** Finds every professor that student #1 (Jordan Lee) has had, across all their courses.

**Why it's written this way:**

This is the reverse of the previous query. The chain is:

```
enrollments → courses → professors → departments
```

We start from `enrollments` filtered to one student, follow the courses those enrollments point to, follow those courses to their professors, and then follow those professors to their departments (to get the department name in the output).

Again, `DISTINCT` prevents duplicates — if two of the student's courses share the same professor, that professor would otherwise appear twice.

Notice that `departments` is only in the query because we want `d.name` in the output. If we only needed the professor's name, we'd stop at the `professors` JOIN.

---

### Whether a student has had the same professor more than once

```sql
SELECT
    s.first_name || ' ' || s.last_name AS student,
    p.first_name || ' ' || p.last_name AS professor,
    COUNT(*) AS courses_together
FROM enrollments e
JOIN courses    c ON c.id = e.course_id
JOIN professors p ON p.id = c.professor_id
JOIN students   s ON s.id = e.student_id
GROUP BY s.id, p.id, s.first_name, s.last_name, p.first_name, p.last_name
HAVING COUNT(*) > 1
ORDER BY courses_together DESC, s.last_name;
```

**What it does:** Finds every (student, professor) pair where the student took more than one course with that professor, and shows how many courses they shared.

**Why it's written this way:**

This is a more advanced version of the multi-hop join. We don't use `DISTINCT` here — instead, we intentionally *count* how many times each (student, professor) pair appears.

`GROUP BY s.id, p.id, ...` collapses all rows with the same student and professor into a single output row. The `COUNT(*)` for each group is how many enrollment rows matched — which equals how many courses they shared.

`HAVING COUNT(*) > 1` filters *on the result of the aggregation*, keeping only pairs with more than one course together. This is a critical distinction:

- `WHERE` filters individual rows *before* grouping
- `HAVING` filters groups *after* grouping

You can't use `WHERE COUNT(*) > 1` — `COUNT` doesn't exist yet at the `WHERE` stage. `HAVING` exists precisely for this: filtering on computed aggregate values.

---

## Aggregation

Aggregation collapses many rows into summary statistics. The key functions are `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`. Any column not inside an aggregate function must appear in the `GROUP BY` clause.

### How many distinct students does each professor have?

```sql
SELECT
    p.first_name || ' ' || p.last_name AS professor,
    COUNT(DISTINCT e.student_id) AS total_students
FROM professors  p
JOIN courses     c ON c.professor_id = p.id
JOIN enrollments e ON e.course_id    = c.id
GROUP BY p.id, p.first_name, p.last_name
ORDER BY total_students DESC;
```

**What it does:** Counts how many unique students each professor has taught.

**Why `COUNT(DISTINCT e.student_id)` instead of `COUNT(*)`?**

`COUNT(*)` would count the number of *enrollment rows* per professor, which overcounts students who took multiple courses with the same professor. For example, if Jordan Lee took three of Torres's courses, `COUNT(*)` would add 3 to Torres's total even though it's the same student.

`COUNT(DISTINCT e.student_id)` counts each student only once per professor, no matter how many of their courses that student took. The word `DISTINCT` inside an aggregate function means "count unique values only."

**Why does `GROUP BY` include `p.first_name` and `p.last_name` when we're already grouping by `p.id`?**

In PostgreSQL, every non-aggregated column in the `SELECT` list must appear in `GROUP BY`. The `id` uniquely identifies the professor, so technically the name columns are redundant — but PostgreSQL doesn't know that, so you have to include them. Some databases (like MySQL) are more lenient about this; PostgreSQL is strict by design.

---

### How many courses is each student enrolled in?

```sql
SELECT
    s.first_name || ' ' || s.last_name AS student,
    COUNT(e.id) AS course_count
FROM students    s
JOIN enrollments e ON e.student_id = s.id
GROUP BY s.id, s.first_name, s.last_name
ORDER BY course_count DESC, s.last_name;
```

**What it does:** Counts how many courses each student is taking.

**Why it's written this way:**

`COUNT(e.id)` counts the number of enrollment rows per student. Since each enrollment row represents one course, this gives us the course count. You could also use `COUNT(*)` here — the result is the same because there are no NULL `enrollment.id` values. The difference: `COUNT(column)` skips NULLs; `COUNT(*)` never skips anything.

**What if a student has zero enrollments?** This query would exclude them entirely, because an INNER JOIN (the default) only produces rows where a match exists in both tables. If you wanted to include unenrolled students with a count of 0, you'd use `LEFT JOIN enrollments e ON e.student_id = s.id` — a LEFT JOIN keeps all rows from the left table (`students`) even when there's no matching row on the right.

---

### Average GPA by major

```sql
SELECT
    major,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    COUNT(*)           AS student_count
FROM students
GROUP BY major
ORDER BY avg_gpa DESC;
```

**What it does:** Computes the average GPA for each major and shows how many students are in each group.

**Why it's written this way:**

`AVG(gpa)` is an aggregate function that computes the mean across all rows in each group. `GROUP BY major` defines the groups — one per unique major value.

`ROUND(AVG(gpa), 2)` wraps the result in `ROUND` to limit it to two decimal places. `AVG` by itself can return something like `3.6166666...`; rounding makes the output readable.

Including `COUNT(*)` alongside `AVG` is a good habit: it tells you how much data the average is based on. An average GPA of 3.9 means something very different if it comes from 1 student versus 20.

No JOIN is needed because `major` is stored directly on the `students` table.

---

### Total enrollment count per department

```sql
SELECT
    d.name AS department,
    COUNT(e.id) AS total_enrollments
FROM departments d
JOIN courses     c ON c.department_id = d.id
JOIN enrollments e ON e.course_id     = c.id
GROUP BY d.id, d.name
ORDER BY total_enrollments DESC;
```

**What it does:** Counts total enrollments per department, aggregating across all courses in each department.

**Why it's written this way:**

Enrollments don't have a direct link to departments — they link to courses, and courses link to departments. So we need two JOINs to bridge the gap:

```
departments → courses → enrollments
```

After the JOINs, `GROUP BY d.id, d.name` collapses all enrollment rows for all courses in a department into one output row. `COUNT(e.id)` counts all those enrollment rows.

Starting `FROM departments` (rather than `FROM enrollments`) and working forward is a stylistic choice that makes the intent clear: "for each department, count enrollments." Either direction produces the same result, but starting from the anchor concept (department) reads more naturally.

---

## HAVING / Filtering on Aggregates

`HAVING` is to `GROUP BY` what `WHERE` is to `FROM` — it's a filter, but applied *after* the groups are computed. Any time you need to filter based on a `COUNT`, `SUM`, `AVG`, or similar, you need `HAVING`.

### Which students have had the same professor more than once?

```sql
SELECT
    s.first_name || ' ' || s.last_name AS student,
    p.first_name || ' ' || p.last_name AS professor,
    COUNT(*) AS times_together
FROM enrollments e
JOIN courses    c ON c.id = e.course_id
JOIN professors p ON p.id = c.professor_id
JOIN students   s ON s.id = e.student_id
GROUP BY s.id, p.id, s.first_name, s.last_name, p.first_name, p.last_name
HAVING COUNT(*) > 1
ORDER BY s.last_name, p.last_name;
```

**What it does:** Identical in structure to the "same professor more than once" multi-hop query above, but here ordered by student name rather than count. The point is the same: find repeat student-professor pairs.

**Why you can't use `WHERE` here:**

When the database processes this query, the order of operations is:
1. `FROM` — identify the tables
2. `JOIN` — combine them
3. `WHERE` — filter individual rows
4. `GROUP BY` — collapse into groups
5. `HAVING` — filter groups
6. `SELECT` — compute output columns
7. `ORDER BY` — sort

`COUNT(*)` doesn't exist until step 5. Writing `WHERE COUNT(*) > 1` would fail because at the `WHERE` stage, no counting has happened yet. `HAVING` was designed specifically for step 5 — it lets you filter on values that only exist after aggregation.

---

### Which professors teach more than one course?

```sql
SELECT
    p.first_name || ' ' || p.last_name AS professor,
    COUNT(c.id) AS course_count
FROM professors p
JOIN courses    c ON c.professor_id = p.id
GROUP BY p.id, p.first_name, p.last_name
HAVING COUNT(c.id) > 1
ORDER BY course_count DESC;
```

**What it does:** Lists professors who teach multiple courses.

**Why it's written this way:**

`JOIN courses c ON c.professor_id = p.id` produces one row per (professor, course) pair. Grouping by professor and counting gives us the course count per professor. `HAVING COUNT(c.id) > 1` keeps only the professors with more than one course.

Professors with zero courses would be excluded here because we're using an INNER JOIN. If you wanted to include professors who don't teach any courses, you'd use `LEFT JOIN` and the count for those professors would be 0, which `HAVING > 1` would filter out anyway — so in this specific case, it doesn't matter. But it's worth being aware of.

---

### Which courses have more than 10 enrolled students?

```sql
SELECT
    c.course_code,
    c.title,
    c.semester,
    COUNT(e.id) AS enrolled_count
FROM courses     c
JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.course_code, c.title, c.semester
HAVING COUNT(e.id) > 10
ORDER BY enrolled_count DESC;
```

**What it does:** Finds popular courses with over 10 students enrolled.

**Why it's written this way:**

The pattern is the same: JOIN to get enrollment rows, GROUP BY course, count the enrollments per course, HAVING filters on that count.

Notice `GROUP BY` includes `c.id, c.course_code, c.title, c.semester` — even though `c.id` alone uniquely identifies the course. This is because PostgreSQL requires every non-aggregated column in the `SELECT` list to be in `GROUP BY`. The `c.id` is the functional group key; the rest are along for the ride.

---

## Subqueries

A subquery is a `SELECT` statement nested inside another query. They're useful when the answer to one question depends on the answer to another — and when that inner answer isn't easily expressible as a JOIN.

### Students enrolled in at least one course outside their declared major's department

```sql
SELECT DISTINCT
    s.first_name || ' ' || s.last_name AS student,
    s.major
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN courses     c ON c.id            = e.course_id
    JOIN departments d ON d.id            = c.department_id
    WHERE e.student_id = s.id
      AND d.name <> s.major
);
```

**What it does:** Finds students who have taken at least one course that doesn't belong to their declared major's department.

**Why `EXISTS` instead of a JOIN?**

`EXISTS` is a membership test — it asks "does at least one row matching this condition exist?" It returns true or false for each outer row (each student), and it stops as soon as it finds the first match. This makes it efficient when you only need to know *whether* something exists, not *how many* times it exists.

The subquery is a **correlated subquery** — it references `s.id` and `s.major` from the outer query. For each student row in the outer query, the subquery re-runs with that student's values. This is what makes it able to ask a per-student question: "does *this* student have any cross-department enrollments?"

`SELECT 1` is conventional inside `EXISTS` subqueries — the actual value returned doesn't matter, only whether a row was found. You could write `SELECT *` or `SELECT 42` and get the same result; `SELECT 1` just signals clearly that we don't care about the value.

`d.name <> s.major` is the cross-department check. This works because we named the departments to match the major names in the `students` table (e.g., both use "Computer Science"). In a production database you'd more likely compare department IDs, not names.

---

### Students who share at least one course with a given student

```sql
SELECT DISTINCT
    s.first_name || ' ' || s.last_name AS classmate,
    s.major
FROM students s
WHERE s.id <> 1
  AND s.id IN (
      SELECT e2.student_id
      FROM enrollments e1
      JOIN enrollments e2 ON e1.course_id = e2.course_id
      WHERE e1.student_id = 1
        AND e2.student_id <> 1
  )
ORDER BY s.last_name;
```

**What it does:** Finds every student who shares at least one course with Jordan Lee (student #1).

**Why it's written this way:**

The inner query is the interesting part. It joins `enrollments` to itself — `e1` and `e2` are two aliases for the same table.

`e1` represents Jordan Lee's enrollments (filtered by `e1.student_id = 1`). `e2` represents everyone else's enrollments. `JOIN enrollments e2 ON e1.course_id = e2.course_id` matches pairs of enrollment rows that are in the same course. The result of the inner query is the set of student IDs who have at least one course-match with Jordan.

**Self-joins** (joining a table to itself) are a powerful pattern for finding relationships *within* the same table. Here the relationship is "two students in the same course," which lives entirely in `enrollments`.

`IN (subquery)` in the outer `WHERE` clause filters the `students` table to only those whose IDs appear in the subquery's result set. It's equivalent to `EXISTS` for this use case — `IN` tends to read more naturally when the subquery produces a list of IDs.

`DISTINCT` is needed on the outer query because a student could share multiple courses with Jordan — without it, that student would appear multiple times.

---

## Window Functions

Window functions compute a value for each row based on a *window* of related rows, without collapsing the rows together the way `GROUP BY` does. You get one output row per input row, but each row also sees aggregated information from its window.

The syntax is `FUNCTION() OVER (PARTITION BY ... ORDER BY ...)`:

- `PARTITION BY` divides rows into groups (like `GROUP BY`, but without collapsing)
- `ORDER BY` defines the order within each partition

### Rank students by GPA within their major

```sql
SELECT
    first_name || ' ' || last_name AS student,
    major,
    gpa,
    RANK() OVER (PARTITION BY major ORDER BY gpa DESC) AS rank_in_major
FROM students
ORDER BY major, rank_in_major;
```

**What it does:** Assigns each student a rank within their major based on GPA, with rank 1 being the highest GPA.

**Why a window function instead of a subquery?**

You could compute per-major rankings with a correlated subquery, but it would be verbose and slow. The window function does it in one pass, cleanly.

`PARTITION BY major` means rankings are reset for each major — a student is ranked among their peers, not against the whole university. Without `PARTITION BY`, you'd get a single ranking across all students.

`ORDER BY gpa DESC` determines what "rank 1" means: highest GPA is rank 1.

**`RANK()` vs `ROW_NUMBER()`:** If two students in the same major have identical GPAs, `RANK()` gives them the same rank number and then skips the next rank (e.g., two students tied at rank 2 means the next rank is 4). `ROW_NUMBER()` would assign them different numbers arbitrarily. Use `RANK()` when ties should be acknowledged.

The outer `ORDER BY major, rank_in_major` sorts the final output — this is separate from the `ORDER BY` inside the window function, which only defines the ranking logic.

---

### Running enrollment count per semester

```sql
SELECT
    c.semester,
    s.first_name || ' ' || s.last_name AS student,
    c.course_code,
    e.enrolled_at,
    COUNT(*) OVER (
        PARTITION BY c.semester
        ORDER BY e.enrolled_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses  c ON c.id = e.course_id
ORDER BY c.semester, e.enrolled_at;
```

**What it does:** Shows each enrollment event with a running total of how many enrollments have occurred in that semester up to and including that moment.

**Why it's written this way:**

`PARTITION BY c.semester` resets the running count at the start of each semester — Fall 2024 and Spring 2025 each get their own independent running total.

`ORDER BY e.enrolled_at` defines what "running" means — the count accumulates in timestamp order.

`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` is the **window frame** — it tells the database which rows to include in the count for the current row: all rows from the beginning of the partition up to and including the current row. This is what makes the total "run" — each row's count includes itself and everything before it.

Without the `ROWS BETWEEN` clause, PostgreSQL uses a default frame of `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, which can behave unexpectedly with ties (multiple rows with the same timestamp would all see the count after all of them are included). `ROWS BETWEEN` is explicit and safer when you want true row-by-row accumulation.

This pattern is useful for any "cumulative over time" calculation: running revenue, cumulative sign-ups, rolling averages.

---

## Summary: choosing the right tool

| Situation | Use |
|---|---|
| Data from one table | `SELECT ... FROM ... WHERE` |
| Data from multiple tables | `JOIN` |
| Include rows with no match | `LEFT JOIN` |
| Deduplicate result rows | `DISTINCT` |
| Summarize groups of rows | `GROUP BY` + aggregate functions |
| Filter on a summary value | `HAVING` |
| Ask "does this exist?" | `EXISTS` subquery |
| Filter to a set of IDs | `IN` subquery |
| Per-row ranking or running totals | Window function (`OVER`) |
| Rank with ties acknowledged | `RANK()` |
| Rank without ties | `ROW_NUMBER()` |

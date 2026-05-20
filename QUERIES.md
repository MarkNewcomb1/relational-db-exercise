# Westfield University — SQL Query Reference

Each query includes a plain-English description and the SQL.

---

## Basic Retrieval

### List all students ordered by GPA descending

```sql
SELECT first_name, last_name, major, gpa
FROM students
ORDER BY gpa DESC;
```

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

---

## Single-Hop Joins

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

---

### All courses a specific student is enrolled in (Jordan Lee, student_id = 1)

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

---

### All courses taught by a specific professor (Alan Torres, professor_id = 1)

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

---

## Multi-Hop Joins

### All students a given professor has — across all their courses

Returns every student who has taken at least one course with the given professor.

```sql
SELECT DISTINCT
    s.first_name || ' ' || s.last_name AS student,
    s.major
FROM professors p
JOIN courses     c ON c.professor_id = p.id
JOIN enrollments e ON e.course_id    = c.id
JOIN students    s ON s.id           = e.student_id
WHERE p.id = 1   -- Alan Torres
ORDER BY s.last_name;
```

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
WHERE e.student_id = 1   -- Jordan Lee
ORDER BY p.last_name;
```

---

### Whether a student has had the same professor more than once

Shows each (student, professor) pair where the student took more than one course with that professor.

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

---

## Aggregation

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

---

## HAVING / Filtering on Aggregates

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

---

## Subqueries

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
      AND d.name <> s.major   -- course dept doesn't match the student's major
);
```

---

### Students who share at least one course with a given student (Jordan Lee, student_id = 1)

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

---

## Window Functions

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

---

### Running enrollment count per semester (ordered by enrollment time)

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

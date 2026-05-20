-- Westfield University — Schema Migration
-- Safe to re-run: drops all tables in dependency order before recreating

DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ─── Tables ──────────────────────────────────────────────────────────────────

CREATE TABLE departments (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10)  NOT NULL UNIQUE
);

CREATE TABLE professors (
    id             SERIAL PRIMARY KEY,
    first_name     VARCHAR(50)  NOT NULL,
    last_name      VARCHAR(50)  NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    department_id  INTEGER      NOT NULL REFERENCES departments(id),
    tenure_status  VARCHAR(20)  NOT NULL CHECK (tenure_status IN ('tenured', 'tenure-track', 'adjunct'))
);

CREATE TABLE students (
    id               SERIAL PRIMARY KEY,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    major            VARCHAR(100) NOT NULL,
    enrollment_year  INTEGER      NOT NULL,
    gpa              NUMERIC(3,2) NOT NULL CHECK (gpa BETWEEN 0.00 AND 4.00)
);

CREATE TABLE courses (
    id             SERIAL PRIMARY KEY,
    course_code    VARCHAR(20)  NOT NULL UNIQUE,
    title          VARCHAR(150) NOT NULL,
    credits        INTEGER      NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id  INTEGER      NOT NULL REFERENCES departments(id),
    professor_id   INTEGER      NOT NULL REFERENCES professors(id),
    semester       VARCHAR(20)  NOT NULL CHECK (semester IN ('Fall 2024', 'Spring 2025')),
    max_capacity   INTEGER      NOT NULL CHECK (max_capacity > 0)
);

CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INTEGER   NOT NULL REFERENCES students(id),
    course_id   INTEGER   NOT NULL REFERENCES courses(id),
    grade       VARCHAR(2)         CHECK (grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F', 'W')),
    enrolled_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id)
);

-- ─── Indexes on FK columns ────────────────────────────────────────────────────

CREATE INDEX idx_professors_department ON professors(department_id);
CREATE INDEX idx_courses_department    ON courses(department_id);
CREATE INDEX idx_courses_professor     ON courses(professor_id);
CREATE INDEX idx_enrollments_student   ON enrollments(student_id);
CREATE INDEX idx_enrollments_course    ON enrollments(course_id);

-- ─── Read-only role for the frontend ─────────────────────────────────────────

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'westfield_readonly') THEN
        CREATE ROLE westfield_readonly LOGIN PASSWORD 'readonly_pass';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE westfield TO westfield_readonly;
GRANT USAGE   ON SCHEMA public       TO westfield_readonly;
GRANT SELECT  ON ALL TABLES IN SCHEMA public TO westfield_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO westfield_readonly;

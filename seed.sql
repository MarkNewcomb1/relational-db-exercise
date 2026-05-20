-- Westfield University — Seed Data
-- Run after migration.sql

-- ─── Departments ─────────────────────────────────────────────────────────────

INSERT INTO departments (name, code) VALUES
    ('Computer Science',    'CS'),
    ('Mathematics',         'MATH'),
    ('English Literature',  'ENGL'),
    ('Psychology',          'PSYC'),
    ('History',             'HIST');

-- ─── Professors (12) ─────────────────────────────────────────────────────────
-- dept IDs: CS=1, MATH=2, ENGL=3, PSYC=4, HIST=5

INSERT INTO professors (first_name, last_name, email, department_id, tenure_status) VALUES
    ('Alan',    'Torres',    'a.torres@westfield.edu',    1, 'tenured'),        -- p1  CS
    ('Sandra',  'Kim',       's.kim@westfield.edu',       1, 'tenure-track'),   -- p2  CS
    ('Derek',   'Okafor',    'd.okafor@westfield.edu',    1, 'adjunct'),        -- p3  CS
    ('Priya',   'Sharma',    'p.sharma@westfield.edu',    2, 'tenured'),        -- p4  MATH
    ('James',   'Whitmore',  'j.whitmore@westfield.edu',  2, 'tenure-track'),   -- p5  MATH
    ('Lydia',   'Chen',      'l.chen@westfield.edu',      3, 'tenured'),        -- p6  ENGL
    ('Marco',   'DiLuca',    'm.diluca@westfield.edu',    3, 'adjunct'),        -- p7  ENGL
    ('Fatima',  'Al-Hassan', 'f.alhassan@westfield.edu',  4, 'tenured'),        -- p8  PSYC
    ('Oliver',  'Brecht',    'o.brecht@westfield.edu',    4, 'tenure-track'),   -- p9  PSYC
    ('Helen',   'Vasquez',   'h.vasquez@westfield.edu',   5, 'tenured'),        -- p10 HIST
    ('Jerome',  'Nakamura',  'j.nakamura@westfield.edu',  5, 'tenure-track'),   -- p11 HIST
    ('Cynthia', 'Park',      'c.park@westfield.edu',      2, 'adjunct');        -- p12 MATH

-- ─── Students (20) ───────────────────────────────────────────────────────────

INSERT INTO students (first_name, last_name, email, major, enrollment_year, gpa) VALUES
    ('Jordan',    'Lee',       'j.lee@student.westfield.edu',       'Computer Science',   2022, 3.85),  -- s1
    ('Maya',      'Patel',     'm.patel@student.westfield.edu',     'Computer Science',   2023, 3.60),  -- s2
    ('Ethan',     'Ross',      'e.ross@student.westfield.edu',      'Computer Science',   2021, 2.95),  -- s3
    ('Sofia',     'Guerrero',  's.guerrero@student.westfield.edu',  'Computer Science',   2024, 3.40),  -- s4
    ('Amir',      'Johnson',   'a.johnson@student.westfield.edu',   'Mathematics',        2022, 3.90),  -- s5
    ('Rachel',    'Flynn',     'r.flynn@student.westfield.edu',     'Mathematics',        2023, 3.20),  -- s6
    ('Noah',      'Huang',     'n.huang@student.westfield.edu',     'Mathematics',        2021, 2.80),  -- s7
    ('Isabella',  'Grant',     'i.grant@student.westfield.edu',     'English Literature', 2022, 3.75),  -- s8
    ('Liam',      'Osei',      'l.osei@student.westfield.edu',      'English Literature', 2023, 3.10),  -- s9
    ('Zoe',       'Martinez',  'z.martinez@student.westfield.edu',  'Psychology',         2022, 3.55),  -- s10
    ('Caleb',     'Williams',  'c.williams@student.westfield.edu',  'Psychology',         2023, 3.30),  -- s11
    ('Nadia',     'Kowalski',  'n.kowalski@student.westfield.edu',  'Psychology',         2021, 2.70),  -- s12
    ('Marcus',    'Thompson',  'm.thompson@student.westfield.edu',  'History',            2022, 3.65),  -- s13
    ('Ava',       'Nguyen',    'a.nguyen@student.westfield.edu',    'History',            2023, 3.45),  -- s14
    ('Tyler',     'Brooks',    't.brooks@student.westfield.edu',    'History',            2024, 2.60),  -- s15
    ('Hannah',    'Reeves',    'h.reeves@student.westfield.edu',    'Computer Science',   2022, 3.15),  -- s16
    ('Diego',     'Castillo',  'd.castillo@student.westfield.edu',  'Mathematics',        2023, 3.80),  -- s17
    ('Priya',     'Menon',     'p.menon@student.westfield.edu',     'English Literature', 2022, 3.50),  -- s18
    ('Sam',       'Adeyemi',   's.adeyemi@student.westfield.edu',   'Psychology',         2024, 3.00),  -- s19
    ('Olivia',    'Fischer',   'o.fischer@student.westfield.edu',   'History',            2021, 3.70);  -- s20

-- ─── Courses (18) ────────────────────────────────────────────────────────────
-- Semesters: Fall 2024 and Spring 2025
-- professor IDs match comments above

INSERT INTO courses (course_code, title, credits, department_id, professor_id, semester, max_capacity) VALUES
    -- Computer Science (dept 1)
    ('CS101',   'Intro to Programming',            3, 1, 1, 'Fall 2024',   30),   -- c1  prof Torres
    ('CS301',   'Data Structures',                 3, 1, 1, 'Fall 2024',   25),   -- c2  prof Torres
    ('CS401',   'Algorithm Design',                3, 1, 1, 'Spring 2025', 25),   -- c3  prof Torres
    ('CS210',   'Computer Organization',           3, 1, 2, 'Fall 2024',   28),   -- c4  prof Kim
    ('CS350',   'Operating Systems',               3, 1, 2, 'Spring 2025', 24),   -- c5  prof Kim
    ('CS490',   'Web Development Practicum',       3, 1, 3, 'Spring 2025', 20),   -- c6  prof Okafor

    -- Mathematics (dept 2)
    ('MATH101', 'Calculus I',                      4, 2, 4, 'Fall 2024',   35),   -- c7  prof Sharma
    ('MATH201', 'Calculus II',                     4, 2, 4, 'Spring 2025', 30),   -- c8  prof Sharma
    ('MATH310', 'Linear Algebra',                  3, 2, 5, 'Fall 2024',   28),   -- c9  prof Whitmore
    ('MATH410', 'Probability & Statistics',        3, 2, 12,'Spring 2025', 28),   -- c10 prof Park

    -- English Literature (dept 3)
    ('ENGL101', 'Composition & Rhetoric',          3, 3, 6, 'Fall 2024',   25),   -- c11 prof Chen
    ('ENGL220', 'British Literature Survey',       3, 3, 6, 'Spring 2025', 22),   -- c12 prof Chen
    ('ENGL340', 'American Modernism',              3, 3, 7, 'Fall 2024',   20),   -- c13 prof DiLuca

    -- Psychology (dept 4)
    ('PSYC101', 'Introduction to Psychology',      3, 4, 8, 'Fall 2024',   40),   -- c14 prof Al-Hassan
    ('PSYC360', 'Abnormal Psychology',             3, 4, 8, 'Spring 2025', 30),   -- c15 prof Al-Hassan
    ('PSYC240', 'Research Methods in Psychology',  3, 4, 9, 'Fall 2024',   25),   -- c16 prof Brecht

    -- History (dept 5)
    ('HIST110', 'World History I',                 3, 5, 10,'Fall 2024',   35),   -- c17 prof Vasquez
    ('HIST320', 'Modern European History',         3, 5, 11,'Spring 2025', 28);   -- c18 prof Nakamura

-- ─── Enrollments (~100 rows) ─────────────────────────────────────────────────
-- Key design choices:
--   s1  (Jordan Lee, CS)    → CS301 + CS401 = same prof (Torres) twice
--   s2  (Maya Patel, CS)    → CS301 + CS401 = same prof (Torres) twice
--   s3  (Ethan Ross, CS)    → CS101 + CS301 = same prof (Torres) twice
--   s5  (Amir Johnson, MATH)→ MATH101 + MATH201 = same prof (Sharma) twice
--   s6  (Rachel Flynn, MATH)→ MATH101 + MATH201 = same prof (Sharma) twice
--   s10 (Zoe Martinez, PSYC)→ PSYC101 + PSYC360 = same prof (Al-Hassan) twice
--   s11 (Caleb Williams)    → PSYC101 + PSYC360 = same prof (Al-Hassan) twice
--   Cross-department: CS students in HIST110, MATH students in ENGL101, etc.

INSERT INTO enrollments (student_id, course_id, grade) VALUES
    -- Jordan Lee (s1, CS) — same prof Torres twice via CS301+CS401, plus cross-dept
    (1, 2,  'A'),    -- CS301  (Torres)
    (1, 3,  'A-'),   -- CS401  (Torres) ← same prof second time
    (1, 9,  'B+'),   -- MATH310
    (1, 17, 'B'),    -- HIST110 ← cross-dept

    -- Maya Patel (s2, CS) — same prof Torres twice
    (2, 1,  'B+'),   -- CS101  (Torres)
    (2, 2,  'A-'),   -- CS301  (Torres) ← same prof second time
    (2, 4,  'B'),    -- CS210
    (2, 14, 'A'),    -- PSYC101 ← cross-dept

    -- Ethan Ross (s3, CS) — same prof Torres twice via CS101+CS301
    (3, 1,  'C+'),   -- CS101  (Torres)
    (3, 2,  'C'),    -- CS301  (Torres) ← same prof second time
    (3, 5,  'C+'),   -- CS350
    (3, 7,  'B-'),   -- MATH101 ← cross-dept

    -- Sofia Guerrero (s4, CS) — Kim twice via CS210+CS350, cross-dept
    (4, 4,  'A-'),   -- CS210  (Kim)
    (4, 5,  'B+'),   -- CS350  (Kim) ← same prof second time
    (4, 6,  'A'),    -- CS490
    (4, 11, 'B'),    -- ENGL101 ← cross-dept

    -- Amir Johnson (s5, MATH) — same prof Sharma twice via MATH101+MATH201
    (5, 7,  'A'),    -- MATH101 (Sharma)
    (5, 8,  'A'),    -- MATH201 (Sharma) ← same prof second time
    (5, 9,  'A-'),   -- MATH310
    (5, 2,  'B+'),   -- CS301 ← cross-dept

    -- Rachel Flynn (s6, MATH) — same prof Sharma twice
    (6, 7,  'B'),    -- MATH101 (Sharma)
    (6, 8,  'B+'),   -- MATH201 (Sharma) ← same prof second time
    (6, 10, 'B-'),   -- MATH410
    (6, 14, 'A-'),   -- PSYC101 ← cross-dept

    -- Noah Huang (s7, MATH)
    (7, 7,  'C+'),   -- MATH101
    (7, 9,  'C'),    -- MATH310
    (7, 10, 'C+'),   -- MATH410
    (7, 17, 'B-'),   -- HIST110 ← cross-dept

    -- Isabella Grant (s8, ENGL)
    (8, 11, 'A'),    -- ENGL101 (Chen)
    (8, 12, 'A-'),   -- ENGL220 (Chen) ← same prof second time
    (8, 13, 'B+'),   -- ENGL340
    (8, 17, 'A'),    -- HIST110 ← cross-dept

    -- Liam Osei (s9, ENGL)
    (9, 11, 'B+'),   -- ENGL101
    (9, 12, 'B'),    -- ENGL220
    (9, 13, 'B-'),   -- ENGL340
    (9, 16, 'C+'),   -- PSYC240 ← cross-dept

    -- Zoe Martinez (s10, PSYC) — same prof Al-Hassan twice
    (10, 14, 'A-'),  -- PSYC101 (Al-Hassan)
    (10, 15, 'A'),   -- PSYC360 (Al-Hassan) ← same prof second time
    (10, 16, 'B+'),  -- PSYC240
    (10, 13, 'B'),   -- ENGL340 ← cross-dept

    -- Caleb Williams (s11, PSYC) — same prof Al-Hassan twice
    (11, 14, 'B'),   -- PSYC101 (Al-Hassan)
    (11, 15, 'B+'),  -- PSYC360 (Al-Hassan) ← same prof second time
    (11, 16, 'C+'),  -- PSYC240
    (11, 7,  'B-'),  -- MATH101 ← cross-dept

    -- Nadia Kowalski (s12, PSYC)
    (12, 14, 'C'),   -- PSYC101
    (12, 16, 'C+'),  -- PSYC240
    (12, 11, 'B-'),  -- ENGL101 ← cross-dept
    (12, 18, 'C'),   -- HIST320 ← cross-dept

    -- Marcus Thompson (s13, HIST)
    (13, 17, 'A'),   -- HIST110 (Vasquez)
    (13, 18, 'A-'),  -- HIST320
    (13, 14, 'B+'),  -- PSYC101 ← cross-dept
    (13, 2,  'B'),   -- CS301 ← cross-dept

    -- Ava Nguyen (s14, HIST)
    (14, 17, 'B+'),  -- HIST110
    (14, 18, 'B'),   -- HIST320
    (14, 11, 'A-'),  -- ENGL101 ← cross-dept
    (14, 7,  'B-'),  -- MATH101 ← cross-dept

    -- Tyler Brooks (s15, HIST)
    (15, 17, 'C+'),  -- HIST110
    (15, 18, 'C'),   -- HIST320
    (15, 14, 'B-'),  -- PSYC101 ← cross-dept

    -- Hannah Reeves (s16, CS)
    (16, 1,  'B-'),  -- CS101  (Torres)
    (16, 3,  'C+'),  -- CS401  (Torres) ← same prof second time
    (16, 4,  'B'),   -- CS210
    (16, 11, 'A-'),  -- ENGL101 ← cross-dept

    -- Diego Castillo (s17, MATH)
    (17, 7,  'A-'),  -- MATH101 (Sharma)
    (17, 8,  'A'),   -- MATH201 (Sharma) ← same prof second time
    (17, 10, 'B+'),  -- MATH410
    (17, 1,  'B'),   -- CS101 ← cross-dept

    -- Priya Menon (s18, ENGL) — Chen twice
    (18, 11, 'A'),   -- ENGL101 (Chen)
    (18, 12, 'A'),   -- ENGL220 (Chen) ← same prof second time
    (18, 17, 'B+'),  -- HIST110 ← cross-dept
    (18, 16, 'B'),   -- PSYC240 ← cross-dept

    -- Sam Adeyemi (s19, PSYC) — Brecht only once, Al-Hassan once
    (19, 14, 'B+'),  -- PSYC101 (Al-Hassan)
    (19, 16, 'B'),   -- PSYC240 (Brecht)
    (19, 7,  'C+'),  -- MATH101 ← cross-dept
    (19, 17, 'B-'),  -- HIST110 ← cross-dept

    -- Olivia Fischer (s20, HIST) — Vasquez + Nakamura, plus cross-dept
    (20, 17, 'A-'),  -- HIST110 (Vasquez)
    (20, 18, 'A'),   -- HIST320 (Nakamura)
    (20, 11, 'B+'),  -- ENGL101 ← cross-dept
    (20, 15, 'B'),   -- PSYC360 ← cross-dept

    -- Extra enrollments to flesh out popular courses
    (1,  1,  'A'),   -- Jordan → CS101  (Torres) ← 3rd Torres course
    (2,  3,  'A'),   -- Maya   → CS401  (Torres) ← 3rd Torres course
    (3,  4,  'D'),   -- Ethan  → CS210
    (5,  3,  'A-'),  -- Amir   → CS401 ← cross-dept
    (6,  9,  'B+'),  -- Rachel → MATH310
    (7,  8,  'D'),   -- Noah   → MATH201
    (8,  14, 'B'),   -- Isabella → PSYC101 ← cross-dept
    (9,  17, 'C+'),  -- Liam  → HIST110 ← cross-dept
    (10, 11, 'B-'),  -- Zoe   → ENGL101 ← cross-dept
    (11, 17, 'C'),   -- Caleb → HIST110 ← cross-dept
    (12, 15, 'C-'),  -- Nadia → PSYC360 (Al-Hassan) ← same prof second time
    (13, 11, 'B+'),  -- Marcus → ENGL101 ← cross-dept
    (15, 7,  'C'),   -- Tyler → MATH101 ← cross-dept
    (16, 14, 'B'),   -- Hannah → PSYC101 ← cross-dept
    (17, 9,  'A-'),  -- Diego  → MATH310
    (19, 15, 'B-'),  -- Sam   → PSYC360 (Al-Hassan) ← same prof second time
    (20, 14, 'B+');  -- Olivia → PSYC101 ← cross-dept

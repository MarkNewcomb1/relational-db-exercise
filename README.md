# Westfield University — SQL Learning Project

A local PostgreSQL learning project built around a mock university database. The goal is to practice relational database concepts: many-to-many relationships, JOIN patterns, aggregation, subqueries, and window functions.

## Prerequisites

- PostgreSQL 14 or later (`psql` and `createdb` available in your PATH)
- Node.js 18 or later (for the frontend)

## First-time setup

```bash
# 1. Create the database
createdb westfield

# 2. Run the schema migration (creates tables, indexes, and a read-only role)
psql -d westfield -f migration.sql

# 3. Seed the database with departments, professors, students, courses, and enrollments
psql -d westfield -f seed.sql
```

## Starting the frontend

```bash
cd frontend
npm install       # only needed once
npm start
```

Then open `http://localhost:3000` in your browser. The explorer lets you run any `SELECT` query against the database. Write operations (`INSERT`, `UPDATE`, `DELETE`, `DROP`, etc.) are blocked.

## Resetting the database

If you want to start fresh, re-run the migration and seed:

```bash
psql -d westfield -f migration.sql
psql -d westfield -f seed.sql
```

`migration.sql` drops all tables before recreating them, so this is safe to run at any time.

## Querying directly with psql

```bash
psql -d westfield
```

## What's in the database

| Table | Rows | Description |
|---|---|---|
| `departments` | 5 | CS, Math, English Lit, Psychology, History |
| `professors` | 12 | Mix of tenured, tenure-track, and adjunct |
| `students` | 20 | Declared majors, enrollment years, GPAs |
| `courses` | 18 | Across Fall 2024 and Spring 2025 |
| `enrollments` | 96 | Junction table with grades |

## Files

| File | Description |
|---|---|
| `migration.sql` | Schema definition — safe to re-run |
| `seed.sql` | Mock data |
| `QUERIES.md` | Reference queries covering joins, aggregation, subqueries, and window functions |
| `frontend/` | Node.js read-only SQL explorer |

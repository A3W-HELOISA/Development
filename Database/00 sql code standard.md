# SQL Code Standards for PostgreSQL

## General Guidelines
- Use lowercase for SQL keywords and identifiers.
- Use snake_case for naming (e.g., `first_name`).
- End each SQL statement with a semicolon (`;`).

## Naming Conventions
 
### Tables
- Use singular nouns (e.g., `user`, `order`).
- Column name should be always **id**, even in tempting cases when the table has a small unique code like countries
- Data type should be **serial**, and only in extreme cases bigserial (>2.147.483.647) 
- Name of constraint should be `pk_<table>` (e.g., `pk_user`).
- Always create table and primary key together at start.
- Example: CREATE TABLE x_type (id SERIAL, CONSTRAINT pk_x_type PRIMARY KEY (id));

### Columns
- Add the columns in subsequent statements.
- Example: ALTER TABLE x_type ADD COLUMN code VARCHAR(50) UNIQUE NOT NULL;
- Use singular nouns (e.g., `user_id`, `order_date`).
- Prefix foreign keys columns, with the referenced table name and _id (e.g., `user_id` in the `order` table).

### Descriptive Columns
Use:
- code VARCHAR(50) UNIQUE NOT NULL;
- name VARCHAR(255) NOT NULL;
- description TEXT NOT NULL;
- remarks TEXT;

### Boolean Columns
- Always open boolean columns with not null and default (unless null values are needed)
- Example: ALTER TABLE x_type ADD is_valid BOOL DEFAULT false not null;

### Geometry Columns
- Use always 'geom' as the geometry column
- Declare projection using EPSG:2100
- Always create spatial index for geom column (if exists) with `idx_<table>_geom` (e.g., `idx_area_geom`).
- Example: CREATE INDEX idx_area_geom ON area USING GIST(geom);

### Indexes
- Name indexes with the format `idx_<table>_<column1>[_<columnN>]` (e.g., `idx_user_email`).

### Constraints
- Name foreign keys as `fk_<table>_<referenced_table>` (e.g., `fk_order_user`).
- Name unique constraints as `uq_<table>_<column1>[_<columnN>]` (e.g., `uq_user_email`).
- Name check constraints as `chk_<table>_<column>` (e.g., `chk_user_age`).

## Data Types
- Use `serial` or `bigserial` for auto-incrementing primary keys.
- Use `integer` for general numeric data.
- Use `smallint` for smaller ranges of numeric data.
- Use `bigint` for larger ranges of numeric data.
- Use `decimal` or `numeric` for exact numeric data with fixed precision and scale.
- Use `real` or `double precision` for floating-point numbers.
- Use `varchar(n)` for variable-length strings, where `n` is the maximum length.
- Use `text` for long strings.
- Use `boolean` for true/false values.
- Use `date` for date values.
- Use `time` for time of day values.
- Use `timestamp` or `timestamptz` for date and time values.
- Use `json` or `jsonb` for JSON data.
- Use `uuid` for universally unique identifiers.
- Use `bytea` for binary data.

## SQL Command Syntax

### SELECT
```sql
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column1 ASC|DESC;
```

### INSERT
```sql
INSERT INTO table_name (column1, column2)
VALUES (value1, value2);
```

### UPDATE
```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

### DELETE
```sql
DELETE FROM table_name WHERE condition;
```

### CREATE INDEX
```sql
CREATE INDEX idx_table_column ON table_name (column);
```

### ALTER TABLE
```sql
ALTER TABLE table_name ADD column_name datatype;
```

### DROP TABLE
```sql
DROP TABLE table_name;
```

### DROP INDEX
```sql
DROP INDEX idx_table_column;
```

## Best Practices
- Always use transactions for operations that modify data.
- Use `EXPLAIN` to analyze query performance.
- Regularly vacuum and analyze your database to maintain performance.
- Avoid using `SELECT *`; specify the columns you need.
- Use prepared statements to prevent SQL injection.

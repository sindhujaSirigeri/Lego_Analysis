# LEGO SQL Analysis Project

## Overview
This project involved analyzing a dataset of LEGO sets using PostgreSQL to extract valuable insights about themes, parts, minifigures, colors, and relationships between LEGO elements. The dataset was processed through SQL scripts that created relational tables, defined constraints, and executed analytical queries.

📅 **The raw data was downloaded on 23-06-2025**  
🔗 **Source**: [Rebrickable Downloads](https://rebrickable.com/downloads/)

The project covered everything from cleaning raw data and defining relationships using foreign keys, to identifying trends in LEGO set releases, part usage, and color variations. The final database supports a rich and normalized schema optimized for querying and further exploration.

---

## Tools and Technologies Used

- **PostgreSQL**: Used for creating and managing the relational database.
- **SQL**: Used for writing all schema definitions, data transformations, constraints, and queries.
- **pgAdmin / psql CLI**: Used for interacting with the PostgreSQL database.
- **CSV Files**: Used as the source data format for importing LEGO datasets.
- **GitHub**: Repository for version control and project documentation.
- **Data Cleaning Tools**: Used to preprocess CSVs for type mismatches, malformed strings, and duplicates.

---

## Skills Learned

Throughout this project, I learned and applied the following skills:

- **Relational Schema Design**: Designed a normalized schema representing sets, parts, colors, minifigs, inventories, and themes.
- **Primary and Foreign Keys**: Practiced defining unique constraints and relationships across multiple tables.
- **Data Cleaning**: Handled malformed CSVs, removed duplicates, and resolved type mismatches before importing.
- **Constraint Debugging**: Learned how to identify and resolve errors related to constraint violations, like duplicate primary keys or missing foreign keys.
- **SQL Joins and Aggregation**: Used joins to combine tables and aggregate functions to perform analysis.
- **Data Deduplication**: Used SQL to identify and remove duplicate records to allow for constraint creation.
- **Database Optimization**: Built indexes through primary keys to support efficient querying.
- **Error Handling**: Interpreted and resolved PostgreSQL errors like `23505` (duplicate key) and `42830` (missing constraint).

---

## Project Tasks

- **Data Cleaning**: Cleaned the raw CSV files to fix issues such as:
  - Quoted string errors due to apostrophes.
  - Float values in integer fields (e.g., `"1.0"` in `parent_id`).
  - Duplicate rows preventing primary key assignment.

- **Schema Creation**:
  - Created 12 interrelated tables including `sets`, `parts`, `themes`, `colors`, `inventories`, and more.
  - Used `CREATE TABLE` and `ALTER TABLE` statements to define fields and relationships.
  - ![image](https://github.com/user-attachments/assets/964da86a-eba1-465b-8e39-e76cd9b432c6)


- **Primary Keys**:
  - Added unique identifiers to each table using `ALTER TABLE ... ADD PRIMARY KEY (...)`.
  - Simplified keys where duplicates existed by changing compound keys to single primary fields where possible.

- **Foreign Keys**:
  - Defined relationships across tables such as:
    - `part_cat_id` in `parts` → `part_categories(id)`
    - `theme_id` in `sets` → `themes(id)`
    - `set_num` in `inventories` → `sets(set_num)`
    - `part_num` in `inventory_parts` → `parts(part_num)` (after resolving duplicates)

- **Data Analysis**:
  - Counted the number of sets per theme.
  - Identified most used LEGO parts and most common colors.
  - Analyzed relationships between parent and child LEGO parts.
  - Measured growth in LEGO sets and themes over time.

- **Constraint Validation**:
  - Validated all relationships with `SELECT` queries to ensure foreign keys correctly map across tables.
  - Removed or consolidated duplicate records where necessary to allow constraint enforcement.

- **Error Troubleshooting**:
  - Investigated and resolved errors such as:
    - `duplicate key violates unique constraint`
    - `invalid input syntax for type integer`
    - `no unique constraint matching given keys for referenced table`

---

## Conclusion

This project provided comprehensive hands-on experience with SQL and relational database design using a real-world dataset. By importing and cleaning data, defining relationships with constraints, and performing detailed analysis, I developed a solid understanding of how to model and extract insights from complex datasets. These skills are highly applicable to any future work involving data engineering, analytics, or backend database management.



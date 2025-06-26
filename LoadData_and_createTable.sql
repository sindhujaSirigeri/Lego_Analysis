-- This script resets and rebuilds the LEGO-related tables, including element, 
-- theme, set, inventory, and part data, and removes duplicate records in the inventory_parts table.

-- Drop existing tables if they exist to avoid conflicts during recreation
DROP TABLE IF EXISTS inventory_parts;
DROP TABLE IF EXISTS inventory_minifigs;
DROP TABLE IF EXISTS inventory_sets;
DROP TABLE IF EXISTS inventories;
DROP TABLE IF EXISTS part_relationships;
DROP TABLE IF EXISTS elements;
DROP TABLE IF EXISTS parts;
DROP TABLE IF EXISTS part_categories;
DROP TABLE IF EXISTS minifigs;
DROP TABLE IF EXISTS sets;
DROP TABLE IF EXISTS themes;
DROP TABLE IF EXISTS colors;

-- Recreate core tables with necessary fields

CREATE TABLE elements (
    element_id VARCHAR(10),
    part_num VARCHAR(20),
    color_id VARCHAR,
    design_id NUMERIC
);

CREATE TABLE themes (
    id INT,
    name VARCHAR,
    parent_id NUMERIC
);

CREATE TABLE sets (
    set_num VARCHAR(20),
    name VARCHAR(256),
    year INT,
    theme_id INT,
    num_parts INT,
    img_url TEXT
);

CREATE TABLE inventories (
    id INT,
    version INT,
    set_num VARCHAR(20)
);

CREATE TABLE inventory_sets (
    inventory_id INT,
    set_num VARCHAR(20),
    quantity INT
);

CREATE TABLE minifigs (
    fig_num VARCHAR(20),
    name VARCHAR(256),
    num_parts INT,
    img_url VARCHAR
);

CREATE TABLE inventory_minifigs (
    inventory_id INT,
    fig_num VARCHAR(20),
    quantity INT
);

CREATE TABLE colors (
    id INT,
    name VARCHAR(200),
    rgb VARCHAR(10),
    is_trans BOOLEAN,
    num_part INT,
    num_sets INT,
    y1 VARCHAR,
    y2 VARCHAR
);

CREATE TABLE part_categories (
    id INT,
    name VARCHAR(200)
);

CREATE TABLE parts (
    part_num VARCHAR(20),
    name VARCHAR(250),
    part_cat_id INT,
    part_material VARCHAR
);

CREATE TABLE inventory_parts (
    inventory_id INT,
    part_num VARCHAR,
    color_id INT,
    quantity INT,
    is_spare BOOLEAN,
    img_url VARCHAR
);

CREATE TABLE part_relationships (
    rel_type VARCHAR(1),
    child_part_num VARCHAR(20),
    parent_part_num VARCHAR(20)
);

-- --- Deduplication process for inventory_parts ---

-- Step 1: Check for duplicate entries based on inventory_id, part_num, and color_id
SELECT inventory_id, part_num, color_id, COUNT(*) AS count
FROM inventory_parts
GROUP BY inventory_id, part_num, color_id
HAVING COUNT(*) > 1;

-- Step 2: Remove duplicates, keeping only the first instance (based on ctid, PostgreSQL internal row identifier)
DELETE FROM inventory_parts
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM inventory_parts
    GROUP BY inventory_id, part_num, color_id
);

-- Step 3: Confirm that only unique rows remain
SELECT *
FROM inventory_parts;

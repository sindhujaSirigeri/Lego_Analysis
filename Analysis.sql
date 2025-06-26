-- This script resets and rebuilds the LEGO analysis schema: it drops 
-- existing tables, recreates them, loads data from the public schema, 
-- and establishes primary/foreign keys to ensure relational integrity.


-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS analysis.inventory_parts;
DROP TABLE IF EXISTS analysis.inventory_minifigs;
DROP TABLE IF EXISTS analysis.inventory_sets;
DROP TABLE IF EXISTS analysis.inventories;
DROP TABLE IF EXISTS analysis.part_relationships;
DROP TABLE IF EXISTS analysis.elements;
DROP TABLE IF EXISTS analysis.parts;
DROP TABLE IF EXISTS analysis.part_categories;
DROP TABLE IF EXISTS analysis.minifigs;
DROP TABLE IF EXISTS analysis.sets;
DROP TABLE IF EXISTS analysis.themes;
DROP TABLE IF EXISTS analysis.colors;

-- Create dimension and fact tables
CREATE TABLE analysis.themes (
    id INT,
    name VARCHAR,
    parent_id NUMERIC
);

CREATE TABLE analysis.sets (
    set_num VARCHAR(20),
    name VARCHAR(256),
    year INT,
    theme_id INT,
    num_parts INT,
    img_url TEXT
);

CREATE TABLE analysis.inventories (
    id INT,
    version INT,
    set_num VARCHAR(20)
);

CREATE TABLE analysis.inventory_sets (
    inventory_id INT,
    set_num VARCHAR(20),
    quantity INT
);

CREATE TABLE analysis.minifigs (
    fig_num VARCHAR(20),
    name VARCHAR(256),
    num_parts INT,
    img_url VARCHAR
);

CREATE TABLE analysis.inventory_minifigs (
    inventory_id INT,
    fig_num VARCHAR(20),
    quantity INT
);

CREATE TABLE analysis.colors (
    id VARCHAR,
    name VARCHAR(200),
    rgb VARCHAR(10),
    is_trans BOOLEAN,
    num_part INT,
    num_sets INT,
    y1 VARCHAR,
    y2 VARCHAR
);

CREATE TABLE analysis.part_categories (
    id INT,
    name VARCHAR(200)
);

CREATE TABLE analysis.parts (
    part_num VARCHAR(20),
    name VARCHAR(250),
    part_cat_id INT,
    part_material VARCHAR
);

CREATE TABLE analysis.inventory_parts (
    inventory_id INT,
    part_num VARCHAR,
    color_id VARCHAR,
    quantity INT,
    is_spare BOOLEAN,
    img_url VARCHAR
);

CREATE TABLE analysis.part_relationships (
    rel_type VARCHAR(1),
    child_part_num VARCHAR(20),
    parent_part_num VARCHAR(20)
);

CREATE TABLE analysis.elements (
    element_id VARCHAR(10),
    part_num VARCHAR(20),
    color_id VARCHAR,
    design_id NUMERIC
);

-- Insert data from public schema
INSERT INTO analysis.colors SELECT * FROM public.colors;
INSERT INTO analysis.elements SELECT * FROM public.elements;
INSERT INTO analysis.inventories SELECT * FROM public.inventories;
INSERT INTO analysis.inventory_minifigs SELECT * FROM public.inventory_minifigs;
INSERT INTO analysis.inventory_parts SELECT * FROM public.inventory_parts;
INSERT INTO analysis.inventory_sets SELECT * FROM public.inventory_sets;
INSERT INTO analysis.minifigs SELECT * FROM public.minifigs;
INSERT INTO analysis.part_categories SELECT * FROM public.part_categories;
INSERT INTO analysis.part_relationships SELECT * FROM public.part_relationships;
INSERT INTO analysis.parts SELECT * FROM public.parts;
INSERT INTO analysis.sets SELECT * FROM public.sets;
INSERT INTO analysis.themes SELECT * FROM public.themes;

-- Primary keys
ALTER TABLE analysis.colors ADD PRIMARY KEY (id);
ALTER TABLE analysis.elements ADD PRIMARY KEY (element_id);
ALTER TABLE analysis.inventories ADD PRIMARY KEY (id);
ALTER TABLE analysis.minifigs ADD PRIMARY KEY (fig_num);
ALTER TABLE analysis.part_categories ADD PRIMARY KEY (id);
ALTER TABLE analysis.sets ADD PRIMARY KEY (set_num);
ALTER TABLE analysis.themes ADD PRIMARY KEY (id);

-- Fix data types for foreign key alignment
ALTER TABLE analysis.colors ALTER COLUMN id TYPE INT USING id::INTEGER;
ALTER TABLE analysis.elements ALTER COLUMN color_id TYPE INT USING color_id::INTEGER;
ALTER TABLE analysis.inventory_parts ALTER COLUMN color_id TYPE INT USING color_id::INTEGER;

-- Foreign keys between core tables
ALTER TABLE analysis.inventories ADD FOREIGN KEY (set_num) REFERENCES analysis.sets(set_num);
ALTER TABLE analysis.inventory_parts ADD FOREIGN KEY (inventory_id) REFERENCES analysis.inventories(id);
ALTER TABLE analysis.inventory_minifigs ADD FOREIGN KEY (inventory_id) REFERENCES analysis.inventories(id);
ALTER TABLE analysis.inventory_sets ADD FOREIGN KEY (inventory_id) REFERENCES analysis.inventories(id);
ALTER TABLE analysis.inventory_sets ADD FOREIGN KEY (set_num) REFERENCES analysis.sets(set_num);
ALTER TABLE analysis.inventory_minifigs ADD FOREIGN KEY (fig_num) REFERENCES analysis.minifigs(fig_num);
ALTER TABLE analysis.sets ADD FOREIGN KEY (theme_id) REFERENCES analysis.themes(id);

-- Add missing sets from inventories (if needed)
INSERT INTO analysis.sets (set_num, name, year, theme_id, num_parts)
SELECT DISTINCT i.set_num, NULL, NULL, NULL, NULL
FROM analysis.inventories i
LEFT JOIN analysis.sets s ON i.set_num = s.set_num
WHERE s.set_num IS NULL;

-- Add surrogate key to parts
ALTER TABLE analysis.parts ADD COLUMN id SERIAL PRIMARY KEY;

-- Map part_id in elements
ALTER TABLE analysis.elements ADD COLUMN part_id INT;

UPDATE analysis.elements e
SET part_id = p.id
FROM analysis.parts p
WHERE e.part_num = p.part_num;

ALTER TABLE analysis.elements
ADD CONSTRAINT elements_part_id_fkey
FOREIGN KEY (part_id) REFERENCES analysis.parts(id);

-- Map part_id in inventory_parts
ALTER TABLE analysis.inventory_parts ADD COLUMN part_id INT;

UPDATE analysis.inventory_parts ip
SET part_id = p.id
FROM analysis.parts p
WHERE ip.part_num = p.part_num;

ALTER TABLE analysis.inventory_parts
ADD CONSTRAINT inventory_parts_part_id_fkey
FOREIGN KEY (part_id) REFERENCES analysis.parts(id);

-- Add surrogate key to part_relationships
ALTER TABLE analysis.part_relationships ADD COLUMN id SERIAL PRIMARY KEY;

-- Link parts to part_relationships
ALTER TABLE analysis.parts ADD COLUMN part_relationship_id INT;

UPDATE analysis.parts p
SET part_relationship_id = pr.id
FROM (
  SELECT DISTINCT ON (parent_part_num)
         parent_part_num, id
  FROM analysis.part_relationships
  ORDER BY parent_part_num, id
) pr
WHERE p.part_cat_id::TEXT = pr.parent_part_num;

ALTER TABLE analysis.parts
ADD CONSTRAINT fk_part_relationship
FOREIGN KEY (part_relationship_id)
REFERENCES analysis.part_relationships(id);

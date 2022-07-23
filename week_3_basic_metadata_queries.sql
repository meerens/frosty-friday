-- week 3 / basic / metadata queries
-- challenge details & my documentation: https://www.craft.do/s/K03sY2JoJWQqAJ

-- set up the environment

USE DATABASE frosty_friday;

USE SCHEMA public;

-- load files to the stage

CREATE STAGE week3_basic
URL = 's3://frostyfridaychallenges/challenge_3/';

-- view the files inside the stage

LIST @week3_basic;

-- check keywords.csv to check for the keywords

SELECT 
metadata$filename AS file_name,
metadata$file_row_number AS file_row_numer,
$1,$2, $3, $4
FROM @week3_basic/keywords.csv;

-- checking what's inside one of 'data' files

SELECT 
metadata$filename AS file_name,
metadata$file_row_number AS number_of_rows,
$1 AS id,
$2 AS first_name,
$3 AS last_name,
$4 AS catch_phrase,
$5 AS timestamp
FROM @week3_basic/week3_data4_extra.csv;

-- creating a new file format

CREATE FILE FORMAT csv_frosty_skip_header
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

-- create tables

CREATE OR REPLACE TABLE w3_basic_raw (
 file_name VARCHAR,
 number_of_rows VARCHAR,
 id VARCHAR,
 first_name VARCHAR,
 last_name VARCHAR,
 catch_phrase VARCHAR,
 time_stamp VARCHAR  
);

CREATE OR REPLACE TABLE w3_basic_keywords (
file_name VARCHAR,
file_row_number VARCHAR,
keyword VARCHAR,
added_by VARCHAR,
nonsense VARCHAR
);

-- load data from stage to tables

COPY INTO w3_basic_keywords
FROM
(
  SELECT 
  metadata$filename AS file_name,
  metadata$file_row_number AS file_row_numer,
  t.$1 AS keyword,
  t.$2 AS added_by, 
  t.$3 AS nonsense
  FROM @week3_basic/keywords.csv AS t
)
FILE_FORMAT = 'csv_frosty_skip_header'
PATTERN = 'challenge_3/keywords.csv';


COPY INTO w3_basic_raw
FROM 
(
  SELECT
  metadata$filename AS file_name,
  metadata$file_row_number AS number_of_rows,
  t.$1 AS id,
  t.$2 AS first_name,
  t.$3 AS last_name,
  t.$4 AS catch_phrase,
  t.$5 AS timestamp
  FROM @week3_basic AS t
)
FILE_FORMAT = 'csv_frosty_skip_header';

-- check the raw table

SELECT * FROM w3_basic_raw;

SELECT * FROM w3_basic_keywords;

-- create a view for the keyword files 

CREATE OR REPLACE VIEW w3_keywordfiles
AS
SELECT
file_name,
COUNT(*) AS number_of_rows
FROM w3_basic_raw
WHERE EXISTS 
(
  SELECT keyword
  FROM w3_basic_keywords
  WHERE CONTAINS (w3_basic_raw.file_name,w3_basic_keywords.keyword)
)
GROUP BY file_name;

-- check the view and create the final output

SELECT * FROM w3_keywordfiles;








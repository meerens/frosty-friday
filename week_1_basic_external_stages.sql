-- week 1 / basic / external stages
-- challenge details & my documentation: https://www.craft.do/s/E9OzQH5LblhUHt

-- create database

CREATE DATABASE frosty_friday;

-- create external stage

USE DATABASE frosty_friday;
USE SCHEMA public;

CREATE STAGE week1_basic
URL = 's3://frostyfridaychallenges/challenge_1/';

-- view files in the stage

LIST @week1_basic;

-- querying the stage to see what's in there

SELECT 
metadata$filename,
metadata$file_row_number, 
t.$1, t.$2, t.$3
FROM @week1_basic AS t;


-- create file format for loading the stage into the table

CREATE FILE FORMAT csv_frosty
TYPE = 'CSV'
FIELD_DELIMITER = ',';

-- create table


CREATE TABLE w1_basic (
  column_1 VARCHAR
);

-- load data from stage to table

COPY INTO w1_basic 
FROM @week1_basic;

-- check table

SELECT * 
FROM w1_basic;




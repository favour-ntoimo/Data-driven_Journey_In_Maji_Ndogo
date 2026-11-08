/* 1. Getting to know the data*/

SHOW TABLES;

-- the first five records from each table.

-- i. data_dictionary
SELECT *
FROM data_dictionary
LIMIT 5;

-- ii. employee
SELECT *
FROM employee
LIMIT 5;

-- iii. global_water_access
SELECT *
FROM global_water_access
LIMIT 5;

-- iv. location
SELECT *
FROM location
LIMIT 5;

-- v. visits 
SELECT *
FROM visits
LIMIT 5;

-- vi. water_quality
SELECT *
FROM water_quality
LIMIT 5;

-- vii. water source
SELECT *
FROM water_source
LIMIT 5;

-- viii. well_pollution
SELECT *
FROM well_pollution
LIMIT 5;

-- data_dictionary
 SELECT *
 FROM data_dictionary;
 
 /* 2. type of water source*/

 SELECT DISTINCT
	type_of_water_source
 FROM water_source;
 
 /* 3. visits to water source*/
 
 -- type of water source with time_in_queue over 500 mins. 
SELECT *
FROM visits
WHERE time_in_queue > 500;

-- the details of the first 10 rows of the visit table
 SELECT *
 FROM visits
 LIMIT 10;
 
 -- water_source details for the specific source_ids.
 SELECT *
 FROM water_source
 WHERE source_id IN ( 'AkKi00881224' , 'SoRu37635224' , 
	'SoRu36096224' ,  'HaZa21742224' );
    
-- 
SELECT *
FROM water_source;

/* 4. Assessing the quality of water sources */

-- where the subject_quality_score is only 10 looking for home taps and where the source was visited a second time. 
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;

/* 5. Investigate pollution issues */
 
-- i. well_pollution first 10 results 
SELECT *
FROM well_pollution
LIMIT 10;

--  ii. where the results is Clean but the biological column is > 0.01.
SELECT *
FROM well_pollution
WHERE results = "Clean" AND biological > 0.01;

--  iii. Records that have the word Clean with additional characters after it. 
SELECT *
FROM well_pollution
WHERE description LIKE "clean_%";

-- create a copy of well_pollution to test the update
-- CREATE TABLE md_water_services.well_pollution_copy AS 
-- (SELECT * FROM md_water_services.well_pollution_copy);

-- Case 1: Update descriptions that mistakenly mention`Clean Bacteria: E. coli` to `Bacteria: E. coli`
SET SQL_SAFE_UPDATES = 0;

UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Confirmation that the above Upadte worked 
SELECT *
FROM md_water_services.well_pollution_copy
WHERE description = 'Bacteria: E. coli'

-- Case 1b: Update the descriptions that mistakenly mention `Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
-- SET SQL_SAFE_UPDATES = 0;

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Confirmation that the above Upadte worked 
SELECT *
FROM well_pollution_copy
WHERE description = 'Bacteria: Giardia Lamblia';

-- Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results is `Clean
-- SET SQL_SAFE_UPDATES = 0;

UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

-- Confirmation that the above Upadte worked 
SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
 OR (results = 'Clean' AND biological > 0.01);

-- drop the table oncce verified 
DROP TABLE md_water_services.well_pollution_copy;
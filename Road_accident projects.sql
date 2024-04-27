CREATE SCHEMA accidents;

USE accidents;

/* -------------------------------- */
/* Create Tables */
CREATE TABLE accident(
	accident_index VARCHAR(13),
    accident_severity INT
);

CREATE TABLE vehicles(
	accident_index VARCHAR(13),
    vehicle_type VARCHAR(50)
);
-- DROP TABLE IF EXISTS vehicle_types;

/* First: for vehicle types, create new csv by extracting data from Vehicle Type sheet from Road-Accident-Safety-Data-Guide.xls */
CREATE TABLE IF NOT EXISTS vehicle_types (
    vehicle_code INT,
    vehicle_type VARCHAR(50)
);


/* -------------------------------- */
/* Load Data */
LOAD DATA LOCAL INFILE 'C:\\Users\\HP\\Music\\projects_bytannu\\Accidents_2015.csv'
INTO TABLE accident
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @dummy, @dummy, @dummy, @dummy, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1, accident_severity=@col2;


LOAD DATA LOCAL INFILE 'C:\\Users\\HP\\Music\\projects_bytannu\\Vehicles_2015.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @dummy, @col2, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET accident_index=@col1, vehicle_type=@col2;


LOAD DATA LOCAL INFILE 'C:\\Users\\HP\\Music\\projects_bytannu\\vehicle_types.csv'
INTO TABLE vehicle_types
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

/* -------------------------------- */


select * from accident;

select * from vehicles;

select * from vehicle_types;

-- 1. Evaluate the median severity value of accidents caused by various Motorcycles.
create table accidents_median(
vehicle_types varchar(100),
severity int);

select vehicle_type from vehicle_types where vehicle_type like '%torcycle%';
-------- median severity calculation ---------------
SELECT 
    vehicle_type,
    AVG(median_severity) AS median_severity
FROM (
    SELECT 
        vt.vehicle_type,
        a.accident_severity AS median_severity,
        ROW_NUMBER() OVER (PARTITION BY vt.vehicle_type ORDER BY a.accident_severity) AS row_num,
        COUNT(*) OVER (PARTITION BY vt.vehicle_type) AS total_rows
    FROM 
        accident a
    JOIN 
        vehicles v ON a.accident_index = v.accident_index
    JOIN 
        vehicle_types vt ON v.vehicle_type = vt.vehicle_code
    WHERE 
        vt.vehicle_type LIKE '%motorcycle%'
) AS subquery
WHERE 
    row_num IN (CEILING(total_rows/2), FLOOR(total_rows/2) + 1)
GROUP BY 
    vehicle_type;
/* SELECT 
        vt.vehicle_type,
        a.accident_severity AS median_severity,
        ROW_NUMBER() OVER (PARTITION BY vt.vehicle_type ORDER BY a.accident_severity) AS row_num,
        COUNT(*) OVER (PARTITION BY vt.vehicle_type) AS total_rows
    FROM 
        accident a
    JOIN 
        vehicles v ON a.accident_index = v.accident_index
    JOIN 
        vehicle_types vt ON v.vehicle_type = vt.vehicle_code
    WHERE 
        vt.vehicle_type LIKE '%motorcycle%';*/
select `Vehicle Type`, Severity,`index`from( select v.vehicle_type AS 'Vehicle Type', 
       a.accident_severity AS 'Severity', a.accident_index as 'index'
       FROM accident a 
JOIN vehicles v ON a.accident_index = v.accident_index ) AS subquery WHERE subquery.`Vehicle Type` = 23;

CREATE INDEX accident_index
ON accident(accident_index);

CREATE INDEX accident_index
ON vehicles(accident_index);

-- 2. Evaluate Accident Severity and Total Accidents per Vehicle Type

SELECT vt.vehicle_type AS 'Vehicle Type', 
       a.accident_severity AS 'Severity', 
       COUNT(vt.vehicle_type) AS 'Number of Accidents' 
FROM accident a 
JOIN vehicles v ON a.accident_index = v.accident_index 
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code 
GROUP BY vt.vehicle_type, a.accident_severity 
ORDER BY 2, 3;



/* select sum(total_accidents) from(
SELECT vt.vehicle_type, COUNT(*) AS total_accidents
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code
GROUP BY vt.vehicle_type) AS subquery;*/

-- 3. Calculate the Average Severity by vehicle type.

SELECT vt.vehicle_type, AVG(a.accident_severity) AS avg_severity
FROM accident a
JOIN vehicles v ON a.accident_index = v.accident_index
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code
GROUP BY vt.vehicle_type;


-- 4. Calculate the Average Severity and Total Accidents by Motorcycle.

SELECT vt.vehicle_type AS 'Vehicle Type', 
       AVG(a.accident_severity) AS 'Average Severity', 
       COUNT(vt.vehicle_type) AS 'Total accidents' 
FROM accident a 
JOIN vehicles v ON a.accident_index = v.accident_index 
JOIN vehicle_types vt ON v.vehicle_type = vt.vehicle_code 
GROUP BY 1
ORDER BY 2, 3;


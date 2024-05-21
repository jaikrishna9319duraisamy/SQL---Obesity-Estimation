CREATE DATABASE ObesityAnalysis;
USE ObesityAnalysis;

CREATE TABLE ObesityData (
	PersonID INT AUTO_INCREMENT PRIMARY KEY,
    Gender ENUM('Female', 'Male'),
    Age INT,
    Height FLOAT,
    Weight FLOAT,
    FamilyHistory ENUM('Yes', 'No'),
    FAVC ENUM('Yes', 'No'),
    FCVC INT,
    NCP INT,
    CAEC ENUM('No', 'Sometimes', 'Frequently', 'Always'),
    SMOKE ENUM('Yes', 'No'),
    CH2O INT,
    SCC ENUM('Yes', 'No'),
    FAF INT,
    TUE INT,
    CALC ENUM('No', 'Sometimes', 'Frequently', 'Always'),
    MTRANS ENUM('Automobile', 'Motorbike', 'Bike', 'Public_Transportation', 'Walking'),
    NObeyesdad ENUM('Insufficient_Weight', 'Normal_Weight', 'Overweight_Level_I', 'Overweight_Level_II', 'Obesity_Type_I', 'Obesity_Type_II', 'Obesity_Type_III')
);
select * from obesitydata;

-- Create the sub-tables
-- Demographics: Contains personal information.
-- PhysicalAttributes: Contains physical measurements.
-- EatingHabits: Contains information about eating habits and preferences.
-- Lifestyle: Contains lifestyle and activity information.
-- HealthMonitoring: Contains information about health monitoring habits.
-- ObesityLevel: Contains the obesity classification.

CREATE TABLE Demographics (
    PersonID INT PRIMARY KEY,
    Gender ENUM('Female', 'Male'),
    Age INT,
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

CREATE TABLE PhysicalAttributes (
    PersonID INT PRIMARY KEY,
    Height FLOAT,
    Weight FLOAT,
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

CREATE TABLE EatingHabits (
    PersonID INT PRIMARY KEY,
    FamilyHistory ENUM('Yes', 'No'),
    FAVC ENUM('Yes', 'No'),
    FCVC INT,
    NCP INT,
    CAEC ENUM('No', 'Sometimes', 'Frequently', 'Always'),
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

CREATE TABLE Lifestyle (
    PersonID INT PRIMARY KEY,
    SMOKE ENUM('Yes', 'No'),
    CH2O INT,
    FAF INT,
    TUE INT,
    CALC ENUM('No', 'Sometimes', 'Frequently', 'Always'),
    MTRANS ENUM('Automobile', 'Motorbike', 'Bike', 'Public_Transportation', 'Walking'),
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

CREATE TABLE HealthMonitoring (
    PersonID INT PRIMARY KEY,
    SCC ENUM('Yes', 'No'),
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

CREATE TABLE ObesityLevel (
    PersonID INT PRIMARY KEY,
    NObeyesdad ENUM('Insufficient_Weight', 'Normal_Weight', 'Overweight_Level_I', 'Overweight_Level_II', 'Obesity_Type_I', 'Obesity_Type_II', 'Obesity_Type_III'),
    FOREIGN KEY (PersonID) REFERENCES ObesityData(PersonID)
);

-- Populates the tables
INSERT INTO Demographics (PersonID, Gender, Age)
SELECT PersonID, Gender, Age
FROM ObesityData;

INSERT INTO PhysicalAttributes (PersonID, Height, Weight)
SELECT PersonID, Height, Weight
FROM ObesityData;

INSERT INTO EatingHabits (PersonID, FamilyHistory, FAVC, FCVC, NCP, CAEC)
SELECT PersonID, FamilyHistory, FAVC, FCVC, NCP, CAEC
FROM ObesityData;

INSERT INTO Lifestyle (PersonID, SMOKE, CH2O, FAF, TUE, CALC, MTRANS)
SELECT PersonID, SMOKE, CH2O, FAF, TUE, CALC, MTRANS
FROM ObesityData;

INSERT INTO HealthMonitoring (PersonID, SCC)
SELECT PersonID, SCC
FROM ObesityData;

INSERT INTO ObesityLevel (PersonID, NObeyesdad)
SELECT PersonID, NObeyesdad
FROM ObesityData;





select * from physicalattributes;
select * from obesitylevel;
select * from obesitydata;
select * from lifestyle;
select * from healthmonitoring;
select * from eatinghabits;
select * from demographics;
-- ====================================================================================================
-- 1. What is the count of genders and their average age based on types of Obesity levels ? 
select * from obesitylevel;
select * from demographics;
SELECT ol.NObeyesdad,d.Gender,ceil(AVG(d.Age)) as AverageAge, count(*) as count
FROM ObesityLevel ol
JOIN Demographics d ON ol.PersonID = d.PersonID
GROUP BY ol.NObeyesdad, d.Gender;
-- =========================================================================================================
-- 2. What is the distribution count of induiduals on obesity levels who has a obesity in their FamilyHistory ? 
select * from obesitylevel;
select * from demographics;
select * from eatinghabits;
SELECT eh.FamilyHistory, ol.NObeyesdad, COUNT(*) as Count,d.Gender,d.Age
FROM EatingHabits eh
JOIN ObesityLevel ol ON eh.PersonID = ol.PersonID
JOIN demographics d on ol.PersonID = d.PersonID
where eh.FamilyHistory='yes'
GROUP BY eh.FamilyHistory, ol.NObeyesdad,d.Gender,d.age;
-- ================================================================================================================
-- 3. What is the percentage of induviduals who smoke based on teir Obesity levels ?
select * from obesitylevel;
select * from lifestyle;
SELECT l.smoke, ol.NObeyesdad,(COUNT(CASE WHEN SMOKE = 'yes' THEN 1 END) / COUNT(*)) * 100 AS PercentageSmokers
FROM Lifestyle l
JOIN ObesityLevel ol ON l.PersonID = ol.PersonID
where l.smoke="yes"
GROUP BY l.SMOKE, ol.NObeyesdad;
-- ==================================================================================================================
-- 4.	What is the most common mode of transportation among the individuals?
select * from lifestyle;
SELECT MTRANS, count(*)
from lifestyle
group by Mtrans
order by count(*) desc
limit 1;
-- =====================================================================================================================
-- 5. What is the top 3 obesity levels and their count who uses public transportation? 
select * from obesitylevel;
select * from lifestyle;
WITH ranked_Table as (
SELECT l.MTRANS, ol.NObeyesdad, COUNT(*) as Count, dense_rank()over (order by COUNT(*) desc) as rnk
FROM Lifestyle l
JOIN ObesityLevel ol ON l.PersonID = ol.PersonID
GROUP BY l.MTRANS, ol.NObeyesdad   )
select MTRANS,NObeyesdad,count,rnk
from ranked_Table
where rnk<=3
order by count desc;
-- ===========================================================================================================================

-- -- 6. 
-- SELECT
--         AVG(Height) AS mean_height,
--         AVG(Weight) AS mean_weight
--     FROM
--         obesitydata;
--         -- ===============================================================
--  WITH means AS (
--     SELECT
--         AVG(Height) AS mean_height,
--         AVG(Weight) AS mean_weight
--     FROM
--         obesitydata
-- ),
-- correlation_data AS (
--     SELECT
--         Height,
--         Weight,
--         (Height - means.mean_height) AS height_diff,
--         (Weight - means.mean_weight) AS weight_diff
--     FROM
--         obesitydata,
--         means
-- )
-- SELECT
--     SUM(height_diff * weight_diff) /
--     (SQRT(SUM(POW(height_diff, 2))) * SQRT(SUM(POW(weight_diff, 2)))) AS Correlation
-- FROM
--     correlation_data;
--     -- =============================================================================================
--     SELECT
--         pa.Height,
--         pa.Weight,
--         ol.NObeyesdad
--     FROM
--         physicalattributes pa
--     JOIN
--         obesitylevel ol ON pa.PersonID = ol.PersonID
--         group by ol.NObeyesdad, pa.height,pa.weight;
--         -- STep -2 
--         SELECT
--         ol.NObeyesdad,
--         AVG(Height) AS mean_height,
--         AVG(Weight) AS mean_weight
--         
--     FROM
--         physicalattributes pa
--         JOIN
--         obesitylevel ol ON pa.PersonID = ol.PersonID
--     GROUP BY
--         NObeyesdad;
--         -- ====================================================================
--         -- Step 3:
--         SELECT
--         ol.NObeyesdad,
--         pa.Height,
--         pa.Weight,
--         (pa.Height - avg(pa.height)) AS height_diff,
--         (pa.Weight - avg(pa.weight)) AS weight_diff
--     FROM
--         physicalattributes pa
--     JOIN
--         obesitylevel ol ON pa.PersonID = ol.PersonID
--         GROUP BY
--         ol.NObeyesdad;
        -- =======================================================================================
-- 6. What is the Average height and weight by gender based on obesity level
select * from demographics;
Select * from PhysicalAttributes;
Select * from ObesityLevel;
SELECT d.Gender, ol.NObeyesdad, AVG(pa.Height) as AverageHeight, AVG(pa.Weight) as AverageWeight
FROM PhysicalAttributes pa
JOIN Demographics d ON pa.PersonID = d.PersonID
JOIN ObesityLevel ol ON pa.PersonID = ol.PersonID
GROUP BY d.Gender, ol.NObeyesdad;
-- =======================================================================================================
-- 7. What is the pearson corelation for each obesity level based on induvidual height and weight ?
   WITH joined_data AS (
    SELECT
        pa.PersonID,
        pa.Height,
        pa.Weight,
        ol.NObeyesdad
    FROM
        physicalattributes pa
    JOIN
        obesitylevel ol ON pa.PersonID = ol.PersonID
),
means AS (
    SELECT
        NObeyesdad,
        AVG(Height) AS mean_height,
        AVG(Weight) AS mean_weight
    FROM
        joined_data
    GROUP BY
        NObeyesdad
),
correlation_data AS (
    SELECT
        jd.NObeyesdad,
        jd.Height,
        jd.Weight,
        m.mean_height,
        m.mean_weight,
        (jd.Height - m.mean_height) AS height_diff,
        (jd.Weight - m.mean_weight) AS weight_diff
    FROM
        joined_data jd
    JOIN
        means m ON jd.NObeyesdad = m.NObeyesdad
)
SELECT
    NObeyesdad,
    mean_height,
    mean_weight,
    SUM(height_diff * weight_diff) /
    (SQRT(SUM(POW(height_diff, 2))) * SQRT(SUM(POW(weight_diff, 2)))) AS Correlation
FROM
    correlation_data
GROUP BY
    NObeyesdad, mean_height, mean_weight;
    -- ==========================================================================
-- 8. what is the distribution in Water consumption based on obesity levels ?
DELIMITER $$
CREATE PROCEDURE water_Tracking(IN H2O INT, IN obesity_level VARCHAR(60), IN count__ INT)
BEGIN
    SELECT l.CH2O, ol.NObeyesdad, COUNT(*) AS Count
    FROM Lifestyle l
    JOIN ObesityLevel ol ON l.PersonID = ol.PersonID
    WHERE (l.CH2O >= 3 OR l.CH2O <= 1)
    AND ol.NObeyesdad = obesity_level
    GROUP BY l.CH2O, ol.NObeyesdad
    HAVING COUNT(*) >= count__;
END $$

DELIMITER ;

call water_Tracking(3,"Obesity_Type_I",5);
call water_Tracking(3,"Normal_Weight",5);
call water_Tracking(3,'Overweight_Level_II',5);



-- =====================================================================================================
-- --9.  High-caloric food consumption by obesity level
create view High_Caloric_Tracker as SELECT eh.FAVC, ol.NObeyesdad, COUNT(*) as Count
FROM EatingHabits eh
JOIN ObesityLevel ol ON eh.PersonID = ol.PersonID
GROUP BY eh.FAVC, ol.NObeyesdad;
-- ===========================================================================================================
-- 10. Wat is the physical activity frequency by obesity level ?
SELECT ol.NObeyesdad, l.FAF, COUNT(*) as Count
FROM Lifestyle l
JOIN ObesityLevel ol ON l.PersonID = ol.PersonID
GROUP BY ol.NObeyesdad, l.FAF;
-- ================================================================================================================




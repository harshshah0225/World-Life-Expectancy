# World Life Expectancy Project (Data Cleaning)

SELECT *
FROM world_life_expectancy;

# Identifying & Removing Duplicates
SELECT Country, Year, 
	CONCAT(Country, Year), 
    COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

SELECT *
FROM(
    SELECT Row_ID, CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1;

DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
		SELECT Row_ID
	FROM(
		SELECT Row_ID, CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
		FROM world_life_expectancy
		) AS Row_Table
	WHERE Row_Num > 1 );

# Filling in missing values

# Status
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = "Developing"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developing";

# Updated
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = "Developed"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developed";

# Verified
SELECT *
FROM world_life_expectancy
WHERE Status = "";

# Life Expectancy
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
	t2.Country, t2.Year, t2.`Life expectancy`,
    t3.Country, t3.Year, t3.`Life expectancy`,
    ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = "";

# Updated 
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = "";

# Verified
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = "";


# World Life Expectancy Project (Exploratory Data Analysis)
# Life Expectancy Increase in 15 years
SELECT Country, 
	MIN(`Life expectancy`), 
	MAX(`Life expectancy`),
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15Years;

# Average Life Expectancy in a year
SELECT Year, ROUND(AVG(`Life expectancy`), 2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

# Correlation between GDP and Average Life Expectancy
SELECT Country, ROUND(AVG(`Life expectancy`), 1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC;


SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END), 2) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END), 2) Low_GDP_Life_Expectancy
FROM world_life_expectancy;

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status;

# Rolling Count of Adult Mortality
SELECT Country, Year, `Life expectancy`, `Adult Mortality`, 
	SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;

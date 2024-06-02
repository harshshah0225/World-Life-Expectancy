# World Life Expectancy Data Cleaning and Analysis Project

 ## Project Overview
 This project involves cleaning a dataset related to world life expectancy and performing exploratory data analysis (EDA) to uncover insights and patterns. The primary tasks include identifying and removing duplicate records, filling in missing values for key fields, ensuring data consistency, and conducting EDA to visualize and understand the data.

 ## Files
 - WorldLifeExpectancy.sql: Contains the SQL script used for data cleaning and exploratory data analysis.
 - WorldLifeExpectancy.csv: Contains the actual dataset that was fetched within the schema.

## Data Cleaning Steps
1. Identifying and Removing Duplicates

Duplicates in the dataset are identified based on a combination of Country and Year. The script counts occurrences of each combination and removes any duplicate records.
``` sql
-- Identify duplicates
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Remove duplicates
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_Table
    WHERE Row_Num > 1
);
```
2. Filling in Missing Values
### Status

The Status field, which indicates whether a country is "Developed" or "Developing", is filled based on existing data for each country.
``` sql
-- Fill missing 'Developing' status
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country
SET t1.Status = "Developing"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developing";

-- Fill missing 'Developed' status
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country
SET t1.Status = "Developed"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developed";
```

### Life Expectancy

The Life expectancy field is filled by averaging the life expectancy of the previous and next years for each country.
``` sql
-- Fill missing 'Life expectancy'
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = "";
```

3. Verification

After filling in the missing values, verification steps are included to ensure that no records with empty Status fields remain.
``` sql
-- Verify no empty 'Status' fields
SELECT * FROM world_life_expectancy WHERE Status = "";
```

## Exploratory Data Analysis (EDA)
1. Overview of Life Expectancy

The EDA starts with summarizing the life expectancy data across different countries and years to identify general trends and outliers.
``` sql
-- Summary statistics for life expectancy
SELECT MIN(`Life expectancy`), MAX(`Life expectancy`), AVG(`Life expectancy`)
FROM world_life_expectancy;
```
2. Life Expectancy by Region

Analyze life expectancy trends by countries to identify geographical patterns.
```sql
-- Life expectancy by region
SELECT Country, AVG(`Life expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Country
ORDER BY Avg_Life_Expectancy DESC;
```

3. Developed vs. Developing Countries

Compare life expectancy trends between developed and developing countries.
```sql
-- Life expectancy comparison
SELECT Status, AVG(`Life expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status
ORDER BY Avg_Life_Expectancy DESC;
```

4. Temporal Analysis

Analyze changes in life expectancy over time to identify trends and patterns.
```sql
-- Life expectancy over time
SELECT Year, AVG(`Life expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Year
ORDER BY Year;
```

5. Visualization

Visualizations are created to better understand the data. Common visualizations include line plots for temporal analysis, bar charts for comparisons, and heat maps for geographical patterns. Here are examples of SQL queries for generating data that can be visualized using tools like Python's matplotlib or seaborn.
```sql
-- Data for line plot of life expectancy over time
SELECT Year, AVG(`Life expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Year
ORDER BY Year;

-- Data for bar chart comparing developed and developing countries
SELECT Status, AVG(`Life expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status
ORDER BY Avg_Life_Expectancy DESC;
```

## How To Run

1. Load the **WorldLifeExpectancy.csv** dataset into your SQL environment.
2. Execute the SQL script contained in **WorldLifeExpectancy.sql**.

## Conclusion

By following these steps, the dataset is cleaned and analyzed, providing valuable insights into global life expectancy trends. The data cleaning process ensures data integrity and completeness, while the EDA uncovers patterns and trends essential for understanding and improving global health outcomes.

-- ============================================================
-- UK Road Safety Analysis 2025
-- Author: Ali Hazem
-- Source: Department for Transport (data.gov.uk)
-- Period: January to May 2025 (provisional)
-- Business Question 1: When and where do the most serious 
-- collisions occur and what conditions are associated with 
-- fatal and serious casualties?
-- Business Question 2: Which vehicle types, driver profiles,
-- and road characteristics present the highest risk of fatal
-- outcomes and where should interventions be prioritised?
-- ============================================================


-- ============================================================
-- SECTION 1: DATA EXPLORATION
-- Understanding the shape and quality of all three tables
-- ============================================================

-- 1.1 Row counts across all three tables
SELECT 'collisions' AS table_name, COUNT(*) AS row_count FROM collisions
UNION ALL
SELECT 'casualties', COUNT(*) FROM casualties
UNION ALL
SELECT 'vehicles', COUNT(*) FROM vehicles;

-- 1.2 Collision severity breakdown
-- 1 = Fatal, 2 = Serious, 3 = Slight
SELECT
    CASE collision_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
        ELSE 'Unknown'
    END AS severity,
    COUNT(*) AS total_collisions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM collisions), 1) AS percentage
FROM collisions
GROUP BY collision_severity
ORDER BY collision_severity;

-- 1.3 Casualty severity breakdown
-- 1 = Fatal, 2 = Serious, 3 = Slight
SELECT
    CASE casualty_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
        ELSE 'Unknown'
    END AS severity,
    COUNT(*) AS total_casualties,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM casualties), 1) AS percentage
FROM casualties
GROUP BY casualty_severity
ORDER BY casualty_severity;

-- 1.4 Urban vs Rural split
-- 1 = Urban, 2 = Rural
SELECT
    CASE urban_or_rural_area
        WHEN 1 THEN 'Urban'
        WHEN 2 THEN 'Rural'
        ELSE 'Unclassified'
    END AS area_type,
    COUNT(*) AS collisions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM collisions), 1) AS percentage
FROM collisions
GROUP BY urban_or_rural_area
ORDER BY collisions DESC;

-- 1.5 Check data quality: missing values in key columns
SELECT
    SUM(CASE WHEN collision_severity IS NULL THEN 1 ELSE 0 END) AS missing_severity,
    SUM(CASE WHEN speed_limit IS NULL THEN 1 ELSE 0 END) AS missing_speed_limit,
    SUM(CASE WHEN road_type IS NULL THEN 1 ELSE 0 END) AS missing_road_type,
    SUM(CASE WHEN weather_conditions IS NULL THEN 1 ELSE 0 END) AS missing_weather,
    SUM(CASE WHEN light_conditions IS NULL THEN 1 ELSE 0 END) AS missing_light,
    SUM(CASE WHEN latitude IS NULL THEN 1 ELSE 0 END) AS missing_location
FROM collisions;

-- 1.6 Date range confirmation
SELECT
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    COUNT(DISTINCT date) AS days_covered
FROM collisions;

-- ============================================================
-- SECTION 2: TEMPORAL ANALYSIS
-- When do the most serious collisions occur?
-- Answering Business Question 1
-- ============================================================

-- 2.1 Collisions by day of week with severity breakdown
-- 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday,
-- 5 = Thursday, 6 = Friday, 7 = Saturday
SELECT
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) AS slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM collisions
GROUP BY day_of_week
ORDER BY day_of_week;

-- 2.2 Collisions by hour of day
-- Identifying peak danger hours across all severity levels
SELECT
    CAST(SUBSTR(time, 1, 2) AS INTEGER) AS hour_of_day,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(SUM(CASE WHEN collision_severity IN (1,2) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS serious_or_fatal_pct
FROM collisions
WHERE time IS NOT NULL AND time != ''
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 2.3 Monthly trend across January to May 2025
SELECT
    CASE CAST(SUBSTR(date, 4, 2) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
    END AS month_name,
    CAST(SUBSTR(date, 4, 2) AS INTEGER) AS month_num,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM collisions), 1) AS pct_of_total
FROM collisions
GROUP BY month_num
ORDER BY month_num;

-- 2.4 Most dangerous time windows
-- Combining day of week and hour to find highest risk periods
SELECT
    CASE day_of_week
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    CAST(SUBSTR(time, 1, 2) AS INTEGER) AS hour_of_day,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal_collisions
FROM collisions
WHERE time IS NOT NULL AND time != ''
GROUP BY day_of_week, hour_of_day
HAVING COUNT(*) >= 50
ORDER BY fatal_collisions DESC
LIMIT 15;

-- ============================================================
-- SECTION 3: ENVIRONMENTAL CONDITIONS ANALYSIS
-- What conditions are most associated with serious casualties?
-- Completing Business Question 1
-- ============================================================

-- 3.1 Collision severity by weather conditions
-- 1=Fine no wind, 2=Raining no wind, 3=Snowing no wind,
-- 4=Fine with wind, 5=Raining with wind, 6=Snowing with wind,
-- 7=Fog or mist, 8=Other, 9=Unknown, -1=Data missing
SELECT
    CASE weather_conditions
        WHEN 1 THEN 'Fine - No Wind'
        WHEN 2 THEN 'Raining - No Wind'
        WHEN 3 THEN 'Snowing - No Wind'
        WHEN 4 THEN 'Fine - With Wind'
        WHEN 5 THEN 'Raining - With Wind'
        WHEN 6 THEN 'Snowing - With Wind'
        WHEN 7 THEN 'Fog or Mist'
        WHEN 8 THEN 'Other'
        ELSE 'Unknown'
    END AS weather,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM collisions
WHERE weather_conditions NOT IN (-1, 9)
GROUP BY weather_conditions
ORDER BY fatal_rate_pct DESC;

-- 3.2 Collision severity by light conditions
-- 1=Daylight, 4=Darkness lights lit, 5=Darkness lights unlit,
-- 6=Darkness no lighting, 7=Darkness lighting unknown
SELECT
    CASE light_conditions
        WHEN 1 THEN 'Daylight'
        WHEN 4 THEN 'Darkness - Lights Lit'
        WHEN 5 THEN 'Darkness - Lights Unlit'
        WHEN 6 THEN 'Darkness - No Lighting'
        WHEN 7 THEN 'Darkness - Lighting Unknown'
        ELSE 'Unknown'
    END AS light_condition,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM collisions
WHERE light_conditions != -1
GROUP BY light_conditions
ORDER BY fatal_rate_pct DESC;

-- 3.3 Collision severity by speed limit
-- Shows relationship between speed limit and fatal outcomes
SELECT
    speed_limit,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN collision_severity = 2 THEN 1 ELSE 0 END) AS serious,
    SUM(CASE WHEN collision_severity = 3 THEN 1 ELSE 0 END) AS slight,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct,
    ROUND(SUM(CASE WHEN collision_severity IN (1,2) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS serious_or_fatal_pct
FROM collisions
WHERE speed_limit > 0
GROUP BY speed_limit
ORDER BY speed_limit;

-- 3.4 Road surface conditions and severity
-- 1=Dry, 2=Wet or damp, 3=Snow, 4=Frost or ice,
-- 5=Flood, 6=Oil or diesel, 7=Mud, -1=Data missing
SELECT
    CASE road_surface_conditions
        WHEN 1 THEN 'Dry'
        WHEN 2 THEN 'Wet or Damp'
        WHEN 3 THEN 'Snow'
        WHEN 4 THEN 'Frost or Ice'
        WHEN 5 THEN 'Flood'
        WHEN 6 THEN 'Oil or Diesel'
        WHEN 7 THEN 'Mud'
        ELSE 'Unknown'
    END AS road_surface,
    COUNT(*) AS total_collisions,
    SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    ROUND(SUM(CASE WHEN collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM collisions
WHERE road_surface_conditions != -1
GROUP BY road_surface_conditions
ORDER BY fatal_rate_pct DESC;

-- 3.5 Combined risk profile
-- Weather and light conditions combined to identify highest risk scenarios
SELECT
    CASE weather_conditions
        WHEN 1 THEN 'Fine'
        WHEN 2 THEN 'Raining'
        WHEN 4 THEN 'Fine with Wind'
        WHEN 5 THEN 'Raining with Wind'
        WHEN 7 THEN 'Fog or Mist'
        ELSE 'Other'
    END AS weather,
    CASE light_conditions
        WHEN 1 THEN 'Daylight'
        WHEN 4 THEN

-- ============================================================
-- SECTION 4: MULTI-TABLE JOIN ANALYSIS
-- Combining collision, casualty, and vehicle data
-- to build a complete picture of each incident
-- ============================================================

-- 4.1 Join all three tables to create a unified incident view
-- Foundation query used to support further analysis
SELECT
    c.collision_index,
    c.date,
    c.day_of_week,
    c.time,
    CASE c.collision_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
    END AS collision_severity,
    CASE c.urban_or_rural_area
        WHEN 1 THEN 'Urban'
        WHEN 2 THEN 'Rural'
    END AS area_type,
    c.speed_limit,
    CASE c.weather_conditions
        WHEN 1 THEN 'Fine'
        WHEN 2 THEN 'Raining'
        WHEN 7 THEN 'Fog or Mist'
        ELSE 'Other'
    END AS weather,
    CASE ca.casualty_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
    END AS casualty_severity,
    CASE ca.casualty_class
        WHEN 1 THEN 'Driver or Rider'
        WHEN 2 THEN 'Passenger'
        WHEN 3 THEN 'Pedestrian'
    END AS casualty_class,
    ca.age_of_casualty,
    CASE ca.sex_of_casualty
        WHEN 1 THEN 'Male'
        WHEN 2 THEN 'Female'
        ELSE 'Unknown'
    END AS sex_of_casualty,
    CASE v.vehicle_type
        WHEN 1 THEN 'Pedal Cycle'
        WHEN 2 THEN 'Motorcycle 50cc and under'
        WHEN 3 THEN 'Motorcycle over 50cc'
        WHEN 5 THEN 'Bus or Coach'
        WHEN 8 THEN 'Taxi'
        WHEN 9 THEN 'Car'
        WHEN 10 THEN 'Minibus'
        WHEN 11 THEN 'Goods Vehicle'
        WHEN 19 THEN 'Van'
        ELSE 'Other'
    END AS vehicle_type,
    v.age_of_driver,
    CASE v.sex_of_driver
        WHEN 1 THEN 'Male'
        WHEN 2 THEN 'Female'
        ELSE 'Unknown'
    END AS sex_of_driver
FROM collisions c
LEFT JOIN casualties ca ON ca.collision_index = c.collision_index
LEFT JOIN vehicles v ON v.collision_index = c.collision_index
LIMIT 100;

-- 4.2 Fatal casualties by casualty type and area
-- Joining collision and casualty tables to understand
-- who is most at risk in fatal incidents
SELECT
    CASE ca.casualty_class
        WHEN 1 THEN 'Driver or Rider'
        WHEN 2 THEN 'Passenger'
        WHEN 3 THEN 'Pedestrian'
    END AS casualty_class,
    CASE c.urban_or_rural_area
        WHEN 1 THEN 'Urban'
        WHEN 2 THEN 'Rural'
    END AS area_type,
    COUNT(*) AS total_casualties,
    SUM(CASE WHEN ca.casualty_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN ca.casualty_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(SUM(CASE WHEN ca.casualty_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM casualties ca
JOIN collisions c ON c.collision_index = ca.collision_index
WHERE ca.casualty_class IN (1, 2, 3)
GROUP BY ca.casualty_class, c.urban_or_rural_area
ORDER BY fatal_rate_pct DESC;

-- 4.3 Average casualties per collision by severity and area
-- Joining collision and casualty to understand incident scale
SELECT
    CASE c.collision_severity
        WHEN 1 THEN 'Fatal'
        WHEN 2 THEN 'Serious'
        WHEN 3 THEN 'Slight'
    END AS collision_severity,
    CASE c.urban_or_rural_area
        WHEN 1 THEN 'Urban'
        WHEN 2 THEN 'Rural'
    END AS area_type,
    COUNT(DISTINCT c.collision_index) AS total_collisions,
    COUNT(ca.casualty_reference) AS total_casualties,
    ROUND(COUNT(ca.casualty_reference) * 1.0 / COUNT(DISTINCT c.collision_index), 2) AS avg_casualties_per_collision
FROM collisions c
LEFT JOIN casualties ca ON ca.collision_index = c.collision_index
GROUP BY c.collision_severity, c.urban_or_rural_area
ORDER BY c.collision_severity, c.urban_or_rural_area;

-- 4.4 Vehicle type involvement in fatal collisions
-- Joining collision and vehicle tables to identify
-- which vehicle types are most involved in fatal incidents
SELECT
    CASE v.vehicle_type
        WHEN 1 THEN 'Pedal Cycle'
        WHEN 2 THEN 'Motorcycle 50cc and under'
        WHEN 3 THEN 'Motorcycle over 50cc'
        WHEN 5 THEN 'Bus or Coach'
        WHEN 8 THEN 'Taxi'
        WHEN 9 THEN 'Car'
        WHEN 10 THEN 'Minibus'
        WHEN 11 THEN 'Goods Vehicle'
        WHEN 19 THEN 'Van'
        ELSE 'Other'
    END AS vehicle_type,
    COUNT(*) AS total_vehicles_involved,
    SUM(CASE WHEN c.collision_severity = 1 THEN 1 ELSE 0 END) AS involved_in_fatal,
    ROUND(SUM(CASE WHEN c.collision_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_involvement_pct
FROM vehicles v
JOIN collisions c ON c.collision_index = v.collision_index
WHERE v.vehicle_type NOT IN (-1, 98)
GROUP BY v.vehicle_type
HAVING COUNT(*) >= 100
ORDER BY fatal_involvement_pct DESC;

-- 4.5 Age group and casualty severity
-- Joining all three tables to understand which age groups
-- suffer the most serious casualties and in what vehicle type
WITH age_bands AS (
    SELECT
        ca.collision_index,
        ca.casualty_severity,
        ca.age_of_casualty,
        CASE
            WHEN ca.age_of_casualty BETWEEN 0 AND 15 THEN '0 to 15'
            WHEN ca.age_of_casualty BETWEEN 16 AND 25 THEN '16 to 25'
            WHEN ca.age_of_casualty BETWEEN 26 AND 45 THEN '26 to 45'
            WHEN ca.age_of_casualty BETWEEN 46 AND 65 THEN '46 to 65'
            WHEN ca.age_of_casualty > 65 THEN 'Over 65'
            ELSE 'Unknown'
        END AS age_group
    FROM casualties ca
    WHERE ca.age_of_casualty >= 0
)
SELECT
    ab.age_group,
    COUNT(*) AS total_casualties,
    SUM(CASE WHEN ab.casualty_severity = 1 THEN 1 ELSE 0 END) AS fatal,
    SUM(CASE WHEN ab.casualty_severity = 2 THEN 1 ELSE 0 END) AS serious,
    ROUND(SUM(CASE WHEN ab.casualty_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fatal_rate_pct
FROM age_bands ab
GROUP BY ab.age_group
ORDER BY fatal_rate_pct DESC;

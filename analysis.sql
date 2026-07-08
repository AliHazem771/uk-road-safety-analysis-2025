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

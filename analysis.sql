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

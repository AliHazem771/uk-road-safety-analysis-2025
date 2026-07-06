# UK Road Safety Analysis 2025

## Business Questions
**Question 1:** When and where do the most serious road collisions occur 
in England and Wales, and what environmental conditions are most associated 
with fatal and serious casualties?

**Question 2:** Which vehicle types, driver profiles, and road characteristics 
present the highest risk of fatal outcomes, and where should safety 
interventions be prioritised?

## Overview
SQL and Power BI analysis of provisional 2025 UK road casualty statistics 
published by the Department for Transport, covering January to May 2025.

The dataset contains three linked tables covering 48,472 collisions, 
60,991 casualties, and 87,805 vehicles, all joinable via a shared 
collision index. Analysis is conducted in SQL (SQLite) with findings 
visualised in a Power BI dashboard.

## Tools
- SQL (SQLite)
- Python (pandas) for data loading, cleaning, and label decoding
- Power BI for dashboard visualisation

## Dataset
- Source: Department for Transport — Road Safety Data (data.gov.uk)
- Period: January to May 2025 (provisional)
- Files: collision, casualty, and vehicle CSV files
- Key join field: collision_index

## Status
Work in progress — SQL analysis and Power BI dashboard being built daily.

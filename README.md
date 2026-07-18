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
Work in progress - SQL analysis and Power BI dashboard being built daily.

## SQL Queries - Progress

- [x] Section 1: Data Exploration
- [x] Section 2: Temporal Analysis
- [x] Section 3: Environmental Conditions
- [x] Section 4: Multi-table Joins
- [x] Section 5: Vehicle and Driver Risk Analysis
- [ ] Section 6: Window Functions and Rankings
- [ ] Section 7: Summary Findings

## Key Findings So Far

- Dataset covers 48,472 collisions, 60,991 casualties, and 87,805 
  vehicles across January to May 2025
- 1.4% of collisions were fatal, 24.7% serious, and 73.9% slight
- 66.6% of collisions occurred in urban areas, 33.4% in rural areas
- Zero missing values across all key analytical columns confirming 
  the dataset is clean and ready for analysis
- Friday is the most common day for collisions overall while Sunday 
  shows a higher proportion of fatal collisions
- The evening rush hour between 4pm and 6pm sees the highest volume 
  of collisions across all severity levels
- Late night hours between 11pm and 3am show a disproportionately 
  high fatal rate despite lower overall collision volumes
- March has the highest collision count of the five months covered
- Collisions on roads with 60mph and 70mph speed limits have 
  significantly higher fatal rates than urban 30mph roads despite 
  lower collision volumes
- Darkness with no street lighting produces a disproportionately 
  high fatal rate compared to daylight collisions
- The majority of collisions occur in fine weather conditions, 
  however fog and adverse weather show elevated fatal rates
- Dry road surfaces account for the majority of collisions, 
  suggesting driver behaviour rather than road conditions is 
  the primary risk factor in most cases
- Pedestrians in rural areas show the highest fatal casualty rate 
  of any casualty class and area combination
- Motorcycles show a disproportionately high fatal involvement rate 
  relative to their overall numbers on the road
- Rural collisions produce a higher average number of casualties 
  per incident than urban collisions at equivalent severity levels
- Over 65s show the highest fatal rate of any age group despite 
  not being the most frequently involved
- Motorcycles on dual carriageways and single carriageways at 
  high speed limits show the highest fatal involvement rates 
  of any vehicle and road type combination
- Drivers aged 17 to 24 and those aged 65 and over show 
  elevated fatal involvement rates compared to middle age groups
- Male drivers are involved in a significantly higher proportion 
  of fatal collisions than female drivers
- Rural single carriageways present the highest combined risk 
  of fatal and serious outcomes of any road type and area combination
- Pedal cycles at 60mph speed limit roads show a disproportionately 
  high fatal rate highlighting the vulnerability of cyclists on 
  high speed rural roads

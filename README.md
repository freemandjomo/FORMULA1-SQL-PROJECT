## 🏎️ Formula 1 Data Analysis - SQL Project

##📌 Project Overview
This project performs an extensive Exploratory Data Analysis (EDA) on historical Formula 1 data (1950 - present). Using PostgreSQL, I built a relational database from scratch, designed a Star Schema, and executed complex SQL queries to uncover insights about drivers, constructors, circuits, and race results.

The goal was to demonstrate proficiency in Relational Database Management Systems (RDBMS), data modeling, and advanced SQL techniques.

🛠️ Tech Stack
Database: PostgreSQL 16

GUI Tool: pgAdmin 4

Data Source: [CLICK HERE](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

Concepts Used: Joins (Inner/Left), Aggregations, Pattern Matching, Date/Time Math, Subqueries, Data Cleaning.

📊 Database Schema (ERD)
I designed a Star Schema with results as the fact table, connecting drivers, constructors, and races via Foreign Keys.

(Note: Ensure you upload your 'https://www.google.com/search?q=schema_diagram.png' to the repo for this image to appear)

<details> <summary><strong>Click here to see the Database Setup Script (SQL)</strong></summary>

SQL

-- 1. Clean up old tables
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS races;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS constructors;

-- 2. Create Dimensions
CREATE TABLE constructors (
    constructorId INT PRIMARY KEY,
    constructorRef VARCHAR(255),
    name VARCHAR(255),
    nationality VARCHAR(255),
    url VARCHAR(255)
);

CREATE TABLE drivers (
    driverId INT PRIMARY KEY,
    driverRef VARCHAR(255),
    number VARCHAR(10),
    code VARCHAR(3),
    forename VARCHAR(255),
    surname VARCHAR(255),
    dob DATE,
    nationality VARCHAR(255),
    url VARCHAR(255)
);

CREATE TABLE races (
    raceId INT PRIMARY KEY,
    year INT,
    round INT,
    circuitId INT,
    name VARCHAR(255),
    date DATE,
    time VARCHAR(255),
    url VARCHAR(255),
    fp1_date VARCHAR(255),
    fp1_time VARCHAR(255),
    fp2_date VARCHAR(255),
    fp2_time VARCHAR(255),
    fp3_date VARCHAR(255),
    fp3_time VARCHAR(255),
    quali_date VARCHAR(255),
    quali_time VARCHAR(255),
    sprint_date VARCHAR(255),
    sprint_time VARCHAR(255)
);

-- 3. Create Fact Table (Results)
CREATE TABLE results (
    resultId INT PRIMARY KEY,
    raceId INT,
    driverId INT,
    constructorId INT,
    number INT,
    grid INT,
    position VARCHAR(255),
    positionText VARCHAR(255),
    positionOrder INT,
    points DECIMAL(5,2),
    laps INT,
    time VARCHAR(255),
    milliseconds VARCHAR(255),
    fastestLap VARCHAR(255),
    rank VARCHAR(255),
    fastestLapTime VARCHAR(255),
    fastestLapSpeed VARCHAR(255),
    statusId INT,
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);
</details>

🔎 Analysis & Queries
Here are 16 SQL queries ranging from basic filtering to complex reporting, demonstrating different analytical techniques.

🟢 Level 1: Basics (Filtering & Sorting)
1. German Drivers Retrieve all drivers with German nationality.

SQL

SELECT * FROM drivers 
WHERE nationality = 'German';
2. Driver List (Sorting) List drivers sorted alphabetically.

SQL

SELECT forename, surname, url 
FROM drivers 
ORDER BY surname ASC;
3. High Point Scorers Find race results where a driver scored more than 10 points.

SQL

SELECT * FROM results 
WHERE points > 10;
4. The 2021 Season List all races that took place in 2021.

SQL

SELECT * FROM races 
WHERE year = 2021;
5. Top 10 Fastest Laps Find the fastest lap times recorded, filtering out empty data.

SQL

SELECT fastestLapTime 
FROM results 
WHERE fastestLapTime IS NOT NULL AND fastestLapTime != '\N' 
ORDER BY fastestLapTime ASC 
LIMIT 10;
🟡 Level 2: Joins (Connecting Tables)
6. Driver & Race Results Join results, drivers, and races to see who raced when.

SQL

SELECT r.date, d.forename, d.surname 
FROM results res
JOIN drivers d ON res.driverId = d.driverId
JOIN races r ON res.raceId = r.raceId;
7. Constructors & Points Show how many points each team scored in specific races.

SQL

SELECT c.name, res.points 
FROM results res
JOIN constructors c ON res.constructorId = c.constructorId;
8. The "Comeback Kid" (Won from worst grid position) Find the race where a driver won despite starting from the furthest back on the grid.

SQL

SELECT d.forename, d.surname, r.name AS race_name, res.grid
FROM results res
JOIN drivers d ON res.driverId = d.driverId
JOIN races r ON res.raceId = r.raceId
WHERE res.positionOrder = 1    -- Winner
ORDER BY res.grid DESC         -- Highest grid number first
LIMIT 1;
🟠 Level 3: Logic & Comparisons
9. National Pride (Same Nationality Driver/Team) Find instances where a driver and their team share the same nationality.

SQL

SELECT d.forename, d.surname, c.name AS team, d.nationality
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN constructors c ON r.constructorId = c.constructorId
WHERE d.nationality = c.nationality
LIMIT 10;
10. Pole-to-Win Conversion Count how many times the driver on Pole Position (Grid 1) actually won the race.

SQL

SELECT COUNT(*) AS pole_and_win
FROM results 
WHERE grid = 1 AND positionOrder = 1;
🔴 Level 4: Aggregation & Analysis
11. Team Hoppers (Most Unique Teams) Identify drivers who have raced for the most unique constructors.

SQL

SELECT d.forename, d.surname, COUNT(DISTINCT r.constructorId) AS distinct_teams
FROM results r
JOIN drivers d ON r.driverId = d.driverId
GROUP BY d.driverId, d.forename, d.surname
ORDER BY distinct_teams DESC
LIMIT 5;
12. Home Grand Prix Winners Find winners where the driver's nationality is part of the race name (e.g., German winning German GP).

SQL

SELECT d.forename, d.surname, ra.name AS race_name
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.positionOrder = 1 
  AND ra.name LIKE '%' || d.nationality || '%';
13. Most Dangerous Tracks Rank circuits by the number of accidents/non-finishes (Status != 1).

SQL

SELECT ra.name, COUNT(*) AS accidents
FROM results r
JOIN races ra ON r.raceId = ra.raceId
WHERE r.statusId != 1   
GROUP BY ra.name
ORDER BY accidents DESC
LIMIT 3;
⚫ Level 5: Complex Reporting (The "Boss" Level)
14. Youngest Winner Ever Calculate the age of drivers at the time of their first win using Date Math.

SQL

SELECT d.forename, d.surname, AGE(ra.date, d.dob) AS age_at_win
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.positionOrder = 1
ORDER BY (ra.date - d.dob) ASC
LIMIT 1;
15. Ultimate 2021 Season Report A comprehensive report joining all 4 tables to summarize the 2021 season.

SQL

SELECT ra.date, ra.name, d.surname AS winner, c.name AS team, r.time, r.points
FROM results r
JOIN races ra ON r.raceId = ra.raceId
JOIN drivers d ON r.driverId = d.driverId
JOIN constructors c ON r.constructorId = c.constructorId
WHERE ra.year = 2021 AND r.positionOrder = 1
ORDER BY ra.date ASC;
🟣 Bonus: Anti-Joins
16. The "Unlucky Ones" (Drivers with ZERO wins) Using a LEFT JOIN to find drivers who exist in the database but never recorded a win.

SQL

SELECT d.forename, d.surname
FROM drivers d
LEFT JOIN results r ON d.driverId = r.driverId AND r.positionOrder = 1
WHERE r.resultId IS NULL
ORDER BY d.surname ASC
LIMIT 10;
🚀 How to Run
Install PostgreSQL and pgAdmin 4.

Create a database named Formula1.

Open the Query Tool and run the schema setup script (see collapsible section above).

Import the CSV files into the corresponding tables (ensure proper delimiter settings).

Run the queries provided above to explore the data!

Author: [Your Name]

# 🏎️ Formula 1 Data Analysis - SQL Project

![Formula 1](https://img.shields.io/badge/Formula%201-Data%20Analysis-red?style=for-the-badge&logo=formula1)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?style=for-the-badge&logo=postgresql)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

![](https://github.com/freemandjomo/FORMULA1-SQL-PROJECT/blob/main/mQaYWoU8tmXqVgK6BF6T5k3SVFGRsrO7AdK82eTy9-w.webp)


---

##  Project Overview

This project performs an **extensive Exploratory Data Analysis (EDA)** on historical Formula 1 data spanning from **1950 to present**. Using **PostgreSQL**, I built a relational database from scratch, designed a **Star Schema**, and executed complex SQL queries to uncover insights about drivers, constructors, circuits, and race results.

**The goal:** Demonstrate proficiency in **Relational Database Management Systems (RDBMS)**, data modeling, and advanced SQL techniques.

---

##  Tech Stack

| Technology | Version/Tool |
|-----------|-------------|
| **Database** | PostgreSQL 16 |
| **GUI Tool** | pgAdmin 4 |
| **Data Source** | [Kaggle - Formula 1 Championship Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020) |
| **Concepts Used** | Joins (Inner/Left), Aggregations, Pattern Matching, Date/Time Math, Subqueries, Data Cleaning |

---

## 📊 Database Schema (ERD)

![bild](https://github.com/freemandjomo/FORMULA1-SQL-PROJECT/blob/main/image%20relationnal%20Databases.png)


<summary><strong> Click here to see the Database Setup Script (SQL)</strong></summary>

```sql
-- 1. Clean up old tables
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS races;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS constructors;

-- 2. Create Dimension Tables
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

  SELECT * From constructors;
  SELECT * From drivers;
  SELECT * From races;
  SELECT * From results;
```

</details>

---

![](https://github.com/freemandjomo/FORMULA1-SQL-PROJECT/blob/main/brian-mccall-QhiA6DdlgiM-unsplash%20(1).jpg)

## 🔎 Analysis & Queries

Here are **16 SQL queries** ranging from basic filtering to complex reporting, demonstrating different analytical techniques.

---

### Level 1: Basics (Filtering & Sorting)

#### 1️⃣ German Drivers
*Retrieve all drivers with German nationality.*

```sql
SELECT * FROM drivers 
WHERE nationality = 'German';
```

#### 2️⃣ Driver List (Sorting)
*List drivers sorted alphabetically.*

```sql
SELECT forename, surname, url 
FROM drivers 
ORDER BY surname ASC;
```

#### 3️⃣ High Point Scorers
*Find race results where a driver scored more than 10 points.*

```sql
SELECT * FROM results 
WHERE points > 10;
```

#### 4️⃣ The 2021 Season
*List all races that took place in 2021.*

```sql
SELECT * FROM races 
WHERE year = 2021;
```

#### 5️⃣ Top 10 Fastest Laps
*Find the fastest lap times recorded, filtering out empty data.*

```sql
SELECT fastestLapTime 
FROM results 
WHERE fastestLapTime IS NOT NULL AND fastestLapTime != '\N' 
ORDER BY fastestLapTime ASC 
LIMIT 10;
```

---

### Level 2: Joins (Connecting Tables)

#### 6️⃣ Driver & Race Results
*Join results, drivers, and races to see who raced when.*

```sql
SELECT r.date,
 d.forename,
 d.surname 
FROM results res
JOIN drivers d ON res.driverId = d.driverId
JOIN races r ON res.raceId = r.raceId;
```

#### 7️⃣ Constructors & Points
*Show how many points each team scored in specific races.*

```sql
SELECT c.name, res.points 
FROM results res
JOIN constructors c ON res.constructorId = c.constructorId;
```

#### 8️⃣ The "Comeback Kid" 🏆
*Find the race where a driver won despite starting from the furthest back on the grid.*

```sql
SELECT d.forename,
 d.surname,
r.name AS race_name,
 res.grid
FROM results res
JOIN drivers d ON res.driverId = d.driverId
JOIN races r ON res.raceId = r.raceId
WHERE res.positionOrder = 1    -- Winner
ORDER BY res.grid DESC         -- Highest grid number first
LIMIT 1;
```

---

###  Level 3: Logic & Comparisons

#### 9️⃣ National Pride 🇩🇪🏁
*Find instances where a driver and their team share the same nationality.*

```sql
SELECT d.forename,
 d.surname,
 c.name AS team,
d.nationality
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN constructors c ON r.constructorId = c.constructorId
WHERE d.nationality = c.nationality
LIMIT 10;
```

#### 🔟 Pole-to-Win Conversion
*Count how many times the driver on Pole Position (Grid 1) actually won the race.*

```sql
SELECT COUNT(*) AS pole_and_win
FROM results 
WHERE grid = 1 AND positionOrder = 1;
```

---

###  Level 4: Aggregation & Analysis

#### 1️⃣1️⃣ Team Hoppers 🔄
*Identify drivers who have raced for the most unique constructors.*

```sql
SELECT d.forename,
 d.surname,
COUNT(DISTINCT r.constructorId) AS distinct_teams
FROM results r
JOIN drivers d ON r.driverId = d.driverId
GROUP BY d.driverId, d.forename, d.surname
ORDER BY distinct_teams DESC
LIMIT 5;
```

#### 1️⃣2️⃣ Home Grand Prix Winners 🏠
*Find winners where the driver's nationality is part of the race name.*

```sql
SELECT d.forename, d.surname, ra.name AS race_name
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.positionOrder = 1 
  AND ra.name LIKE '%' || d.nationality || '%';
```

#### 1️⃣3️⃣ Most Dangerous Tracks ⚠️
*Rank circuits by the number of accidents/non-finishes.*

```sql
SELECT ra.name, COUNT(*) AS accidents
FROM results r
JOIN races ra ON r.raceId = ra.raceId
WHERE r.statusId != 1   
GROUP BY ra.name
ORDER BY accidents DESC
LIMIT 3;
```

---

###  Level 5: Complex Reporting (The "Boss" Level)

#### 1️⃣4️⃣ Youngest Winner Ever 👶
*Calculate the age of drivers at the time of their first win using Date Math.*

```sql
SELECT d.forename,
 d.surname,
 AGE(ra.date, d.dob) AS age_at_win
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.positionOrder = 1
ORDER BY (ra.date - d.dob) ASC
LIMIT 1;
```
![](https://github.com/freemandjomo/FORMULA1-SQL-PROJECT/blob/main/max-verstappen-red-bull-racing-helmet-ieas0xpn0ab388xw.jpg)

#### 1️⃣5️⃣ Ultimate 2021 Season Report 📊
*A comprehensive report joining all 4 tables to summarize the 2021 season.*

```sql
SELECT ra.date,
ra.name,
d.surname AS winner,
c.name AS team,
r.time,
r.points
FROM results r
JOIN races ra ON r.raceId = ra.raceId
JOIN drivers d ON r.driverId = d.driverId
JOIN constructors c ON r.constructorId = c.constructorId
WHERE ra.year = 2021 AND r.positionOrder = 1
ORDER BY ra.date ASC;
```

---

###  Bonus: Anti-Joins

#### 1️⃣6️⃣ The "Unlucky Ones" 😢
*Using a LEFT JOIN to find drivers who exist in the database but never recorded a win.*

```sql
SELECT d.forename,
 d.surname
FROM drivers d
LEFT JOIN results r ON d.driverId = r.driverId AND r.positionOrder = 1
WHERE r.resultId IS NULL
ORDER BY d.surname ASC
LIMIT 10;
```

---

## 🚀 How to launch 

1. **Install PostgreSQL** and **pgAdmin 4**
2. Create a database named `Formula1`
3. Open the Query Tool and run the schema setup script (see collapsible section above)
4. Import the CSV files into the corresponding tables (ensure proper delimiter settings)
5. Run the queries provided above to explore the data!

---

## 📈 Key Insights

- 🏆 **Most Successful Driver:** [Add your findings]
- 🏁 **Most Dangerous Track:** [Add your findings]
- 📊 **Pole Position Win Rate:** [Add your findings]
- 👶 **Youngest Winner:** [Add your findings]

---

##  Contributing

Feel free to fork this repository and submit pull requests! Any improvements to the queries or additional analyses are welcome.

---

##   License

This project is open source and available under the [MIT License](LICENSE).

---

## Author : Merveilles Freeman Djomo Freeman

**[Freeman Djomo]**  
 [My email adress](djomofreeman1776@gmail.com)  
 [My GitHub](https://github.com/freemandjomo)

---

<div align="center">
  <sub>Built with ❤️ passion by a Formula 1 & Data enthusiast</sub>
</div>

-- Formula 1 Database Schema
-- This database contains information about F1 races, drivers, constructors, and results

-- Create tables for constructors
CREATE TABLE constructors (
    constructor_id INT PRIMARY KEY,
    constructor_ref VARCHAR(255),
    name VARCHAR(255),
    nationality VARCHAR(255),
    url VARCHAR(255)
);

-- Create tables for drivers
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_ref VARCHAR(255),
    number INT,
    code VARCHAR(3),
    forename VARCHAR(255),
    surname VARCHAR(255),
    dob DATE,
    nationality VARCHAR(255),
    url VARCHAR(255)
);

-- Create tables for races
CREATE TABLE races (
    race_id INT PRIMARY KEY,
    year INT,
    round INT,
    circuit_id INT,
    name VARCHAR(255),
    date DATE,
    time TIME,
    url VARCHAR(255)
);

-- Create tables for results
CREATE TABLE results (
    result_id INT PRIMARY KEY,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    grid INT,
    position INT,
    position_text VARCHAR(255),
    position_order INT,
    points DECIMAL(8,2),
    laps INT,
    time VARCHAR(255),
    milliseconds INT,
    fastest_lap INT,
    rank INT,
    fastest_lap_time VARCHAR(255),
    fastest_lap_speed DECIMAL(10,3),
    status_id INT,
    FOREIGN KEY (race_id) REFERENCES races(race_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id)
);

-- Example queries
-- Get all races in 2024
SELECT * FROM races WHERE year = 2024;

-- Get top 10 drivers by points
SELECT d.forename, d.surname, SUM(r.points) as total_points
FROM drivers d
JOIN results r ON d.driver_id = r.driver_id
GROUP BY d.driver_id
ORDER BY total_points DESC
LIMIT 10;

-- Get constructor standings
SELECT c.name, SUM(r.points) as total_points
FROM constructors c
JOIN results r ON c.constructor_id = r.constructor_id
GROUP BY c.constructor_id
ORDER BY total_points DESC;

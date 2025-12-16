-- =====================================================
-- FORMULA 1 DATABASE - COMPLETE SQL IMPLEMENTATION
-- =====================================================
-- This comprehensive SQL script creates and manages
-- a complete Formula 1 racing database system
-- =====================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS races;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS constructors;
DROP TABLE IF EXISTS circuits;
DROP TABLE IF EXISTS seasons;

-- =====================================================
-- TABLE: seasons
-- =====================================================
CREATE TABLE seasons (
    season_id INT PRIMARY KEY AUTO_INCREMENT,
    year INT NOT NULL UNIQUE,
    total_races INT,
    champion_driver_id INT,
    champion_constructor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: circuits
-- =====================================================
CREATE TABLE circuits (
    circuit_id INT PRIMARY KEY AUTO_INCREMENT,
    circuit_ref VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    country VARCHAR(255),
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    altitude INT,
    url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: constructors
-- =====================================================
CREATE TABLE constructors (
    constructor_id INT PRIMARY KEY AUTO_INCREMENT,
    constructor_ref VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    nationality VARCHAR(255),
    url VARCHAR(255),
    founded_year INT,
    headquarters VARCHAR(255),
    total_championships INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: drivers
-- =====================================================
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_ref VARCHAR(255) NOT NULL UNIQUE,
    number INT,
    code VARCHAR(3),
    forename VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    dob DATE,
    nationality VARCHAR(255),
    url VARCHAR(255),
    total_points DECIMAL(10, 2) DEFAULT 0,
    total_wins INT DEFAULT 0,
    total_podiums INT DEFAULT 0,
    championships INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_surname (surname),
    INDEX idx_nationality (nationality)
);

-- =====================================================
-- TABLE: races
-- =====================================================
CREATE TABLE races (
    race_id INT PRIMARY KEY AUTO_INCREMENT,
    year INT NOT NULL,
    round INT NOT NULL,
    circuit_id INT,
    name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    time TIME,
    url VARCHAR(255),
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME,
    sprint_date DATE,
    sprint_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id),
    INDEX idx_year (year),
    INDEX idx_date (date),
    UNIQUE KEY unique_race (year, round)
);

-- =====================================================
-- TABLE: results
-- =====================================================
CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    race_id INT NOT NULL,
    driver_id INT NOT NULL,
    constructor_id INT NOT NULL,
    number INT,
    grid INT NOT NULL,
    position INT,
    position_text VARCHAR(255),
    position_order INT NOT NULL,
    points DECIMAL(8, 2) DEFAULT 0,
    laps INT NOT NULL,
    time VARCHAR(255),
    milliseconds INT,
    fastest_lap INT,
    rank INT,
    fastest_lap_time VARCHAR(255),
    fastest_lap_speed DECIMAL(10, 3),
    status_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (race_id) REFERENCES races(race_id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id) ON DELETE CASCADE,
    INDEX idx_race (race_id),
    INDEX idx_driver (driver_id),
    INDEX idx_constructor (constructor_id),
    INDEX idx_position (position)
);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: Current Driver Standings
CREATE OR REPLACE VIEW driver_standings AS
SELECT 
    d.driver_id,
    d.forename,
    d.surname,
    d.code,
    d.nationality,
    COUNT(DISTINCT r.race_id) AS races_entered,
    SUM(res.points) AS total_points,
    SUM(CASE WHEN res.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN res.position <= 3 THEN 1 ELSE 0 END) AS podiums,
    AVG(res.position) AS avg_finish_position
FROM drivers d
LEFT JOIN results res ON d.driver_id = res.driver_id
LEFT JOIN races r ON res.race_id = r.race_id
GROUP BY d.driver_id
ORDER BY total_points DESC;

-- View: Constructor Standings
CREATE OR REPLACE VIEW constructor_standings AS
SELECT 
    c.constructor_id,
    c.name,
    c.nationality,
    COUNT(DISTINCT r.race_id) AS races_entered,
    SUM(res.points) AS total_points,
    SUM(CASE WHEN res.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN res.position <= 3 THEN 1 ELSE 0 END) AS podiums
FROM constructors c
LEFT JOIN results res ON c.constructor_id = res.constructor_id
LEFT JOIN races r ON res.race_id = r.race_id
GROUP BY c.constructor_id
ORDER BY total_points DESC;

-- View: Race Winners
CREATE OR REPLACE VIEW race_winners AS
SELECT 
    r.year,
    r.round,
    r.name AS race_name,
    r.date,
    d.forename || ' ' || d.surname AS winner,
    c.name AS constructor,
    res.time,
    res.points
FROM results res
JOIN races r ON res.race_id = r.race_id
JOIN drivers d ON res.driver_id = d.driver_id
JOIN constructors c ON res.constructor_id = c.constructor_id
WHERE res.position = 1
ORDER BY r.year DESC, r.round ASC;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure: Get Driver Statistics
DELIMITER //
CREATE PROCEDURE GetDriverStats(IN p_driver_id INT)
BEGIN
    SELECT 
        d.forename || ' ' || d.surname AS driver_name,
        d.nationality,
        d.dob,
        COUNT(DISTINCT r.race_id) AS total_races,
        SUM(res.points) AS total_points,
        SUM(CASE WHEN res.position = 1 THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN res.position = 2 THEN 1 ELSE 0 END) AS second_places,
        SUM(CASE WHEN res.position = 3 THEN 1 ELSE 0 END) AS third_places,
        SUM(CASE WHEN res.position <= 3 THEN 1 ELSE 0 END) AS podiums,
        AVG(res.position) AS avg_position,
        MIN(res.position) AS best_finish
    FROM drivers d
    LEFT JOIN results res ON d.driver_id = res.driver_id
    LEFT JOIN races r ON res.race_id = r.race_id
    WHERE d.driver_id = p_driver_id
    GROUP BY d.driver_id;
END //
DELIMITER ;

-- Procedure: Get Season Summary
DELIMITER //
CREATE PROCEDURE GetSeasonSummary(IN p_year INT)
BEGIN
    SELECT 
        r.year,
        COUNT(DISTINCT r.race_id) AS total_races,
        COUNT(DISTINCT res.driver_id) AS total_drivers,
        COUNT(DISTINCT res.constructor_id) AS total_constructors,
        MAX(res.points) AS highest_points_single_race,
        AVG(res.points) AS avg_points_per_race
    FROM races r
    LEFT JOIN results res ON r.race_id = res.race_id
    WHERE r.year = p_year
    GROUP BY r.year;
END //
DELIMITER ;

-- =====================================================
-- ADVANCED ANALYTICS QUERIES
-- =====================================================

-- Query: Top 10 Drivers of All Time
SELECT 
    d.forename || ' ' || d.surname AS driver,
    d.nationality,
    COUNT(DISTINCT r.race_id) AS races,
    SUM(res.points) AS points,
    SUM(CASE WHEN res.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN res.position <= 3 THEN 1 ELSE 0 END) AS podiums,
    ROUND(SUM(CASE WHEN res.position = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT r.race_id), 2) AS win_percentage
FROM drivers d
JOIN results res ON d.driver_id = res.driver_id
JOIN races r ON res.race_id = r.race_id
GROUP BY d.driver_id
HAVING COUNT(DISTINCT r.race_id) >= 50
ORDER BY points DESC
LIMIT 10;

-- Query: Constructor Dominance by Era
SELECT 
    FLOOR(r.year / 10) * 10 AS decade,
    c.name AS constructor,
    COUNT(CASE WHEN res.position = 1 THEN 1 END) AS wins,
    SUM(res.points) AS total_points
FROM results res
JOIN races r ON res.race_id = r.race_id
JOIN constructors c ON res.constructor_id = c.constructor_id
GROUP BY decade, c.constructor_id
ORDER BY decade DESC, wins DESC;

-- Query: Fastest Lap Analysis
SELECT 
    d.forename || ' ' || d.surname AS driver,
    COUNT(res.fastest_lap) AS fastest_laps,
    AVG(res.fastest_lap_speed) AS avg_speed,
    MAX(res.fastest_lap_speed) AS max_speed,
    MIN(res.fastest_lap_time) AS best_time
FROM drivers d
JOIN results res ON d.driver_id = res.driver_id
WHERE res.fastest_lap IS NOT NULL
GROUP BY d.driver_id
HAVING COUNT(res.fastest_lap) >= 10
ORDER BY fastest_laps DESC;

-- Query: Head-to-Head Driver Comparison
WITH driver_pairs AS (
    SELECT 
        r.race_id,
        r.year,
        d1.forename || ' ' || d1.surname AS driver1,
        d2.forename || ' ' || d2.surname AS driver2,
        res1.position AS position1,
        res2.position AS position2,
        CASE 
            WHEN res1.position < res2.position THEN 1 
            ELSE 0 
        END AS driver1_wins
    FROM results res1
    JOIN results res2 ON res1.race_id = res2.race_id
    JOIN drivers d1 ON res1.driver_id = d1.driver_id
    JOIN drivers d2 ON res2.driver_id = d2.driver_id
    JOIN races r ON res1.race_id = r.race_id
    WHERE res1.driver_id < res2.driver_id
)
SELECT 
    driver1,
    driver2,
    COUNT(*) AS races_together,
    SUM(driver1_wins) AS driver1_wins,
    COUNT(*) - SUM(driver1_wins) AS driver2_wins
FROM driver_pairs
GROUP BY driver1, driver2
HAVING COUNT(*) >= 10
ORDER BY races_together DESC;

-- =====================================================
-- TRIGGERS FOR DATA INTEGRITY
-- =====================================================

-- Trigger: Update driver stats after result insert
DELIMITER //
CREATE TRIGGER update_driver_stats_after_insert
AFTER INSERT ON results
FOR EACH ROW
BEGIN
    UPDATE drivers
    SET 
        total_points = total_points + NEW.points,
        total_wins = total_wins + (CASE WHEN NEW.position = 1 THEN 1 ELSE 0 END),
        total_podiums = total_podiums + (CASE WHEN NEW.position <= 3 THEN 1 ELSE 0 END),
        updated_at = CURRENT_TIMESTAMP
    WHERE driver_id = NEW.driver_id;
END //
DELIMITER ;

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

CREATE INDEX idx_results_points ON results(points DESC);
CREATE INDEX idx_results_position ON results(position);
CREATE INDEX idx_drivers_nationality ON drivers(nationality);
CREATE INDEX idx_races_year_round ON races(year, round);
CREATE INDEX idx_constructors_name ON constructors(name);

-- =====================================================
-- SAMPLE DATA INSERTION QUERIES
-- =====================================================

-- Insert sample constructor
INSERT INTO constructors (constructor_ref, name, nationality, founded_year, headquarters)
VALUES 
    ('red_bull', 'Red Bull Racing', 'Austrian', 2005, 'Milton Keynes, UK'),
    ('mercedes', 'Mercedes-AMG Petronas', 'German', 1954, 'Brackley, UK'),
    ('ferrari', 'Scuderia Ferrari', 'Italian', 1950, 'Maranello, Italy');

-- =====================================================
-- END OF SQL SCRIPT
-- =====================================================

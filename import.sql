-- Data Import Scripts for Formula 1 Database

-- Load constructors data
LOAD DATA INFILE 'data-constructors.csv'
INTO TABLE constructors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load drivers data
LOAD DATA INFILE 'data-drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load races data
LOAD DATA INFILE 'data-races.csv'
INTO TABLE races
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load results data
LOAD DATA INFILE 'data-results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify data loaded
SELECT 'Constructors' AS table_name, COUNT(*) AS row_count FROM constructors
UNION ALL
SELECT 'Drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'Races', COUNT(*) FROM races
UNION ALL
SELECT 'Results', COUNT(*) FROM results;

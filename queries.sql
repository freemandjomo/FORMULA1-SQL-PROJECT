-- Advanced F1 Analytics Queries

-- Top 5 drivers with most wins
SELECT 
    d.forename || ' ' || d.surname AS driver_name,
    COUNT(*) AS total_wins
FROM drivers d
JOIN results r ON d.driver_id = r.driver_id
WHERE r.position = 1
GROUP BY d.driver_id
ORDER BY total_wins DESC
LIMIT 5;

-- Constructor championship standings by year
SELECT 
    r.year,
    c.name AS constructor,
    SUM(res.points) AS total_points
FROM races r
JOIN results res ON r.race_id = res.race_id
JOIN constructors c ON res.constructor_id = c.constructor_id
GROUP BY r.year, c.constructor_id
ORDER BY r.year DESC, total_points DESC;

-- Fastest lap statistics
SELECT 
    d.forename || ' ' || d.surname AS driver,
    COUNT(r.fastest_lap) AS fastest_laps,
    AVG(r.fastest_lap_speed) AS avg_speed
FROM drivers d
JOIN results r ON d.driver_id = r.driver_id
WHERE r.fastest_lap IS NOT NULL
GROUP BY d.driver_id
ORDER BY fastest_laps DESC;

-- Podium finishes per driver
SELECT 
    d.forename || ' ' || d.surname AS driver,
    SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN r.position = 2 THEN 1 ELSE 0 END) AS second_places,
    SUM(CASE WHEN r.position = 3 THEN 1 ELSE 0 END) AS third_places,
    SUM(CASE WHEN r.position <= 3 THEN 1 ELSE 0 END) AS total_podiums
FROM drivers d
JOIN results r ON d.driver_id = r.driver_id
WHERE r.position <= 3
GROUP BY d.driver_id
ORDER BY total_podiums DESC;

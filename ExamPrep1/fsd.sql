CREATE SCHEMA `fsd`;

CREATE TABLE `countries` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL
);


CREATE TABLE `towns` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`country_id` INT NOT NULL
);

CREATE TABLE `stadiums` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`capacity` INT NOT NULL,
`town_id` INT NOT NULL
);

CREATE TABLE `teams` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT 0,
`stadium_id` INT NOT NULL
);

CREATE TABLE `skills_data` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`dribbling` INT DEFAULT 0,
`pace` INT DEFAULT 0,
`passing` INT DEFAULT 0,
`shooting` INT DEFAULT 0,
`speed` INT DEFAULT 0,
`strength` INT DEFAULT 0
);

CREATE TABLE `coaches` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(10, 2) NOT NULL DEFAULT 0,
`coach_level` INT NOT NULL DEFAULT 0
);

CREATE TABLE `players_coaches` (
`player_id` INT,
`coach_id` INT
);


CREATE TABLE `players` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`age` INT NOT NULL,
`position` CHAR(1) NOT NULL,
`salary` DECIMAL(10, 2) NOT NULL DEFAULT 0,
`hire_date` DATETIME,
`skills_data_id` INT NOT NULL,
`team_id` INT
);

ALTER TABLE `players_coaches`
ADD CONSTRAINT `fk_pc_coaches`
FOREIGN KEY (`coach_id`)
REFERENCES `coaches`(`id`),
ADD CONSTRAINT `fk_pc_players`
FOREIGN KEY (`player_id`)
REFERENCES `players`(`id`)
;

ALTER TABLE `players`
ADD CONSTRAINT `fk_players_skills_data`
FOREIGN KEY (`skills_data_id`)
REFERENCES `skills_data`(`id`),
ADD CONSTRAINT `fk_players_teams`
FOREIGN KEY (`team_id`)
REFERENCES `teams`(`id`)
;

ALTER TABLE `teams`
ADD CONSTRAINT `fk_teams_stadiums`
FOREIGN KEY (`stadium_id`)
REFERENCES `stadiums`(`id`)
;

ALTER TABLE `stadiums`
ADD CONSTRAINT `fk_stadiums_towns`
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`)
;

ALTER TABLE `towns`
ADD CONSTRAINT `fk_towns_countries`
FOREIGN KEY (`country_id`)
REFERENCES `countries`(`id`)
;

-----------------------------------

INSERT INTO `coaches` (first_name, last_name, salary, coach_level)
(
SELECT first_name, last_name, salary*2, char_length(first_name) AS `coach_level` 
FROM `players`
WHERE `age` >= 45
);

UPDATE `coaches` 
SET 
    coach_level = coach_level + 1
WHERE
    first_name LIKE 'A%'
        AND (SELECT 
            COUNT(*)
        FROM
            players_coaches
        WHERE
            coach_id = `id`) > 0
;

DELETE FROM `players`
WHERE `age` >= 45;

-----------------------------------

SELECT `first_name`, `age`, `salary`
FROM players
ORDER BY salary DESC;

SELECT p.`id`, concat_ws(' ', first_name, last_name) AS `full_name`, `age`, `position`, `hire_date`
FROM players AS p
JOIN skills_data AS sd ON sd.`id` = p.skills_data_id
WHERE sd.strength > 50 AND age < 23 AND `position` = 'A' AND hire_date IS NULL AND
sd.strength > 50
ORDER BY p.salary, p.`age`;

SELECT t.`name`, t.`established`, t.`fan_base`, COUNT(p.`id`) AS `count_of_players`
FROM teams AS t
LEFT JOIN players AS p ON t.`id` = p.team_id
GROUP BY t.`name`
ORDER BY `count_of_players` DESC, t.fan_base DESC;

SELECT MAX(sd.speed) AS `max_speed`, t.`name` AS `town_name`
FROM skills_data AS sd
RIGHT JOIN players AS p ON p.skills_data_id = sd.`id`
RIGHT JOIN teams AS tm ON tm.`id` = p.team_id
RIGHT JOIN stadiums AS s ON s.`id` = tm.stadium_id
RIGHT JOIN towns AS t ON t.`id` = s.town_id
WHERE tm.`name` NOT IN('Devify')
GROUP BY t.`id`
ORDER BY `max_speed` DESC, t.`name`;

SELECT c.`name`, COUNT(p.`id`) AS `total_count_of_players`, IF(COUNT(p.`id`) != 0, SUM(p.salary), NULL) AS `total_sum_of_salaries`
FROM countries AS c
LEFT JOIN towns AS t ON t.`country_id` = c.`id`
LEFT JOIN stadiums AS s ON s.`town_id` = t.`id`
LEFT JOIN teams AS tm ON tm.`stadium_id` = s.`id`
LEFT JOIN players AS p ON p.`team_id` = tm.`id`
GROUP BY c.`name`
ORDER BY `total_count_of_players` DESC, c.`name`;

-----------------------------------
DELIMITER $$
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(p.`id`) AS `count` FROM players AS p
	JOIN teams AS tm ON tm.`id` = p.team_id
	JOIN stadiums AS s ON s.`id` = tm.stadium_id
	WHERE s.`name` = stadium_name
	GROUP BY s.`name`)
	;
END $$

DELIMITER ;
SELECT udf_stadium_players_count('Jaxworks') AS 'count';

DELIMITER $$
CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT, team_name VARCHAR(45))
BEGIN
	DECLARE avg_speed INT DEFAULT (SELECT AVG(speed) FROM skills_data);
	SELECT concat_ws(' ', p.first_name, p.last_name) AS `full_name`,
    p.age, p.salary, sd.dribbling, sd.speed, tm.`name`
    FROM players AS p
    JOIN skills_data AS sd ON sd.`id` = p.skills_data_id
    JOIN teams AS tm ON tm.`id` = p.team_id
    WHERE tm.`name` = team_name AND 
    sd.dribbling > min_dribble_points AND
    sd.speed > avg_speed
    ORDER BY sd.speed desc
    LIMIT 1;
END $$
DELIMITER ;

CALL udp_find_playmaker(20, 'Skyble');

DROP SCHEMA instd;

CREATE SCHEMA instd;

CREATE TABLE users (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
`email` VARCHAR(50) NOT NULL,
`gender` CHARACTER(1) NOT NULL,
`age` INT NOT NULL,
`job_title` VARCHAR(40) NOT NULL,
`ip` VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address` VARCHAR(30) NOT NULL,
`town` VARCHAR(30) NOT NULL,
`country` VARCHAR(30) NOT NULL,
`user_id` INT NOT NULL
);

CREATE TABLE photos (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
`views` INT NOT NULL DEFAULT 0
);

CREATE TABLE comments (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL
);

CREATE TABLE users_photos (
`user_id` INT NOT NULL,
`photo_id` INT NOT NULL
);

CREATE TABLE likes (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`photo_id` INT NOT NULL,
`user_id` INT NOT NULL
);

------------------------------------

ALTER TABLE users_photos
ADD CONSTRAINT fk_up_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`),
ADD CONSTRAINT fk_up_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`);

ALTER TABLE comments
ADD CONSTRAINT fk_comments_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`);

ALTER TABLE addresses
ADD CONSTRAINT fk_addresses_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`);

ALTER TABLE likes
ADD CONSTRAINT fk_likes_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`),
ADD CONSTRAINT fk_likes_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`);

------------------------------------

INSERT INTO addresses (address, town, country, user_id) 
(
SELECT username, `password`, ip, age
FROM users
WHERE gender = 'M'
);

UPDATE addresses 
SET country = IF(country LIKE 'B%', 'Blocked', IF(country LIKE 'T%', 'Test', IF(country LIKE 'P%', 'In Progress', country)))
;

UPDATE addresses
SET country = IF(country LIKE 'B%', 'Blocked', IF(country LIKE 'T%', 'Test', 'In Progress'))
WHERE country LIKE 'B%' OR country LIKE 'T%' OR country LIKE 'P%'
;

DELIMITER $$
UPDATE addresses
SET country = 
CASE
	WHEN country LIKE 'B%' THEN 'Blocked'
	WHEN country LIKE 'T%' THEN 'Test'
	ELSE 'In Progress'
END 
WHERE country LIKE 'B%' OR country LIKE 'T%' OR country LIKE 'P%'
$$

DELIMITER ;

DELETE FROM addresses
WHERE `id` % 3 = 0;

------------------------------------

SELECT username, gender, age
FROM users
ORDER BY age DESC, username ASC;

SELECT
 p.`id`,
 p.`date` AS `date_and_time`,
 p.`description`,
 COUNT(c.`id`) AS `comments_count`
FROM photos AS p
JOIN comments AS c ON c.photo_id = p.`id`
GROUP BY p.`id`
ORDER BY `comments_count` DESC, p.`id` ASC
LIMIT 5;

SELECT concat_ws(' ', u.`id`, u.`username`) AS `id_username`, u.`email`
FROM users AS u
JOIN users_photos AS up ON up.user_id = u.`id`
WHERE up.user_id = up.photo_id
ORDER BY u.`id`;

SELECT p.`id` AS `photo_id`, COUNT(DISTINCT l.`id`) AS `likes_count`, COUNT(DISTINCT c.`id`) AS `comments_count`
FROM photos AS p
LEFT JOIN likes AS l ON l.photo_id = p.`id`
LEFT JOIN comments AS c ON c.photo_id = p.`id`
GROUP BY p.id
ORDER BY `likes_count` DESC, `comments_count` DESC, p.`id` ASC
;

SELECT CONCAT(SUBSTRING(`description`, 1, 30), '...') AS `summary`, `date`
FROM photos
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;

------------------------------------
DELIMITER $$
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (
	SELECT COUNT(*) 
    FROM users AS u
    JOIN users_photos AS up ON up.user_id = u.`id`
    WHERE u.`username` = username);
END
$$

DELIMITER ;
DROP FUNCTION udf_users_photos_count;

DELIMITER ;
SELECT udf_users_photos_count('ssantryd') AS photosCount;

DELIMITER $$

CREATE PROCEDURE udp_modify_user(address VARCHAR(30), town VARCHAR(30))
BEGIN
	IF((SELECT u.username FROM addresses AS a
    JOIN users AS u ON u.`id` = a.user_id
    WHERE address = a.address) IS NOT NULL) 
    THEN UPDATE users AS u
    JOIN addresses AS aa ON u.`id` = aa.user_id
    SET u.age = u.age + 10
    WHERE aa.address = address AND aa.town = town;
    END IF;
END $$

DELIMITER ;

CALL udp_modify_user ('97 Valley Edge Parkway', 'Divinópolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';


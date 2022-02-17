CREATE TABLE `addresses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL
);


CREATE TABLE `clients` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `courses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`from_address_id`INT NOT NULL,
`start` DATETIME NOT NULL,
`car_id` INT NOT NULL,
`client_id` INT NOT NULL,
`bill` DECIMAL(10, 2) NOT NULL DEFAULT 10
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE `cars` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT NOT NULL DEFAULT 0,
`mileage` INT DEFAULT 0,
`condition` CHAR(1) NOT NULL,
`category_id` INT NOT NULL
);

CREATE TABLE `drivers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`rating` FLOAT DEFAULT 5.5
);

CREATE TABLE `cars_drivers` (
`car_id` INT NOT NULL,
`driver_id` INT NOT NULL,
PRIMARY KEY (car_id, driver_id)
);


ALTER TABLE `cars_drivers`
ADD CONSTRAINT `fk_cd_drivers`
FOREIGN KEY (`driver_id`)
REFERENCES `drivers`(`id`),
ADD CONSTRAINT `fk_cd_cars`
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`)
;

ALTER TABLE `courses`
ADD CONSTRAINT `fk_courses_clients`
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`),
ADD CONSTRAINT `fk_courses_cars`
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`),
ADD CONSTRAINT `fk_courses_addresses`
FOREIGN KEY (`from_address_id`)
REFERENCES `addresses`(`id`)
;

ALTER TABLE `cars`
ADD CONSTRAINT `fk_cars_categories`
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`)
;

---------------------------------

INSERT INTO clients(full_name, phone_number)
(SELECT concat_ws(' ', first_name, last_name), concat('(088) 9999 ', `id`*2)
FROM drivers
WHERE `id` BETWEEN 10 AND 20);

UPDATE cars
SET `condition` = 'C'
WHERE (mileage >= 800000 OR mileage IS NULL) 
	AND `year` <= 2010 
	AND `make` !='Mercedes-Benz';
    
    
DELETE cl.*
FROM clients AS cl
LEFT JOIN courses AS c ON c.client_id = cl.`id`
WHERE c.`id` IS NULL AND char_length(full_name) > 3;

---------------------------------

SELECT `make`, `model`, `condition` 
FROM cars
ORDER BY `id`;

SELECT d.first_name, d.last_name, c.make, c.model, c.mileage
FROM drivers AS d
JOIN cars_drivers AS cd ON d.`id` = cd.driver_id
JOIN cars AS c ON c.`id` = cd.car_id
WHERE c.mileage IS NOT NULL
ORDER BY c.mileage DESC, d.first_name ASC;

SELECT c.`id` AS `car_id`, c.make, c.mileage, COUNT(co.`id`) AS `count_of_courses`, ROUND(AVG(co.bill), 2) AS `avg_bill`
FROM cars AS c
LEFT JOIN courses AS co ON co.car_id = c.`id`
GROUP BY c.`id`
HAVING COUNT(co.`id`) != 2
ORDER BY COUNT(co.`id`) DESC, c.`id`;

SELECT cl.full_name, COUNT(co.car_id) AS `count_of_cars`, SUM(co.bill) AS `total_sum`
FROM clients AS cl
JOIN courses AS co ON co.client_id = cl.`id`
GROUP BY cl.`id`
HAVING substr(cl.full_name, 2, 1) = 'a' AND COUNT(co.car_id) > 1
ORDER BY cl.full_name
;

SELECT ad.`name`, IF(
HOUR(co.`start`) BETWEEN 6 AND 20, 'Day', 'Night'
) AS `day_time`, co.`bill`, cl.`full_name`, c.`make`, c.`model`, ca.`name`
FROM courses AS co
JOIN clients AS cl ON cl.`id` = co.client_id
JOIN addresses AS ad ON ad.`id` = co.from_address_id
JOIN cars AS c ON c.`id` = co.car_id
JOIN categories AS ca ON ca.`id` = c.category_id
ORDER BY co.`id`;

---------------------------------

DELIMITER &&
CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR(20))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (
    SELECT COUNT(co.`id`) AS `count`
    FROM clients AS cl
    LEFT JOIN courses AS co ON co.client_id = cl.`id`
    WHERE cl.phone_number = phone_num
    );
END 
&&

DELIMITER ;


DELIMITER &&
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN
	SELECT ad.`name`, cl.full_name, 
    IF(co.bill <= 20, 'Low', if((co.bill BETWEEN 21 AND 30), 'Medium', 'High')) AS `level_of_bill`, c.`make`, c.`condition`, cat.`name` AS `cat_name`
    FROM courses AS co
    JOIN addresses AS ad ON ad.`id` = co.from_address_id
    JOIN clients AS cl ON cl.`id` = co.client_id
    JOIN cars AS c ON c.`id` = co.car_id
	JOIN categories AS cat ON cat.`id` = c.category_id
    WHERE ad.`name` = address_name
    ORDER BY c.`make`, cl.full_name
    ;
END
&&

DELIMITER ;
CREATE SCHEMA `minions`;

USE minions;

CREATE TABLE `minions` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30),
`age` INT UNSIGNED
);

CREATE TABLE `towns` (
`town_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30)
);

ALTER TABLE `towns`
CHANGE COLUMN `town_id` `id` INT; 

ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns FOREIGN KEY `minions` (`town_id`)
REFERENCES `towns` (`id`);

INSERT INTO `minions` (`id`,`name`,`age`,`town_id`)
VALUES ("1", "Kevin", "22", "1"),
("2", "Bob", "15", "3"),
("3", "Steward", NULL, "2");

INSERT INTO `towns` (`id`,`name`)
VALUES ("1", "Sofia"),
("2", "Plovdiv"),
("3", "Varna");

TRUNCATE TABLE `minions`;

DROP TABLE `minions`;
DROP TABLE `towns`;

SELECT * FROM `towns`;

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users2
PRIMARY KEY `users` (`id`, `username`);

ALTER TABLE `users`
CHANGE COLUMN `last_login_time` `last_login_time` 
DATETIME DEFAULT NOW();

SELECT * FROM employees;

SELECT id, first_name, last_name, job_title
FROM employees
ORDER BY id;

SELECT id, CONCAT(first_name, ' ', last_name) AS `full_name`, job_title, salary
FROM employees
WHERE salary > 1000
ORDER BY id;

SELECT * FROM employees;

UPDATE employees
SET salary = salary + 100
WHERE job_title = 'Manager';

SELECT salary
FROM employees;

SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1;

SELECT * FROM employees
WHERE department_id = 4 AND salary >= 1000
ORDER BY id;

DELETE FROM employees
WHERE department_id = 1 OR department_id = 2;

SELECT * FROM employees
ORDER BY id;

CREATE VIEW `v_top_paid` AS 
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1;

SELECT * FROM `v_top_paid`;

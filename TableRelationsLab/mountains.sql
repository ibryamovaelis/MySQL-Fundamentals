SELECT c.id, v.vehicle_type, concat_ws(' ', c.first_name, c.last_name) AS 'driver_name'
FROM campers AS c
JOIN vehicles AS v
ON v.driver_id = c.id;

DROP TABLE peaks;
DROP TABLE mountains;

CREATE TABLE `mountains` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(45)
);

CREATE TABLE `peaks` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(45),
`mountain_id` INT,
CONSTRAINT `fk_peaks_mountains`
FOREIGN KEY (`mountain_id`) 
REFERENCES `mountains`(`id`)
ON DELETE CASCADE
);

SELECT r.starting_point, r.end_point, r.leader_id, concat_ws(' ', c.first_name, c.last_name) AS 'leader_name' 
FROM routes AS r
JOIN campers AS c
ON r.leader_id = c.id;

CREATE schema `five`;

CREATE TABLE `clients` (
`id` INT(11) AUTO_INCREMENT PRIMARY KEY,
`client_name` VARCHAR(100)
);

CREATE TABLE `projects` (
`id` INT(11) AUTO_INCREMENT PRIMARY KEY,
`client_id` INT(11),
`project_lead_id` INT(11),
CONSTRAINT `fk_clients`
FOREIGN KEY (`client_id`)
REFERENCES `clients` (`id`)
);

CREATE TABLE `employees` (
`id` INT(11) AUTO_INCREMENT PRIMARY KEY,
`first_name` VARCHAR(30),
`last_name` VARCHAR(30),
`project_id` INT(11),
CONSTRAINT `fk_projects`
FOREIGN KEY (`project_id`)
REFERENCES `projects`(`id`)
);

ALTER TABLE `projects`
ADD CONSTRAINT `fk_projects_employees`
FOREIGN KEY (`project_lead_id`)
REFERENCES `employees`(`id`);

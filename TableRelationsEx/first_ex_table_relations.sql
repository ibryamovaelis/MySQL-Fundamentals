CREATE SCHEMA first_ex_TABLE_RELATIONS;

CREATE TABLE people (
`person_id` INT PRIMARY KEY AUTO_INCREMENT UNIQUE,
`first_name` VARCHAR(50) NOT NULL, 
`salary` DECIMAL(10, 2) NOT NULL DEFAULT 0,
`passport_id` INT NOT NULL UNIQUE
);

CREATE TABLE passports (
`passport_id` INT(50) PRIMARY KEY AUTO_INCREMENT UNIQUE NOT NULL,
`passport_number` VARCHAR(15)
) AUTO_INCREMENT = 101;

INSERT INTO people (`first_name`, `salary`, `passport_id`)
	VALUES 
    ('Roberto', 43300, 102),
    ('Tom', 56100, 103),
    ('Yana', 60200, 101);

INSERT INTO passports (`passport_number`)
	VALUES 
    ('N34FG21B'),
    ('K65LO4R7'),
    ('ZE657QP2');
    
ALTER TABLE `people`
ADD CONSTRAINT `fk_people_passports`
FOREIGN KEY (`passport_id`)
REFERENCES `passports`(`passport_id`);
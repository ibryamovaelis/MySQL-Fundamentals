CREATE SCHEMA online_store;

CREATE TABLE `brands` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);


CREATE TABLE `reviews` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`content`TEXT,
`rating` DECIMAL(10, 2) NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`published_at` DATETIME NOT NULL
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`price` DECIMAL(19, 2) NOT NULL,
`quantity_in_stock` INT,
`description` TEXT,
`brand_id` INT NOT NULL,
`category_id` INT NOT NULL,
`review_id` INT NOT NULL
);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`phone` VARCHAR(30) NOT NULL UNIQUE,
`address` VARCHAR(60) NOT NULL,
`discount_card` BIT(1) NOT NULL DEFAULT FALSE
);

CREATE TABLE `orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`order_datetime` DATETIME NOT NULL,
`customer_id` INT NOT NULL
);

CREATE TABLE `orders_products` (
`order_id` INT NOT NULL,
`product_id` INT NOT NULL
);


ALTER TABLE `orders_products`
ADD CONSTRAINT `fk_op_products`
FOREIGN KEY (`product_id`)
REFERENCES `products`(`id`),
ADD CONSTRAINT `fk_op_orders`
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`id`)
;

ALTER TABLE `products`
ADD CONSTRAINT `fk_products_categories`
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`),
ADD CONSTRAINT `fk_products_brands`
FOREIGN KEY (`brand_id`)
REFERENCES `brands`(`id`),
ADD CONSTRAINT `fk_products_reviews`
FOREIGN KEY (`review_id`)
REFERENCES `reviews`(`id`)
;

ALTER TABLE `orders`
ADD CONSTRAINT `fk_orders_customers`
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`id`)
;

------------------------------------

INSERT INTO reviews(content, picture_url, published_at, rating)
(SELECT substr(description, 1, 15), reverse(`name`), '2010-10-10', `price`/8
FROM products
WHERE `id` >= 5);

UPDATE products
SET `quantity_in_stock` = `quantity_in_stock` - 5
WHERE `quantity_in_stock` BETWEEN 60 AND 70;

DELETE c.*
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.`id`
WHERE o.`id` IS NULL;

------------------------------------

SELECT `id`, `name`
FROM categories
ORDER BY `name` DESC;

SELECT `id`, `brand_id`, `name`, `quantity_in_stock`
FROM products
WHERE `price` > 1000 AND `quantity_in_stock` < 30
ORDER BY `quantity_in_stock` ASC, `id`;

SELECT `id`, `content`, `rating`, `picture_url`, `published_at`
FROM reviews
WHERE `content` LIKE 'My%' AND char_length(`content`) > 61
ORDER BY `rating` DESC;

SELECT concat_ws(' ', cu.first_name, cu.last_name) AS `full_name`, cu.`address`, o.`order_datetime` AS `order_date`
FROM customers AS cu
JOIN orders AS o ON o.customer_id = cu.`id`
WHERE YEAR(o.order_datetime ) <= 2018
ORDER BY `full_name` DESC;

SELECT COUNT(p.`id`) AS `items_count`, c.`name`, SUM(p.`quantity_in_stock`) AS `total_quantity`
FROM categories AS c
LEFT JOIN products AS p ON p.category_id = c.`id`
GROUP BY c.id
ORDER BY `items_count` DESC, `total_quantity` ASC
LIMIT 5;


---------------------------
DELIMITER &&
CREATE FUNCTION udf_customer_products_count(`name` VARCHAR(30))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (
    SELECT COUNT(op.`order_id`) AS `count`
    FROM customers AS c
	JOIN orders AS o ON o.customer_id = c.`id`
    JOIN orders_products AS op ON op.order_id = o.id
    WHERE c.`first_name` = `name`
    );
END 
&&

DELIMITER ;

DELIMITER &&
CREATE PROCEDURE udp_reduce_price(category_name VARCHAR(50))
BEGIN
	UPDATE `products` AS p
    JOIN reviews AS r ON r.`id` = p.`review_id`
    JOIN categories AS c ON c.`id` = p.`category_id`
    SET price = 0.7 * price
    WHERE c.`name` = category_name AND r.`rating` < 4
    ;
END
&&

DELIMITER ;


select c.id, c.first_name, c.last_name, COUNT(o.id) from customers c inner join orders o on o.customer_id = c.id  where first_name = 'Shirley' group by c.id;
select * from orders where customer_id = 29;


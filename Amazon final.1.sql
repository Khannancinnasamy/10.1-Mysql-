CREATE DATABASE IF NOT EXISTS AmazonDB;
USE AmazonDB;

CREATE TABLE Users (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    registered_date DATE NOT NULL,
    membership      ENUM('Basic', 'Prime') DEFAULT 'Basic'
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(200) NOT NULL,
    price      DECIMAL(10,2) NOT NULL,
    category   VARCHAR(100) NOT NULL,
    stock      INT NOT NULL
);

CREATE TABLE Orders (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    order_date   DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE OrderDetails (
    order_details_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT,
    product_id       INT,
    quantity         INT NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

USE AmazonDB;

INSERT INTO Users (name, email, registered_date, membership) VALUES
('Alice Johnson', 'alice.j@example.com', '2024-01-15', 'Prime'),
('Bob Smith', 'bob.s@example.com', '2024-02-01', 'Basic'),
('Charlie Brown', 'charlie.b@example.com', '2024-03-10', 'Prime'),
('Daisy Ridley', 'daisy.r@example.com', '2024-04-12', 'Basic');

INSERT INTO Products (name, price, category, stock) VALUES
('Echo Dot', 49.99, 'Electronics', 120),
('Kindle Paperwhite', 129.99, 'Books', 50),
('Fire Stick', 39.99, 'Electronics', 80),
('Yoga Mat', 19.99, 'Fitness', 200),
('Wireless Mouse', 24.99, 'Electronics', 150);

INSERT INTO Orders (user_id, order_date, total_amount) VALUES
(1, '2024-05-01', 79.98),
(1, '2024-05-01', 79.98),
(2, '2024-05-03', 129.99),
(1, '2024-05-04', 49.99),
(3, '2024-05-05', 24.99);

INSERT INTO OrderDetails (order_id, product_id, quantity) VALUES
(1, 3, 2),  -- Fire Stick x2   = 79.98
(2, 3, 2),  -- Fire Stick x2   = 79.98
(3, 2, 1),  -- Kindle x1       = 129.99
(4, 1, 1),  -- Echo Dot x1     = 49.99
(5, 5, 1);  -- Wireless Mouse  = 24.99

-- 1.List all customers who have made purchases of more than $80 --

SELECT DISTINCT u.user_id, u.name, u.email
FROM Users u
JOIN Orders o ON o.user_id = u.user_id
WHERE o.total_amount > 80;


SELECT u.user_id, u.name, u.email, SUM(o.total_amount) AS total_spent
FROM Users u
JOIN Orders o ON o.user_id = u.user_id
GROUP BY u.user_id, u.name, u.email
HAVING SUM(o.total_amount) > 80;


SELECT o.order_id, o.order_date, o.total_amount, u.name, u.email
FROM Orders o
JOIN Users u ON u.user_id = o.user_id
WHERE o.order_date >= CURDATE() - INTERVAL 280 DAY;


SELECT o.order_id, o.order_date, o.total_amount, u.name, u.email
FROM Orders o
JOIN Users u ON u.user_id = o.user_id
WHERE o.order_date >= CURDATE() - INTERVAL 1000 DAY;






-- 3.Find the average product price for each category --

SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM Products
GROUP BY category;

-- 4.List all customers who have purchased a product from the category Electronics --

SELECT DISTINCT u.user_id, u.name, u.email
FROM Users u
JOIN Orders o ON o.user_id = u.user_id
JOIN OrderDetails d ON d.order_id = o.order_id
JOIN Products p ON p.product_id = d.product_id
WHERE p.category = 'Electronics';


-- 5.Fnd the total number of products sold and the total revenue generated for each product --

SELECT p.product_id,
       p.name,
       COALESCE(SUM(d.quantity), 0)             AS total_units_sold,
       COALESCE(SUM(d.quantity * p.price), 0)   AS total_revenue
FROM Products p
LEFT JOIN OrderDetails d ON d.product_id = p.product_id
GROUP BY p.product_id, p.name;

-- 6.Update the price of all products in the Books category, increasing it by 10% --

SET SQL_SAFE_UPDATES = 0;

UPDATE Products
SET price = ROUND(price * 1.10, 2)
WHERE category = 'Books';

-- 7.Remove all orders that were placed before 2020 --

DELETE FROM OrderDetails
WHERE order_id IN (SELECT order_id FROM Orders WHERE order_date < '2020-01-01');

DELETE FROM Orders
WHERE order_date < '2020-01-01';

-- 8.Write a query to fetch the order details, including customer name, product name, and quantity, for orders placed on 2024-05-01--

SELECT o.order_id,
       o.order_date,
       u.name AS customer_name,
       p.name AS product_name,
       d.quantity
FROM Orders o
JOIN Users u         ON u.user_id = o.user_id
JOIN OrderDetails d  ON d.order_id = o.order_id
JOIN Products p      ON p.product_id = d.product_id
WHERE o.order_date = '2024-05-01';


-- 9.Fetch all customers and the total number of orders they have placed --

SELECT u.user_id,
       u.name,
       u.email,
       COUNT(o.order_id) AS total_orders
FROM Users u
LEFT JOIN Orders o ON o.user_id = u.user_id
GROUP BY u.user_id, u.name, u.email;


-- 10.Retrieve the average rating for all products in the Electronics category --

SELECT product_id, name, category, rating FROM Products;


-- 11.List all customers who purchased more than 1 units of any product, including the product name and total quantity purchased. --

SELECT u.user_id,
       u.name AS customer_name,
       p.name AS product_name,
       SUM(d.quantity) AS total_quantity
FROM Users u
JOIN Orders o        ON o.user_id = u.user_id
JOIN OrderDetails d  ON d.order_id = o.order_id
JOIN Products p      ON p.product_id = d.product_id
GROUP BY u.user_id, u.name, p.product_id, p.name
HAVING SUM(d.quantity) > 1;


-- 12.Find the total revenue generated by each category along with the category name --

SELECT p.category,
       SUM(d.quantity * p.price) AS total_revenue
FROM Products p
JOIN OrderDetails d ON d.product_id = p.product_id
GROUP BY p.category;


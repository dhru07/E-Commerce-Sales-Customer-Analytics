CREATE DATABASE IF NOT EXISTS ecommerce_analytics;

USE ecommerce_analytics;

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(100),
    signup_date DATE,
    customer_segment VARCHAR(50),
    state VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    sales_channel VARCHAR(50),
    order_status VARCHAR(30),
    shipping_city VARCHAR(100),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    unit_price DECIMAL(12,2),
    unit_cost DECIMAL(12,2)
);

-- Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(12,2),
    unit_cost DECIMAL(12,2),
    discount_pct DECIMAL(5,2),
    gross_amount DECIMAL(14,2),
    discount_amount DECIMAL(14,2),
    net_amount DECIMAL(14,2),
    cost_amount DECIMAL(14,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- Payments
CREATE TABLE payments (
    order_id INT,
    payment_id INT PRIMARY KEY,
    payment_method VARCHAR(50),
    payment_amount DECIMAL(14,2),
    payment_status VARCHAR(30),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- Returns
CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_date DATE,
    return_reason VARCHAR(100),
    refund_status VARCHAR(30),
    refund_amount DECIMAL(14,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

-- Marketing
CREATE TABLE marketing (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(150),
    channel VARCHAR(50),
    month DATE,
    spend DECIMAL(14,2),
    impressions INT,
    clicks INT,
    conversions INT
);


SHOW TABLES;

DESCRIBE customers;

DESCRIBE order_items;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

ALTER TABLE marketing
MODIFY COLUMN campaign_id VARCHAR(20);

USE ecommerce_analytics;

ALTER TABLE marketing
DROP PRIMARY KEY;

ALTER TABLE marketing
ADD COLUMN marketing_id INT AUTO_INCREMENT PRIMARY KEY FIRST;


SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns

UNION ALL

SELECT 'marketing', COUNT(*)
FROM marketing;
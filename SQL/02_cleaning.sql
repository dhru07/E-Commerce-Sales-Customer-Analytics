USE ecommerce_analytics;

SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_order_items_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS orphan_payments
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_returns
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Null Checks

-- Customers
SELECT
    SUM(age IS NULL) AS null_age,
    SUM(city IS NULL) AS null_city,
    SUM(signup_date IS NULL) AS null_signup_date
FROM customers;

-- Orders
SELECT
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(sales_channel IS NULL) AS null_sales_channel
FROM orders;

-- Products
SELECT
    SUM(unit_price IS NULL) AS null_unit_price,
    SUM(unit_cost IS NULL) AS null_unit_cost
FROM products;

-- Order Items
SELECT
    SUM(quantity IS NULL) AS null_quantity,
    SUM(unit_price IS NULL) AS null_unit_price,
    SUM(unit_cost IS NULL) AS null_unit_cost
FROM order_items;

-- Check invalid business values

-- Invalid quantities
SELECT COUNT(*) AS invalid_quantity
FROM order_items
WHERE quantity IS NULL OR quantity <= 0;

-- Invalid prices/costs
SELECT COUNT(*) AS invalid_price_cost
FROM order_items
WHERE unit_price <= 0
   OR unit_cost <= 0;

-- Invalid discounts
SELECT COUNT(*) AS invalid_discount
FROM order_items
WHERE discount_pct < 0
   OR discount_pct > 100;

-- Invalid product prices/costs
SELECT COUNT(*) AS invalid_product_values
FROM products
WHERE unit_price <= 0
   OR unit_cost <= 0;

-- Validate Statuses

-- Order statuses
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Sales channels
SELECT
    sales_channel,
    COUNT(*) AS order_count
FROM orders
GROUP BY sales_channel
ORDER BY order_count DESC;

-- Payment statuses
SELECT
    payment_status,
    COUNT(*) AS payment_count
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;

-- Refund statuses
SELECT
    refund_status,
    COUNT(*) AS return_count
FROM returns
GROUP BY refund_status
ORDER BY return_count DESC;
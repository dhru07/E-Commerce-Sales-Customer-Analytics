USE ecommerce_analytics;


-- 1. ONE-TIME VS REPEAT CUSTOMERS

SELECT
    customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue), 2) AS revenue,
    ROUND(SUM(total_profit), 2) AS profit
FROM (
    SELECT
        o.customer_id,

        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
                THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type,

        SUM(oi.gross_amount - oi.discount_amount) AS total_revenue,

        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ) AS total_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
) customer_level

GROUP BY customer_type;


-- 2. CUSTOMER VALUE DISTRIBUTION

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units,
    ROUND(SUM(oi.gross_amount - oi.discount_amount), 2) AS total_revenue,
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS total_profit,
    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS aov,
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount) * 100,
        2
    ) AS profit_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.customer_id

ORDER BY total_revenue DESC;


-- 3. TOP 10 CUSTOMERS BY REVENUE

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.gross_amount - oi.discount_amount), 2) AS total_revenue,
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS total_profit

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.customer_id

ORDER BY total_revenue DESC

LIMIT 10;


-- 4. TOP 10 CUSTOMERS BY PROFIT

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.gross_amount - oi.discount_amount), 2) AS total_revenue,
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS total_profit

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.customer_id

ORDER BY total_profit DESC

LIMIT 10;


-- 5. CUSTOMER ORDER FREQUENCY

SELECT
    total_orders,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue), 2) AS revenue
FROM (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.gross_amount - oi.discount_amount) AS total_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
) customer_level

GROUP BY total_orders

ORDER BY total_orders;


-- 6. CUSTOMER RFM BASE TABLE

SELECT
    o.customer_id,

    DATEDIFF(
        (
            SELECT MAX(order_date)
            FROM orders
            WHERE order_status = 'Delivered'
        ) + INTERVAL 1 DAY,
        MAX(o.order_date)
    ) AS recency_days,

    COUNT(DISTINCT o.order_id) AS frequency,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS monetary

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.customer_id

ORDER BY recency_days;


-- 7. RFM CUSTOMER SEGMENTS

WITH rfm_base AS (

    SELECT
        o.customer_id,

        DATEDIFF(
            (
                SELECT MAX(order_date)
                FROM orders
                WHERE order_status = 'Delivered'
            ) + INTERVAL 1 DAY,
            MAX(o.order_date)
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(
            oi.gross_amount - oi.discount_amount
        ) AS monetary

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
),

rfm_scores AS (

    SELECT
        *,
        
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS m_score

    FROM rfm_base
)

SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score,

    CASE

        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 4
             AND f_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score <= 2
            THEN 'New Customers'

        WHEN r_score <= 2
             AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score <= 2
             AND f_score <= 2
            THEN 'Lost Customers'

        ELSE 'Potential Loyalists'

    END AS customer_segment

FROM rfm_scores

ORDER BY monetary DESC;


-- 8. RFM SEGMENT SUMMARY

WITH rfm_base AS (

    SELECT
        o.customer_id,

        DATEDIFF(
            (
                SELECT MAX(order_date)
                FROM orders
                WHERE order_status = 'Delivered'
            ) + INTERVAL 1 DAY,
            MAX(o.order_date)
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(
            oi.gross_amount - oi.discount_amount
        ) AS monetary

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
),

rfm_scores AS (

    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base
),

segmented AS (

    SELECT
        *,
        CASE

            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 4
                 AND f_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Lost Customers'

            ELSE 'Potential Loyalists'

        END AS customer_segment

    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS revenue,
    ROUND(AVG(monetary), 2) AS avg_customer_value

FROM segmented

GROUP BY customer_segment

ORDER BY revenue DESC;


-- 9. CUSTOMER ACTIVITY STATUS

WITH customer_activity AS (

    SELECT
        o.customer_id,

        DATEDIFF(
            (
                SELECT MAX(order_date)
                FROM orders
                WHERE order_status = 'Delivered'
            ),
            MAX(o.order_date)
        ) AS days_since_last_order

    FROM orders o

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
)

SELECT
    CASE
        WHEN days_since_last_order <= 90
            THEN 'Active'

        WHEN days_since_last_order <= 180
            THEN 'At Risk'

        ELSE 'Inactive'
    END AS activity_status,

    COUNT(*) AS customers

FROM customer_activity

GROUP BY activity_status

ORDER BY customers DESC;


-- Customer segment summary

WITH rfm_base AS (
    SELECT
        o.customer_id,
        DATEDIFF(
            (SELECT MAX(order_date)
             FROM orders
             WHERE order_status = 'Delivered') + INTERVAL 1 DAY,
            MAX(o.order_date)
        ) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.gross_amount - oi.discount_amount) AS monetary
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),

rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base
),

segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3
                THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2
                THEN 'Lost Customers'
            ELSE 'Potential Loyalists'
        END AS customer_segment
    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS revenue,
    ROUND(AVG(monetary), 2) AS avg_customer_value
FROM segmented
GROUP BY customer_segment
ORDER BY revenue DESC;


-- Customer activity status

WITH customer_activity AS (
    SELECT
        o.customer_id,
        DATEDIFF(
            (SELECT MAX(order_date)
             FROM orders
             WHERE order_status = 'Delivered'),
            MAX(o.order_date)
        ) AS days_since_last_order
    FROM orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
)

SELECT
    CASE
        WHEN days_since_last_order <= 90 THEN 'Active'
        WHEN days_since_last_order <= 180 THEN 'At Risk'
        ELSE 'Inactive'
    END AS activity_status,
    COUNT(*) AS customers
FROM customer_activity
GROUP BY activity_status
ORDER BY customers DESC;

-- 1. MONTHLY REVENUE GROWTH

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / previous_month_revenue * 100,
        2
    ) AS revenue_growth_pct

FROM (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue

    FROM (
        SELECT
            DATE_FORMAT(o.order_date, '%Y-%m') AS month,
            SUM(
                oi.gross_amount - oi.discount_amount
            ) AS revenue

        FROM orders o

        JOIN order_items oi
            ON o.order_id = oi.order_id

        WHERE o.order_status = 'Delivered'

        GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
    ) monthly_sales
) growth

ORDER BY month;


-- 2. TOP PRODUCTS BY REVENUE VS PROFIT

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount) * 100,
        2
    ) AS profit_margin_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory

ORDER BY revenue DESC

LIMIT 20;


-- 3. HIGH-REVENUE, LOW-MARGIN PRODUCTS

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount) * 100,
        2
    ) AS profit_margin_pct,

    SUM(oi.quantity) AS units_sold

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory

HAVING
    SUM(oi.gross_amount - oi.discount_amount) >= 5000000

ORDER BY profit_margin_pct ASC;


-- 4. REPEAT CUSTOMER RATE

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        )
        / COUNT(*) * 100,
        2
    ) AS repeat_customer_rate_pct

FROM (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM orders o

    WHERE o.order_status = 'Delivered'

    GROUP BY o.customer_id
) customer_orders;


-- 5. DISCOUNT IMPACT ON PROFITABILITY

SELECT
    CASE
        WHEN oi.discount_pct = 0 THEN 'No Discount'
        WHEN oi.discount_pct <= 10 THEN '1-10%'
        WHEN oi.discount_pct <= 20 THEN '11-20%'
        WHEN oi.discount_pct <= 30 THEN '21-30%'
        ELSE '30%+'
    END AS discount_band,

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount) * 100,
        2
    ) AS profit_margin_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY discount_band

ORDER BY
    CASE discount_band
        WHEN 'No Discount' THEN 1
        WHEN '1-10%' THEN 2
        WHEN '11-20%' THEN 3
        WHEN '21-30%' THEN 4
        WHEN '30%+' THEN 5
    END;


-- 6. PAYMENT STATUS VS ORDER STATUS

SELECT
    o.order_status,
    p.payment_status,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(p.payment_amount),
        2
    ) AS payment_amount

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY
    o.order_status,
    p.payment_status

ORDER BY
    o.order_status,
    p.payment_status;


-- 7. ORDER STATUS SUMMARY

SELECT
    order_status,
    COUNT(*) AS orders,

    ROUND(
        COUNT(*) /
        (SELECT COUNT(*) FROM orders) * 100,
        2
    ) AS order_share_pct

FROM orders

GROUP BY order_status

ORDER BY orders DESC;


-- 8. CHANNEL PERFORMANCE WITH REVENUE SHARE

SELECT
    o.sales_channel,

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        /
        (
            SELECT SUM(
                oi2.gross_amount - oi2.discount_amount
            )
            FROM order_items oi2
            JOIN orders o2
                ON oi2.order_id = o2.order_id
            WHERE o2.order_status = 'Delivered'
        ) * 100,
        2
    ) AS revenue_share_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.sales_channel

ORDER BY revenue DESC;


-- 9. CATEGORY PROFITABILITY

SELECT
    p.category,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount) * 100,
        2
    ) AS profit_margin_pct,

    SUM(oi.quantity) AS units_sold

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY p.category

ORDER BY profit DESC;


-- 10. RETURN RATE BY RETURN REASON

SELECT
    return_reason,
    COUNT(DISTINCT order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT order_id)
        /
        (SELECT COUNT(DISTINCT order_id) FROM returns)
        * 100,
        2
    ) AS return_share_pct

FROM returns

GROUP BY return_reason

ORDER BY returned_orders DESC;
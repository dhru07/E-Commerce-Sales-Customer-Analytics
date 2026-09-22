-- KPI 1 — Total Revenue


SELECT
    ROUND(SUM(oi.gross_amount - oi.discount_amount), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';

-- KPI 2 — Total Profit

SELECT
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS total_profit
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';


-- KPI 3 — Delivered Orders

SELECT
    COUNT(DISTINCT order_id) AS delivered_orders
FROM orders
WHERE order_status = 'Delivered';

-- KPI 4 — Total Units Sold

SELECT
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';


-- KPI 5 — Unique Customers

SELECT
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM orders o
WHERE o.order_status = 'Delivered';


-- KPI 6 — Average Order Value

SELECT
    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';


-- KPI 7 — Overall Profit Margin

SELECT
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
        2
    ) AS profit_margin_pct
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';


-- KPI 8 — Monthly Revenue, Profit & Orders

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.gross_amount - oi.discount_amount), 2) AS revenue,
    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        ),
        2
    ) AS profit,
    COUNT(DISTINCT o.order_id) AS orders
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;


-- Profit Margins

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,

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

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS aov

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')

ORDER BY month;


-- Category performance

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

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS aov

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY p.category

ORDER BY revenue DESC;


-- Subcategory performance

SELECT
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

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
        2
    ) AS profit_margin_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY
    p.category,
    p.subcategory

ORDER BY revenue DESC;



-- Top 10 products by revenue

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
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
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

LIMIT 10;



-- Top 10 products by profit

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
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
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

ORDER BY profit DESC

LIMIT 10;


-- Products with meaningful revenue but low profit margins

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
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
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



-- Sales channel performance

SELECT
    o.sales_channel,

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

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            (oi.gross_amount - oi.discount_amount)
            - oi.cost_amount
        )
        / SUM(oi.gross_amount - oi.discount_amount)
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(oi.gross_amount - oi.discount_amount)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS aov

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Delivered'

GROUP BY o.sales_channel

ORDER BY revenue DESC;



-- Overall return analysis

SELECT
    COUNT(DISTINCT r.order_id) AS returned_orders,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id)
        * 100,
        2
    ) AS return_rate_pct

FROM orders o

LEFT JOIN returns r
    ON o.order_id = r.order_id

WHERE o.order_status = 'Delivered';



-- Return reasons

SELECT
    r.return_reason,
    COUNT(DISTINCT r.order_id) AS returned_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / (
            SELECT COUNT(DISTINCT order_id)
            FROM returns
        ) * 100,
        2
    ) AS return_share_pct

FROM returns r

GROUP BY r.return_reason

ORDER BY returned_orders DESC;



-- Return rate by category

SELECT
    p.category,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        COUNT(DISTINCT r.order_id)
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS return_rate_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN returns r
    ON o.order_id = r.order_id

WHERE o.order_status = 'Delivered'

GROUP BY p.category

ORDER BY return_rate_pct DESC;



-- Return reasons by category

SELECT
    p.category,
    r.return_reason,
    COUNT(DISTINCT r.order_id) AS returned_orders

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN returns r
    ON o.order_id = r.order_id

WHERE o.order_status = 'Delivered'

GROUP BY
    p.category,
    r.return_reason

ORDER BY
    p.category,
    returned_orders DESC;


-- Marketing channel performance

SELECT
    channel,
    ROUND(SUM(spend), 2) AS total_spend,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions,

    ROUND(
        SUM(clicks) / SUM(impressions) * 100,
        2
    ) AS ctr_pct,

    ROUND(
        SUM(conversions) / SUM(clicks) * 100,
        2
    ) AS conversion_rate_pct,

    ROUND(
        SUM(spend) / SUM(conversions),
        2
    ) AS cost_per_conversion

FROM marketing

GROUP BY channel

ORDER BY total_spend DESC;



-- Campaign performance

SELECT
    campaign_id,
    campaign_name,
    channel,
    ROUND(SUM(spend), 2) AS total_spend,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions,

    ROUND(
        SUM(clicks) / SUM(impressions) * 100,
        2
    ) AS ctr_pct,

    ROUND(
        SUM(conversions) / SUM(clicks) * 100,
        2
    ) AS conversion_rate_pct,

    ROUND(
        SUM(spend) / SUM(conversions),
        2
    ) AS cost_per_conversion

FROM marketing

GROUP BY
    campaign_id,
    campaign_name,
    channel

ORDER BY cost_per_conversion ASC;

-- Monthly marketing performance

SELECT
    DATE_FORMAT(month, '%Y-%m') AS month,
    ROUND(SUM(spend), 2) AS total_spend,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions,

    ROUND(
        SUM(clicks) / SUM(impressions) * 100,
        2
    ) AS ctr_pct,

    ROUND(
        SUM(conversions) / SUM(clicks) * 100,
        2
    ) AS conversion_rate_pct,

    ROUND(
        SUM(spend) / SUM(conversions),
        2
    ) AS cost_per_conversion

FROM marketing

GROUP BY DATE_FORMAT(month, '%Y-%m')

ORDER BY month;
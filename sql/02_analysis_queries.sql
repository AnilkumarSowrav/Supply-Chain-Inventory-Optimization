/* =====================================================================
   Supply Chain Inventory Optimization — 02: Analysis queries
   Run after 01_create_and_load.sql. Each query answers one business question
   and reproduces a headline number from the Python notebooks.
   ===================================================================== */
USE SupplyChainDB;
GO

/* ---------------------------------------------------------------------
   Q1. Business overview — shipped orders only
   --------------------------------------------------------------------- */
SELECT  COUNT(DISTINCT order_id)                                   AS orders,
        COUNT(*)                                                   AS order_lines,
        CAST(SUM(sales)              AS DECIMAL(14,0))             AS revenue,
        CAST(SUM(order_item_profit)  AS DECIMAL(14,0))             AS profit,
        CAST(SUM(order_item_profit) / SUM(sales) AS DECIMAL(5,3))  AS profit_margin,
        CAST(AVG(CAST(late_delivery_risk AS FLOAT)) AS DECIMAL(5,3)) AS late_rate
FROM    dbo.order_lines
WHERE   is_cancelled = 0;


/* ---------------------------------------------------------------------
   Q2. Catalog break — products sold per month (why we model Jan 2015 – Sep 2017)
   --------------------------------------------------------------------- */
SELECT  order_month,
        COUNT(DISTINCT product_id)            AS products_sold,
        COUNT(*)                              AS order_lines,
        CAST(SUM(sales) AS DECIMAL(14,0))     AS revenue
FROM    dbo.order_lines
WHERE   order_month >= '2017-06-01'
GROUP BY order_month
ORDER BY order_month;


/* ---------------------------------------------------------------------
   Q3. ABC classification with window functions (model window, shipped)
   A = first 80% of revenue, B = next 15%, C = last 5%
   --------------------------------------------------------------------- */
WITH product_revenue AS (
    SELECT  product_id,
            MAX(product_name)  AS product_name,
            SUM(sales)         AS revenue
    FROM    dbo.order_lines
    WHERE   in_model_window = 1 AND is_cancelled = 0
    GROUP BY product_id
),
ranked AS (
    SELECT  *,
            revenue / SUM(revenue) OVER ()                                          AS rev_share,
            SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING)
              / SUM(revenue) OVER ()                                                AS cum_share
    FROM    product_revenue
),
classified AS (
    SELECT  *,
            CASE WHEN cum_share - rev_share < 0.80 THEN 'A'
                 WHEN cum_share - rev_share < 0.95 THEN 'B'
                 ELSE 'C' END AS abc_class
    FROM    ranked
)
SELECT  abc_class,
        COUNT(*)                                         AS products,
        CAST(SUM(revenue)   AS DECIMAL(14,0))            AS revenue,
        CAST(SUM(rev_share) AS DECIMAL(5,3))             AS revenue_share
FROM    classified
GROUP BY abc_class
ORDER BY abc_class;               -- expect A: 7 products / 0.825


/* ---------------------------------------------------------------------
   Q4. Late delivery by shipping mode: promise vs reality
   --------------------------------------------------------------------- */
SELECT  shipping_mode,
        COUNT(*)                                                     AS order_lines,
        CAST(SUM(sales) AS DECIMAL(14,0))                            AS revenue,
        MAX(ship_days_promised)                                      AS promised_days,
        MIN(ship_days_actual)                                        AS min_actual,
        CAST(AVG(CAST(ship_days_actual AS FLOAT)) AS DECIMAL(4,2))   AS avg_actual,
        MAX(ship_days_actual)                                        AS max_actual,
        CAST(AVG(CAST(late_delivery_risk AS FLOAT)) AS DECIMAL(5,3)) AS late_rate
FROM    dbo.order_lines
WHERE   is_cancelled = 0
GROUP BY shipping_mode
ORDER BY late_rate DESC;


/* ---------------------------------------------------------------------
   Q5. Is Second Class faster than Standard Class? (transit-day distribution)
   --------------------------------------------------------------------- */
SELECT  ship_days_actual,
        CAST(SUM(CASE WHEN shipping_mode = 'Second Class'   THEN 1.0 ELSE 0 END)
             / (SELECT COUNT(*) FROM dbo.order_lines WHERE is_cancelled = 0 AND shipping_mode = 'Second Class')
             AS DECIMAL(5,3)) AS second_class_share,
        CAST(SUM(CASE WHEN shipping_mode = 'Standard Class' THEN 1.0 ELSE 0 END)
             / (SELECT COUNT(*) FROM dbo.order_lines WHERE is_cancelled = 0 AND shipping_mode = 'Standard Class')
             AS DECIMAL(5,3)) AS standard_class_share
FROM    dbo.order_lines
WHERE   is_cancelled = 0
  AND   shipping_mode IN ('Second Class', 'Standard Class')
GROUP BY ship_days_actual
ORDER BY ship_days_actual;        -- both ~20% on each of days 2–6: identical service


/* ---------------------------------------------------------------------
   Q6. Do markets or customer segments explain lateness? (within-mode spread)
   --------------------------------------------------------------------- */
SELECT  shipping_mode,
        market,
        CAST(AVG(CAST(late_delivery_risk AS FLOAT)) AS DECIMAL(5,3)) AS late_rate
FROM    dbo.order_lines
WHERE   is_cancelled = 0
GROUP BY shipping_mode, market
ORDER BY shipping_mode, market;   -- late rate is flat across markets within each mode


/* ---------------------------------------------------------------------
   Q7. Scenarios: late rate with honest promises (A) and Second Class rerouted (B)
   --------------------------------------------------------------------- */
WITH s AS (
    SELECT  shipping_mode, sales, late_delivery_risk, ship_days_actual,
            CASE shipping_mode WHEN 'Same Day' THEN 1 WHEN 'First Class' THEN 2
                               WHEN 'Second Class' THEN 4 ELSE 5 END            AS promise_a,
            CASE WHEN shipping_mode = 'Second Class' THEN 2 ELSE ship_days_actual END AS days_b,
            CASE shipping_mode WHEN 'Same Day' THEN 1 WHEN 'First Class' THEN 2
                               WHEN 'Second Class' THEN 3 ELSE 5 END            AS promise_b
    FROM    dbo.order_lines
    WHERE   is_cancelled = 0
)
SELECT  'Today'                              AS scenario,
        CAST(AVG(CAST(late_delivery_risk AS FLOAT)) AS DECIMAL(5,3))                            AS late_rate,
        CAST(SUM(CASE WHEN late_delivery_risk = 1 THEN sales END) AS DECIMAL(14,0))            AS revenue_delivered_late
FROM s
UNION ALL
SELECT  'A: promise reset',
        CAST(AVG(CASE WHEN ship_days_actual > promise_a THEN 1.0 ELSE 0 END) AS DECIMAL(5,3)),
        CAST(SUM(CASE WHEN ship_days_actual > promise_a THEN sales END) AS DECIMAL(14,0))
FROM s
UNION ALL
SELECT  'B: reset + reroute Second Class',
        CAST(AVG(CASE WHEN days_b > promise_b THEN 1.0 ELSE 0 END) AS DECIMAL(5,3)),
        CAST(SUM(CASE WHEN days_b > promise_b THEN sales END) AS DECIMAL(14,0))
FROM s;                            -- expect 0.573 -> 0.198 -> 0.120

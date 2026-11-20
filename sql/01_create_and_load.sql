/* =====================================================================
   Supply Chain Inventory Optimization — 01: Create database & load data
   Source: data/processed/order_lines_clean.csv (output of notebook 01)
   Grain : one row per order line (order_item_id)
   ===================================================================== */

IF DB_ID('SupplyChainDB') IS NULL
    CREATE DATABASE SupplyChainDB;
GO
USE SupplyChainDB;
GO

DROP TABLE IF EXISTS dbo.order_lines;
GO

CREATE TABLE dbo.order_lines (
    payment_type              VARCHAR(10),
    ship_days_actual          TINYINT,
    ship_days_promised        TINYINT,
    delivery_status           VARCHAR(20),
    late_delivery_risk        BIT,
    category_id               INT,
    category_name             NVARCHAR(50),
    customer_city             NVARCHAR(50),
    customer_country          NVARCHAR(30),
    customer_id               INT,
    customer_segment          VARCHAR(15),
    customer_state            VARCHAR(10),
    department_id             INT,
    department_name           NVARCHAR(30),
    market                    VARCHAR(15),
    order_city                NVARCHAR(60),
    order_country             NVARCHAR(60),
    order_id                  INT,
    order_item_discount       DECIMAL(12,4),
    order_item_discount_rate  DECIMAL(6,4),
    order_item_id             INT          NOT NULL PRIMARY KEY,
    unit_price                DECIMAL(12,4),
    order_item_profit_ratio   DECIMAL(8,4),
    order_item_quantity       INT,
    sales                     DECIMAL(12,4),
    order_item_total          DECIMAL(12,4),
    order_item_profit         DECIMAL(12,4),
    order_region              NVARCHAR(30),
    order_state               NVARCHAR(60),
    order_status              VARCHAR(20),
    product_id                INT,
    product_name              NVARCHAR(100),
    shipping_mode             VARCHAR(20),
    order_date                DATETIME2(0),
    ship_date                 DATETIME2(0),
    delay_days                SMALLINT,
    is_cancelled              BIT,
    in_model_window           BIT,
    order_month               DATE
);
GO

/* Change the path below if your project folder is somewhere else.
   If you get "Operating system error 5 (Access is denied)", the SQL Server
   service can't read your OneDrive folder. Either copy the CSV to C:\Temp\ and
   point the path there, or use SSMS > right-click database > Tasks > Import Flat File. */
BULK INSERT dbo.order_lines
FROM 'C:\Users\sowra\OneDrive\Desktop\Supply-Chain-Inventory-Optimization\data\processed\order_lines_clean.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDQUOTE      = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',   -- UTF-8 (city names have accents)
    TABLOCK
);
GO

/* ---------- Validation: should match the notebook ---------- */
SELECT COUNT(*)                         AS row_count,          -- expect 180,519
       COUNT(DISTINCT order_id)         AS orders,             -- expect 65,752
       COUNT(DISTINCT product_id)       AS products,           -- expect 118
       CAST(SUM(sales) AS DECIMAL(14,2)) AS total_sales,
       MIN(order_date)                  AS first_order,
       MAX(order_date)                  AS last_order
FROM dbo.order_lines;

SELECT shipping_mode,
       COUNT(*)                                        AS order_lines,
       CAST(AVG(CAST(late_delivery_risk AS FLOAT)) AS DECIMAL(5,2)) AS late_rate,
       AVG(CAST(ship_days_promised AS FLOAT))          AS promised_days,
       AVG(CAST(ship_days_actual   AS FLOAT))          AS actual_days
FROM dbo.order_lines
GROUP BY shipping_mode
ORDER BY late_rate DESC;

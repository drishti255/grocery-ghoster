-- ============================================================
-- FILE: 02_customer_cohorts.sql
-- PROJECT: The Grocery Ghoster
-- PURPOSE: Build a customer-level cohort table by aggregating
--          order behavior and joining in pre-computed features.
--          One row per customer. Foundation for churn analysis.
-- ============================================================

-- Set context so every query knows where to look
USE DATABASE INSTACART_STAGING;
USE SCHEMA INSTACART;

-- ============================================================
-- CREATE TABLE: customer_cohorts
-- 
-- We JOIN two tables here:
--   STG_ORDERS: raw order-level data (one row per order)
--   STG_CUSTOMER_SUMMARY: pre-aggregated features from Python
--
-- Why GROUP BY? Because STG_ORDERS has 3.3M rows (one per order)
-- but we want ONE row per customer. GROUP BY collapses all of
-- a customer's orders into a single summary row.
--
-- Why MIN(order_number)? Every customer's first order is #1.
-- MIN just ensures we're anchoring to their starting point.
--
-- Why JOIN on user_id? That's the shared key between both tables.
-- It's like a VLOOKUP in Excel — match customers across tables.
-- ============================================================

CREATE OR REPLACE TABLE customer_cohorts AS
SELECT
    o.user_id,                          -- Unique customer ID
    MIN(o.order_number) AS first_order_number,  -- Always 1, anchors cohort start
    MIN(o.order_dow) AS first_order_dow,        -- Day of week of first order (0=Sun, 6=Sat)
    COUNT(o.order_id) AS total_orders,          -- How many orders this customer placed
    c.avg_days_between,                 -- Average gap between orders (from Python ETL)
    c.std_days_between,                 -- Std deviation of gaps (high = irregular shopper)
    c.max_gap                           -- Longest gap ever recorded (key churn signal)
FROM STG_ORDERS o
JOIN STG_CUSTOMER_SUMMARY c ON o.user_id = c.user_id  -- Match each order to its customer summary
GROUP BY o.user_id, c.avg_days_between, c.std_days_between, c.max_gap;
-- Note: we GROUP BY all non-aggregated columns (Snowflake requires this)

-- ============================================================
-- SANITY CHECK: Preview first 10 rows
-- Should show one row per customer with all 7 columns populated
-- ============================================================
SELECT * FROM customer_cohorts LIMIT 10;
-- ============================================================
-- FILE: 04_retention_metrics.sql
-- PROJECT: The Grocery Ghoster
-- PURPOSE: Measure how many customers reach each order milestone
--          and what % of their segment they represent.
--          This is order-based retention — since this dataset has
--          no calendar dates, we use order count as a proxy for time.
--
-- KEY INSIGHT: The biggest customer drop-off happens between
--          order 5 and order 10. That's the critical intervention
--          window — customers deciding if Instacart is a habit.
-- ============================================================

USE DATABASE INSTACART_STAGING;
USE SCHEMA INSTACART;

-- ============================================================
-- APPROACH 1: WIDE FORMAT
-- One row per segment, one column per milestone.
-- Good for a quick side-by-side comparison across milestones.
-- Limitation: harder to visualize in Tableau, gets wide fast.
-- ============================================================

SELECT
    customer_segment,
    COUNT(*)                                                         AS total_customers,

    -- Each CASE WHEN counts customers who reached that milestone.
    -- SUM(CASE WHEN condition THEN 1 ELSE 0 END) is SQL's way of
    -- counting rows that meet a condition — like COUNTIF in Excel.
    SUM(CASE WHEN total_orders >= 5  THEN 1 ELSE 0 END)             AS reached_order_5,
    SUM(CASE WHEN total_orders >= 10 THEN 1 ELSE 0 END)             AS reached_order_10,
    SUM(CASE WHEN total_orders >= 20 THEN 1 ELSE 0 END)             AS reached_order_20,
    SUM(CASE WHEN total_orders >= 30 THEN 1 ELSE 0 END)             AS reached_order_30,
    SUM(CASE WHEN total_orders >= 50 THEN 1 ELSE 0 END)             AS reached_order_50,

    -- Retention rate at order 10 as a quick benchmark
    ROUND(SUM(CASE WHEN total_orders >= 10 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS retention_rate_10

FROM churn_flags
GROUP BY customer_segment
ORDER BY customer_segment;

-- ============================================================
-- APPROACH 2: LONG FORMAT (PREFERRED FOR TABLEAU)
-- One row per segment per milestone.
-- Much cleaner for visualization — Tableau loves long format.
-- Each UNION ALL block adds one milestone as its own set of rows.
--
-- WHY UNION ALL?
-- We can't dynamically generate rows in standard SQL, so we
-- manually stack one query per milestone using UNION ALL.
-- UNION ALL = stack results on top of each other, keep all rows.
-- (vs UNION which deduplicates — we don't want that here)
--
-- WHY THE JOIN?
-- We need each segment's total customer count to calculate
-- retention rate WITHIN that segment, not across all customers.
-- The subquery calculates segment totals, then we JOIN it back
-- so every row knows its segment's baseline.
-- ============================================================

CREATE OR REPLACE TABLE retention_metrics AS

SELECT customer_segment, days_segment, 5 AS order_milestone,
    COUNT(*) AS customers_reached,
    ROUND(COUNT(*) / MAX(seg_total.seg_customers) * 100, 2) AS retention_rate
FROM churn_flags
JOIN (SELECT customer_segment AS seg, COUNT(*) AS seg_customers 
      FROM churn_flags GROUP BY customer_segment) seg_total
ON churn_flags.customer_segment = seg_total.seg
WHERE total_orders >= 5
GROUP BY customer_segment, days_segment

UNION ALL

SELECT customer_segment, days_segment, 10 AS order_milestone,
    COUNT(*) AS customers_reached,
    ROUND(COUNT(*) / MAX(seg_total.seg_customers) * 100, 2) AS retention_rate
FROM churn_flags
JOIN (SELECT customer_segment AS seg, COUNT(*) AS seg_customers 
      FROM churn_flags GROUP BY customer_segment) seg_total
ON churn_flags.customer_segment = seg_total.seg
WHERE total_orders >= 10
GROUP BY customer_segment, days_segment

UNION ALL

SELECT customer_segment, days_segment, 20 AS order_milestone,
    COUNT(*) AS customers_reached,
    ROUND(COUNT(*) / MAX(seg_total.seg_customers) * 100, 2) AS retention_rate
FROM churn_flags
JOIN (SELECT customer_segment AS seg, COUNT(*) AS seg_customers 
      FROM churn_flags GROUP BY customer_segment) seg_total
ON churn_flags.customer_segment = seg_total.seg
WHERE total_orders >= 20
GROUP BY customer_segment, days_segment

UNION ALL

SELECT customer_segment, days_segment, 30 AS order_milestone,
    COUNT(*) AS customers_reached,
    ROUND(COUNT(*) / MAX(seg_total.seg_customers) * 100, 2) AS retention_rate
FROM churn_flags
JOIN (SELECT customer_segment AS seg, COUNT(*) AS seg_customers 
      FROM churn_flags GROUP BY customer_segment) seg_total
ON churn_flags.customer_segment = seg_total.seg
WHERE total_orders >= 30
GROUP BY customer_segment, days_segment

UNION ALL

SELECT customer_segment, days_segment, 50 AS order_milestone,
    COUNT(*) AS customers_reached,
    ROUND(COUNT(*) / MAX(seg_total.seg_customers) * 100, 2) AS retention_rate
FROM churn_flags
JOIN (SELECT customer_segment AS seg, COUNT(*) AS seg_customers 
      FROM churn_flags GROUP BY customer_segment) seg_total
ON churn_flags.customer_segment = seg_total.seg
WHERE total_orders >= 50
GROUP BY customer_segment, days_segment

ORDER BY customer_segment, order_milestone;

-- ============================================================
-- FINAL OUTPUT: Preview retention_metrics table
-- Expected: 4 segments x 5 milestones = ~20 rows
-- Use this table directly in Tableau for the retention curve viz
-- ============================================================

SELECT * FROM retention_metrics ORDER BY customer_segment, order_milestone;
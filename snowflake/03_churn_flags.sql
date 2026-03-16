-- ============================================================
-- FILE: 03_churn_flags.sql
-- PROJECT: The Grocery Ghoster
-- PURPOSE: Define and flag churned customers using a behavioral
--          definition personalized to each customer's order pattern.
--
-- KEY INSIGHT: This dataset caps days_since_prior at 30 days,
-- making fixed threshold churn (>30 days) meaningless — nearly
-- everyone hits that cap. Instead, we use a BEHAVIORAL definition:
-- if a customer's longest gap exceeds 2x their personal average,
-- they broke their pattern. That's our churn signal.
-- ============================================================

USE DATABASE INSTACART_STAGING;
USE SCHEMA INSTACART;

-- ============================================================
-- STEP 1: EXPLORE THE DATA BEFORE DEFINING CHURN
-- Always look at your data distribution before hardcoding thresholds.
-- This percentile query revealed that max_gap is capped at 30 for
-- nearly all customers — which invalidated the threshold approach.
-- ============================================================

SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY max_gap) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY max_gap) AS p50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY max_gap) AS p75,
    PERCENTIC_CONT(0.90) WITHIN GROUP (ORDER BY max_gap) AS p90,
    MAX(max_gap) AS max_value
FROM customer_cohorts;
-- Result: p25=27, p50=30, p75=30, p90=30, max=30
-- Conclusion: 30-day threshold is useless here. Switching to behavioral definition.

-- ============================================================
-- STEP 2: CREATE CHURN FLAGS TABLE
--
-- One row per customer. Built from customer_cohorts.
-- Adds three new columns:
--   is_churned      — 1 if max_gap > 2x avg, else 0
--   customer_segment — frequency label based on avg ordering cadence
--   days_segment     — readable day range label for dashboards
--
-- WHY CASE WHEN?
-- There's no churn column in the raw data — we have to derive it.
-- CASE WHEN is SQL's if/else. It evaluates a condition row by row
-- and returns a value based on whether it's true or false.
--
-- WHY 2x avg_days_between?
-- A customer who orders every 7 days is churning if they go 14+ days.
-- A customer who orders every 20 days is fine at 30 days.
-- This personalizes the threshold instead of applying one size fits all.
-- ============================================================

CREATE OR REPLACE TABLE churn_flags AS
SELECT
    user_id,
    total_orders,
    avg_days_between,
    std_days_between,
    max_gap,

    -- CHURN FLAG
    -- If the longest gap ever recorded exceeds 2x their normal cadence,
    -- they broke their pattern — we flag them as churned.
    CASE
        WHEN max_gap > (avg_days_between * 2) THEN 1
        ELSE 0
    END AS is_churned,

    -- FREQUENCY SEGMENT
    -- Groups customers by how often they typically order.
    -- These buckets map to real shopping behaviors:
    --   High Frequency  = weekly shoppers (fresh produce, daily essentials)
    --   Medium Frequency = bi-weekly shoppers (regular household stock-ups)
    --   Low Frequency   = monthly shoppers (bulk or occasional)
    --   Infrequent      = rare shoppers (one-off or nearly lapsed)
    CASE
        WHEN avg_days_between <= 7  THEN 'High Frequency'
        WHEN avg_days_between <= 14 THEN 'Medium Frequency'
        WHEN avg_days_between <= 21 THEN 'Low Frequency'
        ELSE 'Infrequent'
    END AS customer_segment,

    -- DAYS SEGMENT
    -- Same bucketing as above but as a readable range for dashboards.
    -- Useful when you want the label to show "8-14 days" instead of
    -- "Medium Frequency" — both tell a story, just different audiences.
    CASE
        WHEN avg_days_between <= 7  THEN '1-7 days'
        WHEN avg_days_between <= 14 THEN '8-14 days'
        WHEN avg_days_between <= 21 THEN '15-21 days'
        ELSE '22+ days'
    END AS days_segment

FROM customer_cohorts;

-- ============================================================
-- STEP 3: VALIDATE — CHURN RATE BY SEGMENT
--
-- This query answers: which customer segments churn the most?
-- GROUP BY collapses all customers in each segment into one row.
-- SUM(is_churned) counts how many 1s are in that group.
-- Dividing by COUNT(*) gives the churn rate as a decimal,
-- multiplied by 100 and rounded to give a clean percentage.
--
-- KEY FINDING:
-- High and Medium Frequency customers churn most (70-80%).
-- This is counterintuitive — your most engaged customers are
-- also your most at-risk. They have a strong pattern, so when
-- they break it, it's a meaningful signal worth acting on.
-- ============================================================

SELECT
    customer_segment,
    days_segment,
    COUNT(*)                                          AS total_customers,
    SUM(is_churned)                                   AS churned,
    ROUND(SUM(is_churned) / COUNT(*) * 100, 2)        AS churn_rate
FROM churn_flags
GROUP BY customer_segment, days_segment
ORDER BY churn_rate DESC;
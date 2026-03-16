-- ============================================================
-- FILE: 01_staging_orders.sql
-- PROJECT: The Grocery Ghoster
-- PURPOSE: Set up the database, schema, and staging tables.
--          Staging = clean, typed, structured data.
--          No business logic here — just the foundation.
-- ============================================================

-- ============================================================
-- STEP 1: Set database and create schema
--
-- DATABASE: already exists (INSTACART_STAGING)
-- SCHEMA: think of it like a folder inside the database.
--         All our project tables live inside INSTACART schema.
-- ============================================================

USE DATABASE INSTACART_STAGING;
CREATE SCHEMA IF NOT EXISTS INSTACART;
USE SCHEMA INSTACART;

-- ============================================================
-- TABLE 1: STG_ORDERS
-- Source: orders_clean.csv (3,346,083 rows)
-- One row per order. Contains order sequence, timing, and gap data.
--
-- Column notes:
--   order_id        — unique identifier for each order
--   user_id         — the customer who placed the order
--   eval_set        — 'prior' or 'train' (we dropped 'test' in ETL)
--   order_number    — sequence number for this customer (1 = first ever)
--   order_dow       — day of week (0 = Sunday, 6 = Saturday)
--   order_hour_of_day — hour the order was placed (0–23)
--   days_since_prior — days since this customer's last order (NULL for order #1)
-- ============================================================

CREATE OR REPLACE TABLE stg_orders (
    order_id          INTEGER,
    user_id           INTEGER,
    eval_set          VARCHAR(10),
    order_number      INTEGER,
    order_dow         INTEGER,
    order_hour_of_day INTEGER,
    days_since_prior  FLOAT
);

-- ============================================================
-- TABLE 2: STG_CUSTOMER_SUMMARY
-- Source: customer_summary.csv (206,209 rows)
-- One row per customer. Pre-aggregated in Python (Notebook 1).
--
-- Column notes:
--   user_id           — unique customer identifier (joins to stg_orders)
--   total_orders      — how many orders this customer placed
--   avg_days_between  — average gap between consecutive orders
--   std_days_between  — std deviation of gaps (high = irregular shopper)
--   max_gap           — longest recorded gap (strongest churn signal)
-- ============================================================

CREATE OR REPLACE TABLE stg_customer_summary (
    user_id              INTEGER,
    total_orders         INTEGER,
    avg_days_between     FLOAT,
    std_days_between     FLOAT,
    max_gap              FLOAT
);

-- ============================================================
-- VALIDATION: Run these after loading CSVs to confirm data quality
-- Expected results:
--   STG_ORDERS: 3,346,083 rows
--   STG_CUSTOMER_SUMMARY: 206,209 rows
-- ============================================================

SELECT COUNT(*) FROM INSTACART_STAGING.INSTACART.STG_ORDERS;
SELECT COUNT(*) FROM INSTACART_STAGING.INSTACART.STG_CUSTOMER_SUMMARY;
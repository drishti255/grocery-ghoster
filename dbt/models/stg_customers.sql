-- this is from churn flags table from snowflake

-- Model: stg_customers
-- Source: INSTACART_STAGING.INSTACART.CHURN_FLAGS
-- Description: Staging model for customer-level churn data. One row per customer.
--              Named after the business entity (customers) not the source table.
--              No transformation — clean passthrough for downstream mart models.

with source as (
    select * from {{ source('instacart', 'churn_flags') }}
)

select
    user_id,
    total_orders,
    avg_days_between,
    std_days_between,
    max_gap,
    is_churned,
    customer_segment
from source

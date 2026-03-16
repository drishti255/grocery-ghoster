-- Model: stg_retention
-- Source: INSTACART_STAGING.INSTACART.RETENTION_METRICS
-- Description: Staging model for order milestone retention data.
--              Clean passthrough — retention_rate already calculated in SQL layer.
--              Added to maintain consistent staging architecture across all sources.

with source as (
    select * from {{ source('instacart', 'retention_metrics') }}
)

select
    order_milestone,
    days_segment,
    customer_segment,
    customers_reached,
    retention_rate
from source

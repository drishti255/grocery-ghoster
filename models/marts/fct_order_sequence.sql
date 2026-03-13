-- Model: fct_order_sequence
-- Depends on: stg_retention
-- Description: Exposes order milestone retention curve for Tableau.
--              Shows customer drop-off across order numbers.
--              Critical window (orders 5-10) visible in retention_rate decline.

with retention as (
    select * from {{ ref('stg_retention') }}
)

select
    order_milestone,
    days_segment,
    customer_segment,
    customers_reached,
    retention_rate
from retention
order by order_milestone
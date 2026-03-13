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
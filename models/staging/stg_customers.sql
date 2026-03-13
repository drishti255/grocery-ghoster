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
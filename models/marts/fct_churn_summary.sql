with customers as (
    select * from {{ ref('stg_customers') }}
)

select
    customer_segment,
    count(*) as total_customers,
    sum(is_churned) as churned_customers,
    round(sum(is_churned) * 100.0 / count(*), 2) as churn_rate_pct
from customers
group by customer_segment
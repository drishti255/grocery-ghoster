# 🛒 The Grocery Ghoster
### Identifying and Predicting Customer Disengagement in Online Grocery

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat&logo=postgresql&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat&logo=dbt&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white)

## Why This Project

Most churn analyses ask one question: did the customer leave?

This one asks something harder: when did they start pulling away, and could you have caught it earlier?

I used the public Instacart dataset to look at how customers behave before they go quiet. The patterns I found in grocery (orders slowing down, longer gaps, less variety) look a lot like how employees disengage from workplace benefits. They don't leave all at once. They just slowly stop showing up.

That's what this project is really about.

Full disclosure: I'm an Instacart member myself. I stopped ordering regularly because items kept going out of stock mid-order, which meant I still had to make a store run anyway. At some point it just stopped making sense. I churned. That's what got me curious about how many others did the same, and why.

## The Dataset

Public Instacart dataset from Kaggle. ~3.3 million orders across 206,000 customers. You can download the raw data [here](https://www.kaggle.com/c/instacart-market-basket-analysis/data).

I started with 6 raw files and cleaned them down to one row per customer with four features:

| Feature | What it means |
|---|---|
| `total_orders` | How many times they ordered |
| `avg_days_between` | Their usual ordering pace |
| `std_days_between` | How consistent or irregular they were |
| `max_gap` | The longest they ever went without ordering |

## How I Defined Churn

Instead of a fixed 30-day rule, I made it personal:

```
churned = max_gap > (avg_days_between × 2)
```

If a customer's longest gap was more than double their own usual pace, I flagged them as churned. It's based on their pattern, not a one-size-fits-all cutoff.

## Key Findings

**39.88%** of customers churned.

But the more interesting stuff is underneath that number:

- 🔴 **High-frequency customers churned at ~80%.** The customers who ordered the most still went silent. That's the counterintuitive part.
- 📉 **Orders 5-10 is where most customers dropped off.** 48,634 customers were lost in this window. If someone doesn't build a habit in the first 10 orders, they probably won't.
- 🧺 **Basket size doesn't predict churn.** Customers don't spend less before they leave. They just stop ordering entirely.
- ⭐ **Reorder rate is the strongest loyalty signal.** Customers who kept rebuying the same products were much less likely to churn.

## Tech Stack & Project Architecture

```
Raw Kaggle Data (6 files)
        │
        ▼
  Python / Google Colab          ← Cleaning, joining, feature engineering
        │
        ▼
  Snowflake (SQL)                ← Staging, cohorts, churn flags, retention metrics
        │
        ▼
  dbt Cloud                      ← 4 models: stg_customers, stg_retention,
        │                           fct_churn_summary, fct_order_sequence
        ▼
  Tableau Public                 ← Dashboard: churn rate, segment breakdown,
                                    retention by order milestone
```

## AI-Assisted Development

I used Claude (Anthropic) throughout this project as a thought partner. It helped me think through decisions, debug code, and structure my findings. All the actual building, querying, and analysis was done by me. AI helped me move faster and think more clearly, which is exactly how I'd use it on the job.

This was also my first time working with dbt. I built all four models from scratch, which gave me solid hands-on experience with the transformation layer.

## dbt Models

| Model | Layer | Description |
|---|---|---|
| `stg_customers` | Staging | Cleaned customer-level features |
| `stg_retention` | Staging | Retention metrics formatted for Tableau |
| `fct_churn_summary` | Mart | Churn rate by customer segment |
| `fct_order_sequence` | Mart | Drop-off analysis across order milestones |

## Dashboard

📊 **[View the Tableau Dashboard →](https://public.tableau.com/app/profile/drishti8812/viz/TheGroceryGhoster_CustomerChurnAnalysis/ChurnAnalysisDashboard)**

Three views:
- Overall churn rate (39.88%)
- Churn rate by customer segment
- Customer retention across order milestones 1-10+

## Repository Structure

```
grocery-ghoster/
│
├── notebooks/
│   ├── etl_cleaning.ipynb            # Data loading, cleaning, feature engineering
│   └── 02_churn_analysis.ipynb       # EDA, segmentation, findings
│
├── snowflake/
│   ├── 01_staging_orders.sql
│   ├── 02_customer_cohorts.sql
│   ├── 03_churn_flags.sql
│   └── 04_retention_metrics.sql
│
├── dbt/
│   └── models/
│       ├── stg_customers.sql
│       ├── stg_retention.sql
│       ├── fct_churn_summary.sql
│       └── fct_order_sequence.sql
│
└── README.md
```

## The Bigger Picture

In my previous work supporting enterprise benefits programs, I saw this pattern a lot. Employees would quietly stop engaging with their benefits, and by the time it showed up in reporting, it was too late to do anything about it. The grocery version of that is a customer who stops reordering their usual staples. The gap grows. Nothing else changes. And then they're gone.

This project was about finding that signal earlier.

*Built by Drishti Shishodiya · [LinkedIn](https://www.linkedin.com/in/drishtishishodiya/) · [Tableau Public](https://public.tableau.com/app/profile/drishti8812)*

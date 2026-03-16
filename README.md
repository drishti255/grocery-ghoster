# 🛒 The Grocery Ghoster
### Identifying and Predicting Customer Disengagement in Online Grocery

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat&logo=postgresql&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat&logo=dbt&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white)

---

## Why This Project

Most churn analyses answer the same question: *did the customer leave?*

This one asks something harder: *when did they start to disengage — and could you have seen it coming?*

I built The Grocery Ghoster to go beyond a binary churn label and uncover the **behavioral signals that precede disengagement** in online grocery. The patterns here — declining order frequency, widening gaps, shrinking reorder rates — aren't unique to grocery. They mirror how employees disengage from workplace benefits programs: slowly, quietly, and usually before anyone notices.

That parallel is the real insight. Churn isn't a moment. It's a drift.

---

## The Dataset

Public Instacart dataset from Kaggle — ~3.3 million orders across 206,000 customers.

Starting with 6 raw files, I collapsed the data into one row per customer with four behavioral signals:

| Signal | What it captures |
|---|---|
| `total_orders` | Overall engagement level |
| `avg_days_between` | Baseline ordering rhythm |
| `std_days_between` | Consistency vs. volatility |
| `max_gap` | The longest silence — the disengagement signal |

---

## Churn Definition

Rather than a fixed 30-day rule, I used a **personalized behavioral threshold**:

```
churned = max_gap > (avg_days_between × 2)
```

If a customer's longest silence is more than double their own normal rhythm, that's a churn signal — defined on *their* terms, not an arbitrary cutoff.

---

## Key Findings

**39.88%** of customers show behavioral churn signals.

But the more interesting findings are underneath that number:

- 🔴 **High-frequency customers churn at ~80%** — counterintuitive, but detectable. These are customers with established habits who still go silent.
- 📉 **Orders 5–10 is the critical drop-off window** — 48,634 customers lost here. If a customer doesn't form a habit in the first 10 orders, they likely won't.
- 🧺 **Basket size is NOT an early churn signal** — customers don't spend less before they leave. They just stop.
- ⭐ **Reorder rate is the strongest loyalty signal** — customers who consistently rebuy the same products are far less likely to churn.

---

## Tech Stack & Project Architecture

```
Raw Kaggle Data (6 files)
        │
        ▼
  Python / Google Colab          ← ETL, cleaning, feature engineering
        │
        ▼
  Snowflake (SQL)                ← Staging, cohorts, churn flags, retention metrics
        │
        ▼
  dbt Cloud                      ← 4 models: stg_customers, stg_retention,
        │                           fct_churn_summary, fct_order_sequence
        ▼
  Tableau Public                 ← Dashboard: churn KPI, segment breakdown,
                                    retention by order milestone
```

---

## dbt Models

| Model | Layer | Description |
|---|---|---|
| `stg_customers` | Staging | Cleaned customer-level behavioral signals |
| `stg_retention` | Staging | Retention metrics in long format for Tableau compatibility |
| `fct_churn_summary` | Mart | Churn rate aggregated by segment |
| `fct_order_sequence` | Mart | Drop-off analysis across order milestones |

---

## Dashboard

📊 **[View the Tableau Dashboard →](https://public.tableau.com/app/profile/drishti8812/viz/TheGroceryGhoster_CustomerChurnAnalysis/ChurnAnalysisDashboard)**

Three views:
- Overall churn rate KPI (39.88%)
- Churn rate by customer segment
- Customer retention across order milestones 1–10+

---

## Repository Structure

```
grocery-ghoster/
│
├── notebooks/
│   ├── 01_etl_cleaning.ipynb         # Data loading, cleaning, feature engineering
│   └── 02_churn_analysis.ipynb       # EDA, segmentation, behavioral signatures
│
├── snowflake/
│   ├── stg_orders.sql
│   ├── stg_customer_summary.sql
│   ├── customer_cohorts.sql
│   ├── churn_flags.sql
│   └── retention_metrics.sql
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

---

## The Bigger Picture

The grocery churn signals in this project map directly onto disengagement patterns I've studied in enterprise benefits analytics: a customer who stops reordering staples looks a lot like an employee who stops logging into their benefits portal. The gap widens gradually. The basket doesn't change. And by the time it's visible in aggregate reporting, the window to intervene has already closed.

The goal of this project was to find that window earlier.

---

*Built by Drishti Shishodiya · [LinkedIn](https://www.linkedin.com/in/drishtishishodiya/) · [Tableau Public](https://public.tableau.com/app/profile/drishti8812)*

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

# podyplomowe-modern-data-stack-msp-uam-2026/

## Project Structure

```text
podyplomowe-modern-data-stack-msp-uam-2026/
├── infrastructure/
│   ├── bigquery/
│   │   ├── schema.sql
│   │   └── external_tables/
│   │       ├── ext_books.sql
│   │       ├── ext_customers.sql
│   │       └── ext_transactions.sql
│   ├── docker/
│   └── terraform/
├── transformation/
│   └── dbt-bookstore/
│       ├── dbt_project.yml
│       ├── models/
│       ├── seeds/
│       ├── snapshots/
│       ├── macros/
│       └── tests/
│
├── ingestion/
│   └── bookstore-generator/
│       ├── generator.py
│       ├── books.csv
│       └── README.md
│
├── staging/
│   └── local-data-staging/
│       └── .gitkeep
│
├── orchestration/
│   └── airflow/
│       └── dags/
│           └── daily_data_generator.py
│
│
├── .gitignore
└── README.md
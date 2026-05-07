# podyplomowe-modern-data-stack-msp-uam-2026/

## Project Structure

```text
podyplomowe-modern-data-stack-msp-uam-2026/
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
├── transformation/
│   └── dbt-bookstore/
│       ├── dbt_project.yml
│       ├── models/
│       ├── seeds/
│       ├── snapshots/
│       ├── macros/
│       └── tests/
│
├── orchestration/
│   └── airflow/
│       └── dags/
│           └── daily_data_generator.py
│
├── infrastructure/
│   ├── docker/
│   └── terraform/
│
│
├── .gitignore
└── README.md
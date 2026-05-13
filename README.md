# podyplomowe-modern-data-stack-msp-uam-2026/

## Repo Project Structure

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

```

## Warstwy Hurtowni (BigQuery)

1. **`bookstore_src`**: Tutaj będą żyły tabele zewnętrzne (External Tables).
2. **`bookstore_stg`**: Warstwa Staging - lekkie czyszczenie i standaryzacja.
3. **`bookstore_dwh`**: Główna hurtownia - tabele Faktów i Wymiarów.
4. **`bookstore_semantic`**: Warstwa semantyczna - gotowe raporty i widoki dla BI.
5. **`bookstore_security`**: Bezpieczne miejsce na klucze szyfrujące (keystore).


## Opis projektu dbt

Projekt dbt buduje hurtownię danych dla księgarni internetowej.  
Obejmuje dane dotyczące:
- klientów,
- książek,
- autorów,
- wydawnictw,
- transakcji sprzedażowych.

Dane źródłowe są dostępne w BigQuery w schemacie `bookstore_src` jako:
- `ext_books`,
- `ext_customers`,
- `ext_transactions`.

Warstwa źródłowa nie jest tworzona przez dbt — projekt dbt konsumuje istniejące już dane poprzez definicje `sources`.

---

## Architektura warstw

Projekt został podzielony na kilka logicznych warstw:

### 1. Staging (`models/staging`)
Warstwa odpowiedzialna za:
- czyszczenie danych,
- standaryzację,
- podstawowe transformacje,
- przygotowanie danych do dalszego modelowania.

Najważniejsze modele:
- `stg_books`
- `stg_customers`
- `stg_transactions`
- `user_keys`

W tej warstwie:
- generowane są klucze szyfrowania użytkowników,
- szyfrowane są dane osobowe klientów,
- obsługiwane są rekordy techniczne dla błędnych danych (np. `book_id = -1`).

---

### 2. Prep (`models/prep`)
Warstwa pośrednia odpowiedzialna za:
- wzbogacanie danych,
- łączenie encji,
- przygotowanie danych do modelu analitycznego.

Najważniejszy model:
- `prep_transactions_enriched`

Model:
- łączy transakcje z klientami i książkami,
- rozwija zagnieżdżone pozycje zamówień,
- przygotowuje dane dla warstwy DWH.

---

### 3. DWH / Core (`models/dwh/core`)
Docelowa warstwa analityczna hurtowni danych.

Zawiera:
- tabele wymiarów (`dimensions`),
- tabele faktów (`facts`),
- modele agregacyjne.

#### Wymiary:
- `dim_books`
- `dim_authors`
- `dim_publishers`
- `dim_customers`

#### Fakty:
- `fct_transactions`

#### Dodatkowe modele:
- `flat_transactions`
- `nested_transactions`
- `metrics_daily_sales`

Projekt implementuje klasyczny model gwiazdy (`star schema`).

---

## Testy jakości danych

Projekt wykorzystuje testy dbt oraz `dbt_utils`.

Zaimplementowano m. in. :
- `not_null`,
- `unique`,
- testy relacji (`relationships`),
- testy unikalności kombinacji kluczy.

Testy zapewniają:
- integralność danych,
- poprawność relacji między faktami i wymiarami,
- jakość kluczy biznesowych.

---

## Charakterystyka projektu

Projekt reprezentuje klasyczny przykład architektury Modern Data Stack:
- dane źródłowe w BigQuery,
- transformacje realizowane w dbt,
- warstwowy model hurtowni,
- separacja ingestion / infrastructure / transformation,
- model analityczny typu star schema,
- podstawowe mechanizmy bezpieczeństwa danych (szyfrowanie klientów).
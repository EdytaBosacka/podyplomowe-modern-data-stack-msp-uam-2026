{{ config(materialized='table') }}

SELECT
    transaction_date,
    count(distinct transaction_id) as total_transactions,
    count(distinct customer_id) as unique_customers,
    sum(quantity) as total_books_sold,
    round(sum(total_item_price), 2) as daily_revenue
FROM {{ ref('fct_transactions') }}
GROUP BY transaction_date
ORDER BY transaction_date DESC
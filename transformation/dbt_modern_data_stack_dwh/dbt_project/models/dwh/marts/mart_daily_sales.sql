{{ config(materialized='table') }}

SELECT
    t.transaction_date,

    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.week_of_year,
    d.day_of_week,
    d.day_name,
    d.is_weekend,

    count(*) as transaction_items_count,
    count(distinct t.transaction_id) as total_transactions,
    count(distinct t.customer_id) as unique_customers,
    sum(t.quantity) as total_books_sold,
    round(sum(t.total_item_price), 2) as revenue,
    round(sum(t.total_item_price) / count(distinct t.transaction_id), 2) as avg_revenue_per_transaction

FROM {{ ref('fct_transactions') }} t

LEFT JOIN {{ ref('dim_dates') }} d
    ON t.transaction_date = d.date_id

GROUP BY
    1,2,3,4,5,6,7,8,9

ORDER BY t.transaction_date DESC
{{ config(materialized='table') }}

select
    t.transaction_id,
    t.transaction_date,

    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.week_of_year,
    d.day_of_week,
    d.day_name,
    d.is_weekend,

    t.customer_id,

    count(*) as transaction_items_count,
    sum(t.quantity) as total_books_sold,
    round(sum(t.total_item_price), 2) as basket_value,
    round(avg(t.unit_price), 2) as avg_unit_price

from {{ ref('fct_transactions') }} t

left join {{ ref('dim_dates') }} d
    on t.transaction_date = d.date_id

group by
    1,2,3,4,5,6,7,8,9,10,11
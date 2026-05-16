{{ config(materialized='table') }}

select 
    t.transaction_date,


    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.week_of_year,
    d.day_of_week,
    d.day_name,
    d.is_weekend,

    b.book_id,
    b.title,
    b.publisher_name as book_publisher,
    b.category as book_category,
    a.author_name as book_author,

    count(*) as transaction_items_count,
    count(distinct t.transaction_id) as total_transactions,
    sum(t.quantity) as total_books_sold,
    round(sum(t.total_item_price), 2) as revenue,
    round(sum(t.total_item_price) / count(distinct t.transaction_id), 2) as avg_revenue_per_transaction

from {{ ref('fct_transactions') }} t

inner join {{ ref('dim_books') }} b 
    on t.book_id = b.book_id

inner join {{ ref('dim_authors') }} a 
    on t.author_id = a.author_id

left join {{ ref('dim_dates') }} d
    on t.transaction_date = d.date_id

group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14


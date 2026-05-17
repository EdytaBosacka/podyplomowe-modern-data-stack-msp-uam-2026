{{ config(materialized='table') }}

with customer_sales as (

    select
        t.customer_id,

        count(distinct t.transaction_id) as total_transactions,
        sum(t.quantity) as total_books_sold,
        round(sum(t.total_item_price), 2) as total_spent,
        round(sum(t.total_item_price) / count(distinct t.transaction_id), 2) as avg_basket_value, --avg_transaction_value

        min(t.transaction_date) as first_purchase_date,
        max(t.transaction_date) as last_purchase_date

    from {{ ref('fct_transactions') }} t

    group by
        t.customer_id
),

favorite_genre as (

    select
        customer_id,
        book_category as favorite_genre
    from (
        select
            t.customer_id,
            b.category as book_category,
            sum(t.total_item_price) as genre_revenue,
            row_number() over (
                partition by t.customer_id
                order by sum(t.total_item_price) desc
            ) as rn

        from {{ ref('fct_transactions') }} t

        inner join {{ ref('dim_books') }} b
            on t.book_id = b.book_id

        group by
            t.customer_id,
            b.category
    )

    where rn = 1
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.registration_date,

    cs.total_transactions,
    cs.total_books_sold,
    cs.total_spent,
    cs.avg_basket_value,
    cs.first_purchase_date,
    cs.last_purchase_date,

    fg.favorite_genre

from customer_sales cs

inner join {{ ref('dim_customers') }} c
    on cs.customer_id = c.customer_id

left join favorite_genre fg
    on cs.customer_id = fg.customer_id
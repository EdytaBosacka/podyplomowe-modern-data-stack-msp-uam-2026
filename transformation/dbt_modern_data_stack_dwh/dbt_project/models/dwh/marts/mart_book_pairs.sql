{{ config(materialized='table') }}

with transaction_books as (

    select distinct
        t.transaction_id,
        t.book_id,
        b.title
    from {{ ref('fct_transactions') }} t

    inner join {{ ref('dim_books') }} b
        on t.book_id = b.book_id
),

book_pairs as (

    select
        a.book_id as book_1_id,
        a.title as book_1_title,
        b.book_id as book_2_id,
        b.title as book_2_title,
        count(distinct a.transaction_id) as pair_transactions_count

    from transaction_books a

    inner join transaction_books b
        on a.transaction_id = b.transaction_id
        and a.book_id < b.book_id

    group by
        1,2,3,4
)

select *
from book_pairs
order by pair_transactions_count desc
{{ config(materialized='table') }}

select 
t.transaction_date,
b.publisher_name as book_publisher,
b.category as book_category,
a.author_name as book_author,
sum(t.quantity) as books_sold,
sum(t.total_item_price) as total_price,
count(*) as transaction_count
from `bookstore_dwh.fct_transactions`  t
inner join `bookstore_dwh.dim_books`  b on t.book_id=b.book_id
inner join `bookstore_dwh.dim_authors`  a on t.author_id=a.author_id
group by
1,2,3,4



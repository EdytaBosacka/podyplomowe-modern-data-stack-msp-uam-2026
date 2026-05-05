{{ config(materialized='table') }}

SELECT
    transaction_id,
    customer_id,
    book_id,
    author_id,
    publisher_id,
    transaction_date,
    quantity,
    unit_price,
    total_item_price
FROM {{ ref('flat_transactions') }}
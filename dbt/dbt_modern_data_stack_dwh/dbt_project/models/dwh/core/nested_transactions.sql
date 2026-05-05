{{
    config(
        materialized='table'
    )
}}

SELECT
    transaction_id,
    customer_id,
    transaction_date,
    cash_register,
    cashier,
    ARRAY_AGG(
        STRUCT(
            book_id,
            book_title,
            book_author,
            author_id,
            book_publisher,
            publisher_id,
            book_category,
            unit_price,
            quantity,
            total_item_price
        )
    ) AS items,
    SUM(total_item_price) AS total_transaction_amount,
    SUM(quantity) AS total_items_count
FROM {{ ref('flat_transactions') }}
GROUP BY 
    transaction_id, 
    customer_id, 
    transaction_date, 
    cash_register, 
    cashier
SELECT
    transaction_id,
    book_id,
    unit_price, 
    COUNT(*) as cnt
FROM {{ ref('fct_transactions') }}
GROUP BY transaction_id, book_id, unit_price
HAVING cnt > 1
WITH transactions AS (
    SELECT * FROM {{ source('gcs_raw', 'ext_transactions') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

books AS (
    SELECT * FROM {{ ref('stg_books') }}
),

flattened_items AS (
    SELECT
        t.transaction_id,
        STRUCT(
            COALESCE(SAFE_CAST(i.book_id AS INT64), -1) as book_id,
            b.title as book_title,
            b.author as book_author,
            b.publisher as book_publisher,
            b.category as book_category,
            i.unit_price,
            i.quantity
        ) as item_enriched
    FROM transactions t
    CROSS JOIN UNNEST(t.items) i
    LEFT JOIN books b ON COALESCE(SAFE_CAST(i.book_id AS INT64), -1) = b.book_id
),

enriched_items_array AS (
    SELECT
        transaction_id,
        ARRAY_AGG(item_enriched) as items
    FROM flattened_items
    GROUP BY 1
)

SELECT
    t.transaction_id,
    t.customer_id,
    t.transaction_date,
    t.cash_register,
    t.cashier,
    c.first_name,
    c.last_name,
    c.email,
    c.registration_date,
    e.items
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN enriched_items_array e ON t.transaction_id = e.transaction_id
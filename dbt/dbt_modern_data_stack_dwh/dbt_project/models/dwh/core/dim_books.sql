{{ config(materialized='table') }}

SELECT
    index as book_id,
    Book_Name as title,
    Author as author_name,
    ABS(FARM_FINGERPRINT(Author)) as author_id,
    Publisher as publisher_name,
    ABS(FARM_FINGERPRINT(Publisher)) as publisher_id,
    genre as category
FROM {{ ref('stg_books') }}
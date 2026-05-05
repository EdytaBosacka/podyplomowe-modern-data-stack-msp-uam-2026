{{ config(materialized='table') }}

SELECT
    book_id,
    title,
    author as author_name,
    ABS(FARM_FINGERPRINT(author)) as author_id,
    publisher as publisher_name,
    ABS(FARM_FINGERPRINT(publisher)) as publisher_id,
    category
FROM {{ ref('stg_books') }}
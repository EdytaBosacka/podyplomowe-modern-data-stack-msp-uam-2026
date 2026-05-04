{{ config(materialized='table') }}

SELECT DISTINCT
    ABS(FARM_FINGERPRINT(Author)) as author_id,
    Author as author_name
FROM {{ ref('stg_books') }}
WHERE Author IS NOT NULL
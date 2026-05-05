{{ config(materialized='table') }}

SELECT DISTINCT
    ABS(FARM_FINGERPRINT(Publisher)) as publisher_id,
    Publisher as publisher_name
FROM {{ ref('stg_books') }}
WHERE Publisher IS NOT NULL
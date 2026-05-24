{{ config(materialized='table') }}

SELECT
    customer_id,
    first_name,        
    last_name,         
    email,             
    registration_date,
    country,
    city,
    age,
    gender
FROM {{ ref('stg_customers') }}
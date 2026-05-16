-- models/dimensions/dim_dates.sql

{{ config(materialized='table') }}

WITH dates AS (
    SELECT date_day
    FROM UNNEST(GENERATE_DATE_ARRAY('2020-01-01', '2030-12-31')) AS date_day
)

SELECT
    date_day AS date_id,
    date_day AS full_date,

    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    EXTRACT(MONTH FROM date_day) AS month,
    FORMAT_DATE('%B', date_day) AS month_name,

    EXTRACT(WEEK FROM date_day) AS week_of_year,
    EXTRACT(DAY FROM date_day) AS day_of_month,
    EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,

    FORMAT_DATE('%A', date_day) AS day_name,

    CASE
        WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend

FROM dates
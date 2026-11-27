WITH 
store_clean AS(
    SELECT
    TRIM(store_name) store_name, 
    INITCAP(TRIM(city)) city,
    opened_date
    FROM  {{ source('raw','raw_stores')  }}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key(['trim(store_name)'])  }} as store_key,
    *
FROM store_clean
SELECT 
    {{ dbt_utils.generate_surrogate_key(['store_name'])  }} as store_key,
    TRIM(store_name) store_name, 
    INITCAP(TRIM(city)) city,
    opened_date
FROM  {{ source('raw','raw_stores')  }}
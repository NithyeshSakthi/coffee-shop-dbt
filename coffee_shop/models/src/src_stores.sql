WITH raw_stores AS (
    SELECT * FROM COFFEE_SHOP.RAW.RAW_STORES
)
SELECT 
    store_name, 
    city,
    opened_date
FROM raw_stores
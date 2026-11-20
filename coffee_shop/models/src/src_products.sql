WITH raw_products AS(
    SELECT * FROM COFFEE_SHOP.RAW.RAW_PRODUCTS)
SELECT 
    product_id,
    product_name,
    category AS product_category,
    unit_price,
    is_active
FROM raw_products
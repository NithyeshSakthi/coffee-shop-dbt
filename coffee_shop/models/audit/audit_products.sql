{# Total Products
Duplicate Product IDs
Missing Product Names
Negative Prices
Invalid Categories #}

WITH
cte1 AS
    (SELECT 
        COUNT(CASE WHEN product_id IS NULL OR product_name IS NULL OR product_name = '' OR category IS NULL OR unit_price IS NULL THEN 1 END) total_invlaid_value,
        COUNT(CASE WHEN unit_price <0 THEN 1 END) AS negative_price_count,
        COUNT(CASE WHEN lower(category) NOT IN ('coffee','tea','pastry') or category IS NULL THEN 1 END) invalid_category_count,
        COUNT( CASE WHEN is_active = False THEN 1 END) AS total_inactive
    FROM {{ source('raw', 'raw_products') }} ),
cte2 AS
    (SELECT product_id, COUNT(*) cnt
    FROM {{ source('raw', 'raw_products') }} 
    GROUP BY product_id 
    HAVING cnt > 1),
cte AS
   ( SELECT COUNT(cnt) total_duplicate FROM cte2)
SELECT 
    cte1.total_invlaid_value,
    cte1.negative_price_count,
    cte1.invalid_category_count,
    cte1.total_inactive,
    cte.total_duplicate
FROM cte1
JOIN cte 
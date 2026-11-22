{# Duplicate Order Items
Negative Quantities
Missing Product IDs
Missing Order IDs #}

WITH 
    cte1 AS(
        SELECT order_item_id, COUNT(*) cnt
        FROM {{ source('raw', 'raw_order_items') }}
        GROUP BY order_item_id
        HAVING cnt > 1),
    cte2 AS(
    SELECT count(CASE WHEN quantity < 0 THEN 1 END) AS total_negative_values,
    COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS total_missing_product_ids,
    COUNT(CASE WHEN order_id IS NULL THEN 1 END )AS total_missing_order_ids
    FROM {{ source('raw','raw_order_items')}}),
    cte AS (SELECT COUNT(cnt) total_duplicate FROM cte1)
SELECT 
    cte2.total_negative_values,
    cte2.total_missing_product_ids,
    cte2.total_missing_order_ids,
    cte.total_duplicate
FROM cte2
CROSS JOIN cte
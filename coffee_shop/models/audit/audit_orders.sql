{# Total Orders
Guest Orders
Duplicate Orders
Invalid Status Values
Future Orders #}
WITH 
    cte1 AS
        (SELECT 
            COUNT(DISTINCT(order_id)) AS distinct_order_count,
            COUNT(CASE WHEN customer_id IS NULL or customer_id = '' THEN 1 END) guset_order,
            COUNT(CASE WHEN status ='' OR status IS NULL THEN 1 END) AS status_invalid_count,
            COUNT(CASE WHEN order_ts > CURRENT_TIMESTAMP THEN 1 END) AS future_order_count    
        FROM {{ source('raw', 'raw_orders') }}),
    cte2 AS
    (SELECT order_id, COUNT(*) cnt
    FROM {{ source('raw', 'raw_orders') }}
    GROUP BY order_id
    HAVING cnt > 1),
    cte AS (SELECT COUNT(*) total_duplicate FROM cte2)
SELECT 
    cte1.distinct_order_count,
    cte1.guset_order,
    cte1.status_invalid_count,
    cte1.future_order_count,
    cte.total_duplicate
FROM cte1
CROSS JOIN cte
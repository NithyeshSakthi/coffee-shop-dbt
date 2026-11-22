{# Missing Store Names
Duplicate Stores
Future Open Dates #}

WITH 
cte2 AS(
    SELECT  
        COUNT(CASE WHEN trim(store_name) ='' OR store_name IS NULL THEN 1 END) AS missing_store_name,
        COUNT(CASE WHEN opened_date > current_timestamp THEN 1 END ) AS feature_date
    FROM {{ source('raw', 'raw_stores') }}
),
cte1 AS
    (SELECT store_name, COUNT(*) cnt 
    FROM {{ source('raw', 'raw_stores') }}
    GROUP BY store_name
    HAVING cnt > 1),
cte AS
    (SELECT COUNT(cnt) duplicate_count FROM cte1) 
SELECT 
    cte2.missing_store_name,
    cte2.feature_date,
    cte.duplicate_count
FROM cte2
CROSS JOIN cte
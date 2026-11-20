--- Total rows
--- Missing emails
--- Duplicate customerid
--- lowercasae cities
--- uppercase emails
--- Null customerIDs
--- Invalida loyalti tiers
--- future signup dates
{# SELECT 
    COUNT(*) AS total_customers,
    COUNT(CASE 
            WHEN email IS NULL or email =''
            THEN 1 
        END) AS missing_values,
    COUNT(CASE WHEN email = UPPER(email) THEN 1 END) AS uppercase_mail,
    COUNT(CASE WHEN city = lower(city) THEN 1 END) AS lowercase_city
FROM {{ source('raw', 'raw_customers') }} #}


WITH 
    cte1 AS (
        SELECT customer_ID, count(*) cnt FROM {{ source('raw','raw_customers') }}
        GROUP BY customer_ID        
        HAVING cnt > 1
    ),
    cte2 AS(
        SELECT 
        count(*) total_count, 
        count(CASE WHEN email = '' THEN 1 END) AS total_empty_mail,
        count(CASE WHEN city = LOWER(city) AND city <> UPPER(city) THEN 1 END)AS total_lower_city,
        COUNT(CASE WHEN loyalty_tier = '' OR loyalty_tier IS NULL THEN 1 END) total_loyality_invalid,
        COUNT(CASE WHEN UPDATED_AT > CURRENT_TIMESTAMP THEN 1 END) future_date
        FROM {{ source('raw','raw_customers') }}
    ),
    cte AS(
        SELECT COUNT(*) duplicate_id, COALESCE(SUM(cnt),0) AS duplicate_row 
        FROM cte1
    )
SELECT 
    a.total_count,
    a.total_empty_mail,
    a.total_lower_city,
    a.total_loyality_invalid,
    a.future_date,
    b.duplicate_id,
    b.duplicate_row
FROM cte2 a
JOIN cte b





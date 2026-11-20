WITH 
cte1 AS (
    SELECT  * FROM {{ source('raw', 'raw_customers')}}),
cte2 AS (
    SELECT 
        customer_id,
        initcap(trim(first_name)) first_name,
        initcap(trim(last_name)) last_name,
        nullif(lower(trim(email)), '' ) email,
        initcap(trim(city)) city,
        signup_date,
        INITCAP(trim(loyalty_tier)) loyalty_tier,
        updated_at
    FROM cte1
)
SELECT * FROM cte2
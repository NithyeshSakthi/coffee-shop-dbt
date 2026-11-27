SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    city,
    signup_date,
    loyalty_tier,
    updated_at
FROM {{ ref('stg_customers') }}
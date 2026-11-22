{# Total Payments
Missing Payment Methods
Negative Amounts
Invalid Payment Types #}

SELECT
    COUNT(DISTINCT payment_id ) total_payment_made,
    COUNT(CASE WHEN lower(PAYMENT_METHOD) NOT IN('card','cash','app') AND PAYMENT_METHOD IS NOT NULL AND trim(payment_method) <> '' THEN 1 END) AS invalid_payment_method,
    COUNT(CASE WHEN amount_cents < 0 THEN 1 END) negative_amount,
    COUNT(CASE WHEN created_at > CURRENT_TIMESTAMP THEN 1 END ) feature_created_time
FROM {{ source('raw','raw_payments') }}







(venv) PS D:\2026job\DBT\coffeeshop_dbt> dbt init --skip-profile-setup coffee_shop
17:22:47  Running with dbt=1.12.7
17:22:47  Your new dbt project "coffee_shop" was created!
Initialized new project in D:\2026job\DBT\coffeeshop_dbt\coffee_shop\coffee_shop

For more information on how to configure the profiles.yml file,
please consult the dbt documentation here:

  https://docs.getdbt.com/docs/configure-your-profile

One more thing:

Need help? Don't hesitate to reach out to us via GitHub issues or on Slack:

  https://community.getdbt.com/

Happy modeling!

(venv) PS D:\2026job\DBT\coffeeshop_dbt> 


---- Add the profile.yml file 
--- 1.Audit 
{# Total Orders
Guest Orders
Duplicate Orders
Invalid Status Values
Future Orders #}

WITH 
    cte1 AS
        (SELECT 
            COUNT(DISTINCT(order_id)) AS distinct_order_count,
            COUNT(CASE WHEN customer_id IS NULL or customer_id = 0 THEN 1 END) guset_order,
            COUNT(CASE WHEN status ='' OR status IS NULL THEN 1 END) AS status_invalid_count,
            COUNT(CASE WHEN order_ts > CURRENT_TIMESTAMP THEN 1 END) AS future_order_count    
        FROM COFFEE_SHOP.RAW.RAW_ORDERS),
    cte2 AS
    (SELECT order_id, COUNT(*) cnt
    FROM COFFEE_SHOP.RAW.RAW_ORDERS
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

-- create the audit order items and validate
{# Duplicate Order Items
Negative Quantities
Missing Product IDs
Missing Order IDs #}

WITH 
    cte1 AS(
        SELECT order_item_id, COUNT(*) cnt
        FROM COFFEE_SHOP.RAW.RAW_ORDER_ITEMS
        GROUP BY order_item_id
        HAVING cnt > 1),
    cte2 AS(
    SELECT count(CASE WHEN quantity < 0 THEN 1 END) AS total_negative_values,
    COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS total_missing_product_ids,
    COUNT(CASE WHEN order_id IS NULL THEN 1 END )AS total_missing_order_ids
    FROM COFFEE_SHOP.RAW.RAW_ORDER_ITEMS),
    cte AS (SELECT COUNT(cnt) total_duplicate FROM cte1)
SELECT 
    cte2.total_negative_values,
    cte2.total_missing_product_ids,
    cte2.total_missing_order_ids,
    cte.total_duplicate
FROM cte2
CROSS JOIN cte

--- create the validation table for payments
{# Total Payments
Missing Payment Methods
Negative Amounts
Invalid Payment Types #}


SELECT
    COUNT(DISTINCT payment_id ) total_payment_made,
    COUNT(CASE WHEN lower(PAYMENT_METHOD) NOT IN('card','cash','app') AND PAYMENT_METHOD IS NOT NULL AND trim(payment_method) <> '' THEN 1 END) AS invalid_payment_method,
    COUNT(CASE WHEN amount_cents < 0 THEN 1 END) negative_amount,
    COUNT(CASE WHEN created_at > CURRENT_TIMESTAMP THEN 1 END ) feature_created_time
FROM COFFEE_SHOP.RAW.RAW_PAYMENTS

--- create validation for products
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
    FROM COFFEE_SHOP.RAW.RAW_PRODUCTS),
cte2 AS
    (SELECT product_id, COUNT(*) cnt
    FROM COFFEE_SHOP.RAW.RAW_PRODUCTS
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

--- validate the raw store table
{# Missing Store Names
Duplicate Stores
Future Open Dates #}

WITH 
cte2 AS(
    SELECT  
        COUNT(CASE WHEN trim(store_name) ='' OR store_name IS NULL THEN 1 END) AS missing_store_name,
        COUNT(CASE WHEN opened_date > current_timestamp THEN 1 END ) AS feature_date
    FROM COFFEE_SHOP.RAW.RAW_STORES
),
cte1 AS
    (SELECT store_name, COUNT(*) cnt FROM COFFEE_SHOP.RAW.RAW_STORES
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


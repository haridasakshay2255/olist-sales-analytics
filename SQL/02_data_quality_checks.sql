-- =====================================================
-- 02_data_quality_checks.sql
-- Checks duplicates, missing values, invalid dates, orphan rows
-- and price ranges. Raw tables are NOT modified; fixes are applied
-- through views in 03_clean_views.sql.
-- =====================================================

USE olist_db;

-- 1) All checks in one result grid
SELECT 'dup_orders' AS check_name, COUNT(*) - COUNT(DISTINCT order_id) AS value FROM orders
UNION ALL SELECT 'dup_customers', COUNT(*) - COUNT(DISTINCT customer_id) FROM customers
UNION ALL SELECT 'dup_products', COUNT(*) - COUNT(DISTINCT product_id) FROM products
UNION ALL SELECT 'dup_review_ids', COUNT(*) - COUNT(DISTINCT review_id) FROM order_reviews
UNION ALL SELECT 'no_approval_date', SUM(order_approved_at IS NULL) FROM orders
UNION ALL SELECT 'no_carrier_date', SUM(order_delivered_carrier_date IS NULL) FROM orders
UNION ALL SELECT 'no_delivery_date', SUM(order_delivered_customer_date IS NULL) FROM orders
UNION ALL SELECT 'delivered_but_no_date', COUNT(*) FROM orders
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
UNION ALL SELECT 'delivered_before_purchase', COUNT(*) FROM orders
  WHERE order_delivered_customer_date < order_purchase_timestamp
UNION ALL SELECT 'products_no_category', COUNT(*) FROM products
  WHERE product_category_name IS NULL
UNION ALL SELECT 'orders_without_items', COUNT(*) FROM orders o
  LEFT JOIN order_items oi ON o.order_id = oi.order_id WHERE oi.order_id IS NULL
UNION ALL SELECT 'zero_value_payments', COUNT(*) FROM order_payments WHERE payment_value = 0
UNION ALL SELECT 'not_defined_payments', COUNT(*) FROM order_payments
  WHERE payment_type = 'not_defined';

-- Results found:
--   duplicates in orders / customers / products ....... 0
--   duplicate review_id values ........................ 814  -> fixed with reviews_clean
--   orders with no approval date ...................... 160  -> left as NULL
--   delivered but no delivery date .................... 8    -> flagged in orders_clean
--   products with no category ......................... 610  -> labelled 'unknown'
--   orders without items .............................. 775  -> drop out of sales_detail
--   zero-value payments / 'not_defined' payments ...... 9 / 3 -> removed in payments_clean

-- 2) Product categories with no English translation (returned 2 rows)
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- 3) Payment types and zero-value rows
SELECT payment_type, COUNT(*) AS payment_rows, SUM(payment_value = 0) AS zero_value
FROM order_payments GROUP BY payment_type;

-- 4) Price range (min 0.85, max 6735.00, no zero or negative prices)
SELECT MIN(price), MAX(price), SUM(price <= 0) AS zero_or_negative
FROM order_items;

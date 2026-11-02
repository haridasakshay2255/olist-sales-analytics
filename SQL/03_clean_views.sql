-- =====================================================
-- 03_clean_views.sql
-- Fixes found in 02_data_quality_checks.sql and builds the views
-- that Power BI connects to.
-- =====================================================

USE olist_db;

-- 1) Add the 2 missing category translations
--    (INSERT IGNORE makes this safe to run more than once)
INSERT IGNORE INTO category_translation VALUES
  ('pc_gamer', 'pc_gamer'),
  ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_preparers');

-- 2) One review per order (keeps the latest review)
CREATE OR REPLACE VIEW reviews_clean AS
SELECT r.order_id, r.review_score, r.review_creation_date
FROM order_reviews r
JOIN (SELECT order_id, MAX(review_pk) AS last_pk
      FROM order_reviews GROUP BY order_id) x
  ON r.review_pk = x.last_pk;

-- 3) Remove invalid payment rows
CREATE OR REPLACE VIEW payments_clean AS
SELECT * FROM order_payments
WHERE payment_type <> 'not_defined' AND payment_value > 0;

-- 4) Orders with a flag for valid deliveries
CREATE OR REPLACE VIEW orders_clean AS
SELECT o.*,
  CASE WHEN o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
       THEN 1 ELSE 0 END AS is_valid_delivery
FROM orders o;

-- 5) Main reporting view (one row per order item)
--    days_vs_estimate: positive = late, negative = early
CREATE OR REPLACE VIEW sales_detail AS
SELECT
  oi.order_id,
  oi.order_item_id,
  o.order_status,
  DATE(o.order_purchase_timestamp)          AS order_date,
  o.order_delivered_customer_date           AS delivered_date,
  o.order_estimated_delivery_date           AS estimated_date,
  c.customer_unique_id,
  c.customer_city,
  c.customer_state,
  COALESCE(t.product_category_name_english,
           p.product_category_name, 'unknown') AS category,
  p.product_id,
  s.seller_id,
  s.seller_city,
  s.seller_state,
  oi.price,
  oi.freight_value,
  oi.price + oi.freight_value               AS total_value,
  DATEDIFF(o.order_delivered_customer_date,
           o.order_purchase_timestamp)      AS delivery_days,
  DATEDIFF(o.order_delivered_customer_date,
           o.order_estimated_delivery_date) AS days_vs_estimate
FROM order_items oi
JOIN orders o     ON oi.order_id = o.order_id
JOIN customers c  ON o.customer_id = c.customer_id
JOIN products p   ON oi.product_id = p.product_id
JOIN sellers s    ON oi.seller_id = s.seller_id
LEFT JOIN category_translation t
       ON p.product_category_name = t.product_category_name;

-- 6) Verify the views (sales_detail should be about 112,650)
SELECT 'sales_detail' AS view_name, COUNT(*) AS row_count FROM sales_detail
UNION ALL SELECT 'reviews_clean', COUNT(*) FROM reviews_clean
UNION ALL SELECT 'payments_clean', COUNT(*) FROM payments_clean
UNION ALL SELECT 'valid_deliveries', SUM(is_valid_delivery) FROM orders_clean;

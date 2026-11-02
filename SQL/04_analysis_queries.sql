-- =====================================================
-- 04_analysis_queries.sql
-- Business questions answered with SQL (delivered orders only).
-- The same questions are answered visually in the Power BI dashboard.
-- =====================================================

USE olist_db;

-- 1) Monthly revenue and orders
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(DISTINCT order_id)         AS orders,
       ROUND(SUM(price), 2)             AS revenue
FROM sales_detail
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- 2) Top 10 categories by revenue
SELECT category,
       ROUND(SUM(price), 2)     AS revenue,
       COUNT(DISTINCT order_id) AS orders
FROM sales_detail
WHERE order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- 3) Revenue and customers by state
SELECT customer_state,
       ROUND(SUM(price), 2)               AS revenue,
       COUNT(DISTINCT customer_unique_id) AS customers
FROM sales_detail
WHERE order_status = 'delivered'
GROUP BY customer_state
ORDER BY revenue DESC;

-- 4) Delivery performance by state
SELECT customer_state,
       ROUND(AVG(delivery_days), 1)              AS avg_delivery_days,
       ROUND(100 * AVG(days_vs_estimate > 0), 1) AS pct_late
FROM sales_detail
WHERE order_status = 'delivered' AND delivered_date IS NOT NULL
GROUP BY customer_state
ORDER BY avg_delivery_days DESC;

-- 5) Top 10 sellers by revenue
SELECT seller_id, seller_state,
       ROUND(SUM(price), 2)     AS revenue,
       COUNT(DISTINCT order_id) AS orders
FROM sales_detail
WHERE order_status = 'delivered'
GROUP BY seller_id, seller_state
ORDER BY revenue DESC
LIMIT 10;

-- 6) Payment methods
SELECT payment_type,
       COUNT(*) AS payments,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM payments_clean
GROUP BY payment_type
ORDER BY payments DESC;

-- 7) Review score: late vs on-time deliveries
SELECT CASE WHEN s.days_vs_estimate > 0 THEN 'Late' ELSE 'On time / early' END AS delivery,
       ROUND(AVG(r.review_score), 2) AS avg_review,
       COUNT(DISTINCT s.order_id)    AS orders
FROM sales_detail s
JOIN reviews_clean r ON s.order_id = r.order_id
WHERE s.order_status = 'delivered' AND s.delivered_date IS NOT NULL
GROUP BY delivery;

-- 8) Repeat customers (customers with more than one delivered order)
SELECT COUNT(*) AS repeat_customers
FROM (
  SELECT customer_unique_id
  FROM sales_detail
  WHERE order_status = 'delivered'
  GROUP BY customer_unique_id
  HAVING COUNT(DISTINCT order_id) > 1
) x;

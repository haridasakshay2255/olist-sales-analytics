-- =====================================================
-- 01_create_tables_and_load.sql
-- Olist Brazilian E-Commerce: create database, tables, load CSVs
-- Dataset: Kaggle "Brazilian E-Commerce Public Dataset by Olist"
-- Edit the folder path below if your CSV files are somewhere else.
-- Data folder used here: C:/Projects/Retail analytics/Data/
-- =====================================================

-- One-time: allow loading local files
-- (also add OPT_LOCAL_INFILE=1 under Connection > Advanced > Others in Workbench)
SET GLOBAL local_infile = 1;

CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;

-- 1) Tables -------------------------------------------
CREATE TABLE customers (
  customer_id              VARCHAR(50) PRIMARY KEY,
  customer_unique_id       VARCHAR(50),
  customer_zip_code_prefix VARCHAR(10),
  customer_city            VARCHAR(100),
  customer_state           VARCHAR(5)
);

CREATE TABLE sellers (
  seller_id              VARCHAR(50) PRIMARY KEY,
  seller_zip_code_prefix VARCHAR(10),
  seller_city            VARCHAR(100),
  seller_state           VARCHAR(5)
);

CREATE TABLE products (
  product_id                 VARCHAR(50) PRIMARY KEY,
  product_category_name      VARCHAR(100),
  product_name_length        INT,
  product_description_length INT,
  product_photos_qty         INT,
  product_weight_g           INT,
  product_length_cm          INT,
  product_height_cm          INT,
  product_width_cm           INT
);

CREATE TABLE category_translation (
  product_category_name         VARCHAR(100) PRIMARY KEY,
  product_category_name_english VARCHAR(100)
);

CREATE TABLE orders (
  order_id                      VARCHAR(50) PRIMARY KEY,
  customer_id                   VARCHAR(50),
  order_status                  VARCHAR(20),
  order_purchase_timestamp      DATETIME,
  order_approved_at             DATETIME,
  order_delivered_carrier_date  DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME,
  INDEX idx_orders_customer (customer_id)
);

CREATE TABLE order_items (
  order_id            VARCHAR(50),
  order_item_id       INT,
  product_id          VARCHAR(50),
  seller_id           VARCHAR(50),
  shipping_limit_date DATETIME,
  price               DECIMAL(10,2),
  freight_value       DECIMAL(10,2),
  PRIMARY KEY (order_id, order_item_id),
  INDEX idx_items_product (product_id),
  INDEX idx_items_seller (seller_id)
);

CREATE TABLE order_payments (
  order_id             VARCHAR(50),
  payment_sequential   INT,
  payment_type         VARCHAR(30),
  payment_installments INT,
  payment_value        DECIMAL(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
  review_pk               INT AUTO_INCREMENT PRIMARY KEY,
  review_id               VARCHAR(50),
  order_id                VARCHAR(50),
  review_score            INT,
  review_comment_title    VARCHAR(255),
  review_comment_message  TEXT,
  review_creation_date    DATETIME,
  review_answer_timestamp DATETIME,
  INDEX idx_reviews_order (order_id)
);

-- 2) Load data ----------------------------------------
LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, @cat, @name_len, @desc_len, @photos, @weight, @len, @height, @width)
SET product_category_name      = NULLIF(@cat, ''),
    product_name_length        = NULLIF(@name_len, ''),
    product_description_length = NULLIF(@desc_len, ''),
    product_photos_qty         = NULLIF(@photos, ''),
    product_weight_g           = NULLIF(@weight, ''),
    product_length_cm          = NULLIF(@len, ''),
    product_height_cm          = NULLIF(@height, ''),
    product_width_cm           = NULLIF(@width, '');

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, @purchase, @approved, @carrier, @delivered, @estimated)
SET order_purchase_timestamp      = NULLIF(@purchase, ''),
    order_approved_at             = NULLIF(@approved, ''),
    order_delivered_carrier_date  = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@delivered, ''),
    order_estimated_delivery_date = NULLIF(@estimated, '');

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Projects/Retail analytics/Data/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id, order_id, review_score, @title, @message, @created, @answered)
SET review_comment_title    = NULLIF(@title, ''),
    review_comment_message  = NULLIF(@message, ''),
    review_creation_date    = NULLIF(@created, ''),
    review_answer_timestamp = NULLIF(@answered, '');

-- 3) Verify row counts --------------------------------
-- Expected: customers 99441 | sellers 3095 | products 32951
-- category_translation 71 | orders 99441 | order_items 112650
-- order_payments 103886 | order_reviews 99223
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;

# Olist E-Commerce Sales Analytics

An end-to-end data analytics project: raw CSV files loaded into **MySQL**, cleaned and modelled with **SQL**, and visualised in a four-page **Power BI** dashboard with **DAX** measures.

## Overview

This project analyses roughly 100,000 orders from Olist, a Brazilian online marketplace. It answers questions about revenue, product categories, regional performance, delivery speed, customer reviews, and payment behaviour.

## Tools

- **MySQL 8 / MySQL Workbench**: database, data cleaning, analysis queries
- **Power BI Desktop**: data model, DAX, dashboard
- **DAX**: measures, calculated columns, date table

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle). It has 8 tables: customers, sellers, products, orders, order items, payments, reviews, and category translations. The raw CSV files are not included in this repository.

## Project workflow

1. **Load**: created the `olist_db` database and loaded 8 CSV files with `LOAD DATA LOCAL INFILE`.
2. **Quality checks**: tested for duplicates, missing values, impossible dates, orphan rows, and price outliers.
3. **Clean**: the raw tables stay untouched. Fixes are applied through SQL views:
   - 814 duplicate review IDs reduced to one review per order
   - 12 invalid payment rows removed (zero-value and `not_defined`)
   - 610 products with no category labelled `unknown`
   - 2 missing category translations added
4. **Model**: connected Power BI to MySQL views and built relationships and a date table.
5. **Visualise**: built a 4-page dashboard with 20+ DAX measures.

## Key findings

- **Revenue:** 13.22M across 96K delivered orders, with an average order value of 137.04.
- **Top category:** health_beauty, followed by watches_gifts and bed_bath_table.
- **Top state:** São Paulo (SP) generates the most revenue by a wide margin.
- **Delivery:** average delivery takes 12.4 days, about 12 days earlier than the estimated date. 6.8% of orders arrive late.
- **Reviews:** the average score is 4.1. Late orders score about **XX** stars against **XX** for on-time orders, so delivery speed is the main driver of customer satisfaction.
- **Retention:** only 3.00% of customers ordered more than once, so repeat purchases are the largest growth opportunity.
- **Payments:** credit card makes up about 78% of payment value. Freight is 16.63% of revenue.
- **Order journey:** nearly every order completes the journey (99K ordered, 96K delivered), and only 0.5% were cancelled.

## Dashboard

### Page 1: Sales Overview
![Sales Overview](screenshots/page1.png)

### Page 2: Delivery and Reviews
![Delivery and Reviews](screenshots/page2.png)

### Page 3: Customers and Payments
![Customers and Payments](screenshots/page3.png)

### Page 4: Deep Dive and Insights
![Deep Dive and Insights](screenshots/page4.png)

A PDF export of all pages is available in [Olist_Dashboard.pdf](Olist_Dashboard.pdf).

## Repository structure

```
├── sql/
│   ├── 01_create_tables_and_load.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_clean_views.sql
│   └── 04_analysis_queries.sql
├── powerbi/
│   └── powerbi_measures.txt
├── screenshots/
└── Olist_Dashboard.pdf
```

## How to run

1. Download the dataset from Kaggle and save the CSV files in a folder.
2. In `sql/01_create_tables_and_load.sql`, change the folder path to match yours.
3. Run the four SQL files in order in MySQL Workbench.
4. In Power BI Desktop, connect to the `olist_db` database and load `sales_detail`, `orders_clean`, `reviews_clean`, and `payments_clean`.
5. Recreate the date table, calculated columns, and measures from `powerbi/powerbi_measures.txt`.

## Notes

- The dashboard covers January 2017 to August 2018. Earlier and later months contain very few orders.
- Revenue figures count delivered orders only and exclude freight.

## Author

**Akshay Haridas**: [LinkedIn](https://www.linkedin.com/in/akshay-haridas-53178b217) | [GitHub](https://github.com/haridasakshay2255)

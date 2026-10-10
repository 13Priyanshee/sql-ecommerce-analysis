# Brazilian E-Commerce Analysis (Olist) — SQL & PostgreSQL

**Goal:** Analysis of ~100K orders from Olist's public Brazilian e-commerce dataset (9 tables) using PostgreSQL, covering revenue trends, product categories, payments, delivery performance, and customer behavior. Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Setup

Create a PostgreSQL database named `olist`, import each CSV as a table with lowercase snake_case names, and retain the CSV headers as column names. Expected tables: `orders`, `order_items`, `order_payments`, `order_reviews`, `customers`, `products`, `sellers`, `geolocation`, `product_category_name_translation`. The script uses order purchase/delivery timestamps, item price and freight, customer state and stable `customer_unique_id`, payment type/installments, review score, and translated product category. Timestamp columns should be parsed as timestamps, not text.

Run `olist_analysis.sql` section by section. Revenue is item `price` (merchandise GMV); freight is reported separately. Cancelled/unavailable orders are excluded from completed-order metrics where appropriate. Check your import and document any choices.

## Business questions covered

Monthly order volume and revenue trend; top categories by GMV; payment mix and installment averages; revenue and freight by state; category review scores; delivery times by state; late delivery rate; monthly running revenue and MoM growth; repeat-customer revenue share; late delivery and review scores.

## Findings

- Late-delivered orders averaged **2.57/5** across **7,674 reviews**, while on-time or early orders averaged **4.29/5** across **88,030 reviews**. In this dataset, late deliveries are associated with substantially lower review scores (a 1.72-point gap); this comparison shows an association, not proof that lateness alone caused the lower scores.
- Delivered merchandise revenue increased from **R$40,325.11 in October 2016** to **R$489,338.25 in May 2017**. May was up **43.64%** from April after a **5.16%** April decline. January's unusually high growth rate is driven by the very small December 2016 revenue baseline (R$10.90), so that percentage is not a representative trend.
- **Health and beauty** generated the highest delivered merchandise revenue: **R$1,233,131.72** across **8,647 orders**. Revenue sums item prices and excludes freight.
- Repeat customers (at least two delivered orders per `customer_unique_id`) contributed **R$728,408.75**, or **5.51%** of delivered merchandise revenue (**R$13,221,498.11** total).

## Publish-ready checklist

- [x] Record findings from the executed queries, including periods and units.
- [ ] Add 2 original business questions.
- [ ] Include screenshots of query results and the database tool.
- [ ] Explain date, cancellation, and repeat-customer definitions in the final write-up.




- **Monday** had the highest delivered merchandise revenue by purchase weekday at **R$2,168,905.61** across **15,701 delivered orders**. Saturday was lowest at **R$1,464,049.60** across **10,555 orders**.
- The top seller by delivered merchandise revenue was based in **São Paulo (SP)**, with **R$226,987.93** in delivered item sales.
## Original questions to make the analysis your own

1. Which purchase weekdays generate the most delivered merchandise revenue? Query 11 in `olist_analysis.sql` groups delivered item prices by purchase weekday.
2. Which sellers generate the most delivered merchandise revenue? Query 12 ranks sellers by delivered item prices and order count.

Run both queries and add your observations to Findings before publishing.



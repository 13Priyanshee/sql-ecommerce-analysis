-- Project 2: Olist analysis (PostgreSQL)
-- Expected table names/columns are described in README.md.
-- Merchandise GMV uses item price; freight is kept separate. Run the sections individually.

-- 1. Orders placed per month and trend (all placed orders).
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders_placed
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- 2. Top 10 product categories by merchandise GMV for delivered orders.
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       SUM(i.price) AS merchandise_gmv,
       COUNT(DISTINCT i.order_id) AS orders
FROM order_items i
JOIN orders o USING (order_id)
JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category_name)
WHERE o.order_status = 'delivered'
GROUP BY 1 ORDER BY merchandise_gmv DESC LIMIT 10;

-- 3. Payment mix and average installments. Payments are payment rows, so use paid amount weighting only if desired.
SELECT payment_type, COUNT(*) AS payment_rows,
       COUNT(DISTINCT order_id) AS orders,
       AVG(payment_installments::numeric) AS avg_installments,
       SUM(payment_value) AS payment_value
FROM order_payments
GROUP BY payment_type ORDER BY payment_value DESC;

-- 4. State merchandise GMV and average freight per order item.
SELECT c.customer_state AS state,
       SUM(i.price) AS merchandise_gmv,
       AVG(i.freight_value) AS avg_freight_per_item,
       COUNT(DISTINCT o.order_id) AS delivered_orders
FROM orders o JOIN customers c USING (customer_id)
JOIN order_items i USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state ORDER BY merchandise_gmv DESC;

-- 5. Average review score by product category.
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       AVG(r.review_score::numeric) AS avg_review_score,
       COUNT(DISTINCT r.review_id) AS review_count
FROM order_reviews r
JOIN order_items i USING (order_id)
JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category_name)
GROUP BY 1 HAVING COUNT(DISTINCT r.review_id) >= 20
ORDER BY avg_review_score ASC;

-- 6. Average order-to-delivery days by customer state.
SELECT c.customer_state AS state,
       AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400.0) AS avg_delivery_days,
       COUNT(*) AS delivered_orders
FROM orders o JOIN customers c USING (customer_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_state ORDER BY avg_delivery_days DESC;

-- 7. Late delivery rate: delivered after estimated date. Excludes orders missing either timestamp.
SELECT COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
       COUNT(*) AS comparable_delivered_orders,
       100.0 * COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date)
         / NULLIF(COUNT(*), 0) AS late_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- 8. Monthly delivered merchandise GMV, running total and month-over-month change.
WITH monthly AS (
  SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month, SUM(i.price) AS revenue
  FROM orders o JOIN order_items i USING (order_id)
  WHERE o.order_status = 'delivered' AND o.order_purchase_timestamp IS NOT NULL
  GROUP BY 1
), trend AS (
  SELECT month, revenue,
         SUM(revenue) OVER (ORDER BY month) AS running_revenue,
         LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
  FROM monthly
)
SELECT month, revenue, running_revenue, previous_month_revenue,
       100.0 * (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0) AS mom_growth_pct
FROM trend ORDER BY month;

-- 9. Revenue from repeat customers. Repeat means customer_unique_id with 2+ delivered orders.
WITH customer_revenue AS (
  SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS delivered_orders,
         SUM(i.price) AS merchandise_gmv
  FROM orders o JOIN customers c USING (customer_id)
  JOIN order_items i USING (order_id)
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT SUM(merchandise_gmv) FILTER (WHERE delivered_orders >= 2) AS repeat_customer_gmv,
       SUM(merchandise_gmv) AS total_gmv,
       100.0 * SUM(merchandise_gmv) FILTER (WHERE delivered_orders >= 2)
         / NULLIF(SUM(merchandise_gmv), 0) AS repeat_customer_gmv_pct
FROM customer_revenue;

-- 10. Compare review scores for late vs. on-time delivered orders.
WITH delivery AS (
  SELECT order_id,
         order_delivered_customer_date > order_estimated_delivery_date AS is_late
  FROM orders
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
)
SELECT CASE WHEN d.is_late THEN 'late' ELSE 'on_time_or_early' END AS delivery_group,
       AVG(r.review_score::numeric) AS avg_review_score,
       COUNT(DISTINCT r.review_id) AS reviews
FROM delivery d JOIN order_reviews r USING (order_id)
GROUP BY d.is_late ORDER BY d.is_late;



-- 11. Original question: which purchase weekdays generate the most delivered merchandise revenue?
-- Weekdays are based on the order purchase date; delivered item prices exclude freight.
SELECT
  EXTRACT(ISODOW FROM o.order_purchase_timestamp)::int AS weekday_number,
  CASE EXTRACT(ISODOW FROM o.order_purchase_timestamp)::int
    WHEN 1 THEN 'Monday' WHEN 2 THEN 'Tuesday' WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday' WHEN 6 THEN 'Saturday'
    WHEN 7 THEN 'Sunday'
  END AS weekday,
  SUM(i.price) AS merchandise_revenue,
  COUNT(DISTINCT o.order_id) AS delivered_orders
FROM orders o
JOIN order_items i USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY 1, 2
ORDER BY merchandise_revenue DESC;

-- 12. Original question: which sellers generate the most delivered merchandise revenue?
SELECT
  s.seller_id,
  s.seller_state,
  SUM(i.price) AS merchandise_revenue,
  COUNT(DISTINCT o.order_id) AS delivered_orders
FROM orders o
JOIN order_items i USING (order_id)
JOIN sellers s USING (seller_id)
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
ORDER BY merchandise_revenue DESC
LIMIT 10;

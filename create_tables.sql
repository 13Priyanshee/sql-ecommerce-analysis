-- Run this once in the olist database before importing CSV data.
-- Text columns preserve source values; date and number columns use PostgreSQL types.

CREATE TABLE customers (
  customer_id text,
  customer_unique_id text,
  customer_zip_code_prefix text,
  customer_city text,
  customer_state text
);

CREATE TABLE orders (
  order_id text,
  customer_id text,
  order_status text,
  order_purchase_timestamp timestamp,
  order_approved_at timestamp,
  order_delivered_carrier_date timestamp,
  order_delivered_customer_date timestamp,
  order_estimated_delivery_date timestamp
);

CREATE TABLE order_items (
  order_id text,
  order_item_id integer,
  product_id text,
  seller_id text,
  shipping_limit_date timestamp,
  price numeric(12,2),
  freight_value numeric(12,2)
);

CREATE TABLE order_payments (
  order_id text,
  payment_sequential integer,
  payment_type text,
  payment_installments integer,
  payment_value numeric(12,2)
);

CREATE TABLE order_reviews (
  review_id text,
  order_id text,
  review_score integer,
  review_comment_title text,
  review_comment_message text,
  review_creation_date timestamp,
  review_answer_timestamp timestamp
);

CREATE TABLE products (
  product_id text,
  product_category_name text,
  product_name_length numeric,
  product_description_length numeric,
  product_photos_qty numeric,
  product_weight_g numeric,
  product_length_cm numeric,
  product_height_cm numeric,
  product_width_cm numeric
);

CREATE TABLE sellers (
  seller_id text,
  seller_zip_code_prefix text,
  seller_city text,
  seller_state text
);

CREATE TABLE geolocation (
  geolocation_zip_code_prefix text,
  geolocation_lat numeric,
  geolocation_lng numeric,
  geolocation_city text,
  geolocation_state text
);

CREATE TABLE product_category_name_translation (
  product_category_name text,
  product_category_name_english text
);

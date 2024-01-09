## This project is aimed to create Data warehouse (Dimintional Modeling) with Facts and Dimensions using snowflake(cloud-based DWH).


### Details
the tech or tools that i used:

- Snowflake to create DB and Data warehouse
- AWS ( S3 Bucket to upload the data)
- Dimensional Modelling (Star Schema)

detailed info about the data: The dataset for this competition is a relational set of files describing customers' orders over time. The goal of the competition is to predict which products will be in a user's next order. The dataset is anonymized and contains a sample of over 3 million grocery orders from more than 200,000 Instacart users. For each user, we provide between 4 and 100 of their orders, with the sequence of products purchased in each order. We also provide the week and hour of day the order was placed, and a relative measure of time between orders. For more information, see the blog post accompanying its public release.

there's 5 entities (customer, product, order, aisle)

this kaggle link for data: https://www.kaggle.com/competitions/instacart-market-basket-analysis/rules

----
this the details of the tables that i used:

**Orders Table:**

| Column Name | Data Type | Description |
| --- | --- | --- |
| order_id | integer | Unique identifier for an order |
| user_id | integer | Unique identifier for a user |
| order_number | integer | A counter for the orders of a user |
| order_dow | integer | The day of the week the order was placed |
| order_hour_of_day | integer | The hour of the day the order was placed |
| days_since_prior_order | integer | Number of days since the previous order |

**Products Table:**

| Column Name | Data Type | Description |
| --- | --- | --- |
| product_id | integer | Unique identifier for a product |
| product_name | varchar | Name of the product |
| aisle_id | integer | Unique identifier for an aisle |
| department_id | integer | Unique identifier for a department |

**Order Products Table:**

| Column Name | Data Type | Description |
| --- | --- | --- |
| order_id | integer | Unique identifier for an order |
| product_id | integer | Unique identifier for a product |
| add_to_cart_order | integer | The order in which the product was added to the cart |
| reordered | boolean | Has the product been ordered by this user in the past? |


**Aisles Table:**
| Column Name | Data Type | Description |
| --- | --- | --- |
| aisle_id | integer | Unique identifier for an aisle |
| aisle | varchar | Name of the aisle |



**Departments Table:**

| Column Name | Data Type | Description |
| --- | --- | --- |
| department_id | integer | Unique identifier for a department |
| department | varchar | Name of the department |


-- i created all the tables for the above dataset in snowflake after that i created the fact & diminsions and upload or copy the data from the S3 Buckec(AWS) into the tables

the query for FACT AND DIMINSIONS:
CREATE OR REPLACE TABLE dim_users AS (
  SELECT
    user_id
  FROM
    orders
);

CREATE OR REPLACE TABLE dim_products AS (
  SELECT
    product_id,
    product_name
  FROM
    products
);


CREATE OR REPLACE TABLE dim_aisles AS (
  SELECT
    aisle_id,
    aisle
  FROM
    aisles
);

CREATE OR REPLACE TABLE dim_departments AS (
  SELECT
    department_id,
    department
  FROM
    departments
);

CREATE OR REPLACE TABLE dim_orders AS (
  SELECT
    order_id,
    order_number,
    order_dow,
    order_hour_of_day,
    days_since_prior_order
  FROM
    orders
);

CREATE TABLE fact_order_products AS (
  SELECT
    op.order_id,
    op.product_id,
    o.user_id,
    p.department_id,
    p.aisle_id,
    op.add_to_cart_order,
    op.reordered
  FROM
    order_products op
  JOIN
    orders o ON op.order_id = o.order_id
  JOIN
    products p ON op.product_id = p.product_id
);


SOME analytics functions that could be query to get some info about the DWH:

-- Query to calculate the total number of products ordered per department:
SELECT
  d.department,
  COUNT(*) AS total_products_ordered
FROM
  fact_order_products fop
JOIN
  dim_departments d ON fop.department_id = d.department_id
GROUP BY
  d.department;

-- Query to find the top 5 aisles with the highest number of reordered products:
SELECT
  a.aisle,
  COUNT(*) AS total_reordered
FROM
  fact_order_products fop
JOIN
  dim_aisles a ON fop.aisle_id = a.aisle_id
WHERE
  fop.reordered = TRUE
GROUP BY
  a.aisle
ORDER BY
  total_reordered DESC
LIMIT 5;

-- Query to calculate the average number of products added to the cart per order by day of the week:
SELECT
  o.order_dow,
  AVG(fop.add_to_cart_order) AS avg_products_per_order
FROM
  fact_order_products fop
JOIN
  dim_orders o ON fop.order_id = o.order_id
GROUP BY
  o.order_dow;

-- Query to identify the top 10 users with the highest number of unique products ordered:
SELECT
  u.user_id,
  COUNT(DISTINCT fop.product_id) AS unique_products_ordered
FROM
  fact_order_products fop
JOIN
  dim_users u ON fop.user_id = u.user_id
GROUP BY
  u.user_id
ORDER BY
  unique_products_ordered DESC
LIMIT 10;


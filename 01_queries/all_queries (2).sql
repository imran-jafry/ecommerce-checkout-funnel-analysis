-- ================================================================
-- Project  : E-Commerce Checkout Funnel & Payment Drop-off Analysis
-- Dataset  : Google Analytics Sample Dataset (BigQuery Public Data)
-- Period   : August 2016 to August 2017
-- Created by: Mohd Imran
-- ================================================================


-- Query 1: Dataset Overview
-- First thing I do on any new dataset — understand the size,
-- the date range, and how many unique users we are working with.

SELECT
  COUNT(*) AS total_sessions,
  COUNT(DISTINCT fullVisitorId) AS unique_users,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801';


-- Query 2: Device Breakdown
-- Understanding traffic split by device before any analysis.
-- Mobile vs desktop behavior is very different in e-commerce.

SELECT
  device.deviceCategory AS device_type,
  COUNT(*) AS total_sessions,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY device_type
ORDER BY total_sessions DESC;


-- Query 3: Overall Conversion Rate and Revenue
-- The headline business numbers. This is what the PM asks first.
-- Note: transactionRevenue in this dataset is stored multiplied
-- by 1,000,000 so we divide to get the actual dollar value.

SELECT
  COUNT(*) AS total_sessions,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  ROUND(SUM(IFNULL(totals.transactions, 0)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
  ROUND(SUM(totals.transactionRevenue) / 1000000, 2) AS total_revenue_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801';


-- Query 4: Traffic Source Conversion
-- Different channels bring very different quality of users.
-- IFNULL handles sessions with no transactions — treats them as 0.

SELECT
  trafficSource.medium AS traffic_medium,
  COUNT(*) AS total_sessions,
  SUM(IFNULL(totals.transactions, 0)) AS transactions,
  ROUND(SUM(IFNULL(totals.transactions, 0)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY traffic_medium
ORDER BY total_sessions DESC;


-- Query 5: Conversion Rate and Revenue by Device
-- This query adds AOV per device — which revealed that mobile
-- users who do buy spend half of what desktop users spend.
-- NULLIF prevents division by zero when transactions = 0.

SELECT
  device.deviceCategory AS device_type,
  COUNT(*) AS total_sessions,
  COUNT(DISTINCT fullVisitorId) AS unique_users,
  SUM(IFNULL(totals.transactions, 0)) AS transactions,
  ROUND(SUM(IFNULL(totals.transactions, 0)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
  ROUND(SUM(totals.transactionRevenue) / 1000000, 2) AS revenue_usd,
  ROUND(SUM(totals.transactionRevenue) / 1000000 / NULLIF(SUM(IFNULL(totals.transactions, 0)), 0), 2) AS aov_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY device_type
ORDER BY revenue_usd DESC;


-- Query 6: Checkout Funnel — Core Analysis Query
-- This is the most important query in the project.
-- UNNEST flattens the hits ARRAY so each user action
-- becomes its own row that we can filter and count.
--
-- eCommerceAction.action_type values used:
--   '2' = Product Detail View
--   '3' = Add to Cart
--   '5' = Checkout Started
--
-- Important: action_type '7' (Purchase) returned 0 users
-- due to a data quality issue in the GA sample dataset.
-- I investigated this and switched to totals.transactions >= 1
-- which is the reliable purchase signal in this dataset.
-- Step 4 does not need UNNEST because totals is a STRUCT
-- sitting directly on the session row, not inside an ARRAY.
--
-- FIRST_VALUE gives each step its percentage of the funnel top.
-- LEAD looks at the next row to calculate step-level drop-off.


-- Query 6: Sequential Checkout Funnel
-- Counts sessions progressing through the actions in order.
-- One session is identified by fullVisitorId + visitId.

WITH session_actions AS (
  SELECT
    CONCAT(fullVisitorId, '-', CAST(visitId AS STRING)) AS session_id,
    MIN(IF(hit.eCommerceAction.action_type = '2', hit.hitNumber, NULL)) AS product_view,
    MIN(IF(hit.eCommerceAction.action_type = '3', hit.hitNumber, NULL)) AS add_to_cart,
    MIN(IF(hit.eCommerceAction.action_type = '5', hit.hitNumber, NULL)) AS checkout,
    MIN(IF(hit.eCommerceAction.action_type = '6', hit.hitNumber, NULL)) AS purchase
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hit
  WHERE
    _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
  GROUP BY session_id
)

SELECT
  COUNTIF(product_view IS NOT NULL) AS product_view_sessions,
  COUNTIF(product_view IS NOT NULL AND add_to_cart > product_view)
    AS add_to_cart_after_view,
  COUNTIF(product_view IS NOT NULL
          AND add_to_cart > product_view
          AND checkout > add_to_cart)
    AS checkout_after_cart,
  COUNTIF(product_view IS NOT NULL
          AND add_to_cart > product_view
          AND checkout > add_to_cart
          AND purchase > checkout)
    AS purchase_after_checkout
FROM session_actions;


-- Query 7: Geography Conversion Analysis
-- Finding which countries convert and which ones fail completely.
-- HAVING COUNT(*) > 200 removes countries with too few sessions
-- to give statistically meaningful conversion rates.
-- This is called significance filtering.

SELECT
  geoNetwork.country AS country,
  COUNT(*) AS total_sessions,
  SUM(IFNULL(totals.transactions, 0)) AS transactions,
  ROUND(SUM(IFNULL(totals.transactions, 0)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
  ROUND(SUM(totals.transactionRevenue) / 1000000, 2) AS revenue_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY country
HAVING COUNT(*) > 200
ORDER BY revenue_usd DESC;


-- Query 8: Cross-Dimensional Segmentation — Device x Traffic Source
-- Testing whether traffic source quality can overcome device friction.
-- Finding: desktop + direct = 3.33% conversion (best combination)
-- Finding: mobile + referral = 0.04% conversion (worst combination)
-- This proves that traffic quality sometimes matters more than device.

SELECT
  device.deviceCategory AS device_type,
  trafficSource.medium AS traffic_medium,
  COUNT(*) AS total_sessions,
  SUM(IFNULL(totals.transactions, 0)) AS transactions,
  ROUND(SUM(IFNULL(totals.transactions, 0)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
  ROUND(SUM(totals.transactionRevenue) / 1000000, 2) AS revenue_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY device_type, traffic_medium
HAVING COUNT(*) > 200
ORDER BY conversion_rate_pct DESC
LIMIT 10;


-- Query 9: Headline KPI Summary
-- Clean single-row table used for Power BI KPI card visuals.
-- All values calculated from the queries above.

-- Query 9: Dynamic Headline KPI Summary

SELECT
  COUNT(*) AS total_sessions,
  COUNT(DISTINCT fullVisitorId) AS unique_visitors,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  ROUND(
    SAFE_DIVIDE(
      SUM(IFNULL(totals.transactions, 0)),
      COUNT(*)
    ) * 100, 2
  ) AS conversion_rate_pct,
  ROUND(
    SUM(IFNULL(totals.transactionRevenue, 0)) / 1000000, 2
  ) AS total_revenue_usd,
  ROUND(
    SAFE_DIVIDE(
      SUM(IFNULL(totals.transactionRevenue, 0)) / 1000000,
      SUM(IFNULL(totals.transactions, 0))
    ), 2
  ) AS average_order_value_usd
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20160801' AND '20170801';



-- End of file — 9 queries total
-- Created by Mohd Imran

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

SELECT
  funnel_step,
  users,
  ROUND(users * 100.0 / FIRST_VALUE(users) OVER (ORDER BY step_order), 2) AS pct_of_top,
  ROUND((users - LEAD(users) OVER (ORDER BY step_order)) * 100.0 / users, 2) AS dropoff_rate
FROM (

  SELECT 1 AS step_order, 'Step 1 - Product View' AS funnel_step,
    COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '2'

  UNION ALL

  SELECT 2 AS step_order, 'Step 2 - Add to Cart' AS funnel_step,
    COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '3'

  UNION ALL

  SELECT 3 AS step_order, 'Step 3 - Checkout Started' AS funnel_step,
    COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '5'

  UNION ALL

  SELECT 4 AS step_order, 'Step 4 - Purchase Complete' AS funnel_step,
    COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND totals.transactions >= 1

)
ORDER BY step_order;


-- Query 7: Revenue Impact by Funnel Step
-- Quantifying the business cost of each drop-off using AOV of $127.12.
-- These are theoretical maximum figures — not guaranteed recovery.
-- In the final presentation I noted that even 10-20% recovery
-- would represent $100K-$200K in additional annual revenue.

SELECT
  'Step 1 to 2 - Did Not Add to Cart' AS lost_at_step,
  (99256 - 39817) AS users_lost,
  ROUND((99256 - 39817) * 127.12, 2) AS potential_revenue_lost_usd
UNION ALL
SELECT
  'Step 2 to 3 - Cart Abandoned' AS lost_at_step,
  (39817 - 18280) AS users_lost,
  ROUND((39817 - 18280) * 127.12, 2) AS potential_revenue_lost_usd
UNION ALL
SELECT
  'Step 3 to 4 - Checkout Abandoned' AS lost_at_step,
  (18280 - 10022) AS users_lost,
  ROUND((18280 - 10022) * 127.12, 2) AS potential_revenue_lost_usd
ORDER BY potential_revenue_lost_usd DESC;


-- Query 8: Device-Level Funnel Segmentation
-- Breaking the funnel down by device to find where
-- mobile users specifically drop off vs desktop.
-- PARTITION BY device_category gives each device
-- its own 100% baseline for fair comparison.
-- Key finding: mobile shows a flat ~67% drop-off
-- at every single step — unlike desktop where
-- drop-off improves as users go deeper.

SELECT
  device_category, funnel_step, step_order, users,
  ROUND(users * 100.0 / FIRST_VALUE(users) OVER (PARTITION BY device_category ORDER BY step_order), 2) AS pct_of_device_top,
  ROUND((users - LEAD(users) OVER (PARTITION BY device_category ORDER BY step_order)) * 100.0 / users, 2) AS dropoff_rate
FROM (

  SELECT device.deviceCategory AS device_category, 1 AS step_order,
    'Step 1 - Product View' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '2'
  GROUP BY device_category

  UNION ALL

  SELECT device.deviceCategory AS device_category, 2 AS step_order,
    'Step 2 - Add to Cart' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '3'
  GROUP BY device_category

  UNION ALL

  SELECT device.deviceCategory AS device_category, 3 AS step_order,
    'Step 3 - Checkout Started' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '5'
  GROUP BY device_category

  UNION ALL

  SELECT device.deviceCategory AS device_category, 4 AS step_order,
    'Step 4 - Purchase Complete' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND totals.transactions >= 1
  GROUP BY device_category

)
ORDER BY device_category, step_order;


-- Query 9: Traffic Source Funnel Segmentation
-- Comparing how each traffic channel performs across the funnel.
-- Key finding: affiliate traffic drops 93.28% at the final step
-- suggesting fundamental expectation mismatch, not checkout friction.

SELECT
  traffic_medium, funnel_step, step_order, users,
  ROUND(users * 100.0 / FIRST_VALUE(users) OVER (PARTITION BY traffic_medium ORDER BY step_order), 2) AS pct_of_medium_top,
  ROUND((users - LEAD(users) OVER (PARTITION BY traffic_medium ORDER BY step_order)) * 100.0 / users, 2) AS dropoff_rate
FROM (

  SELECT trafficSource.medium AS traffic_medium, 1 AS step_order,
    'Step 1 - Product View' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '2'
  GROUP BY traffic_medium

  UNION ALL

  SELECT trafficSource.medium AS traffic_medium, 2 AS step_order,
    'Step 2 - Add to Cart' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '3'
  GROUP BY traffic_medium

  UNION ALL

  SELECT trafficSource.medium AS traffic_medium, 3 AS step_order,
    'Step 3 - Checkout Started' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hit
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND hit.eCommerceAction.action_type = '5'
  GROUP BY traffic_medium

  UNION ALL

  SELECT trafficSource.medium AS traffic_medium, 4 AS step_order,
    'Step 4 - Purchase Complete' AS funnel_step, COUNT(DISTINCT fullVisitorId) AS users
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND totals.transactions >= 1
  GROUP BY traffic_medium

)
ORDER BY traffic_medium, step_order;


-- Query 10: Geography Conversion Analysis
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


-- Query 11: Cross-Dimensional Segmentation — Device x Traffic Source
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


-- Query 12: Headline KPI Summary
-- Clean single-row table used for Power BI KPI card visuals.
-- All values calculated from the queries above.

SELECT
  903653     AS total_sessions,
  12115      AS total_transactions,
  1.34       AS conversion_rate_pct,
  1540071.24 AS total_revenue_usd,
  127.12     AS avg_order_value,
  8258       AS checkout_abandonment_users,
  1049756.96 AS checkout_revenue_opportunity;


-- Query 13: Revenue Opportunity Summary
-- Prioritized list of the three biggest revenue recovery opportunities.
-- Used as the source for the opportunity bar chart in the dashboard.

SELECT 'Checkout Abandonment' AS opportunity, 1 AS priority,
  8258 AS users_affected, 1049756.96 AS revenue_opportunity_usd,
  'Simplify checkout form, reduce fields, add autofill' AS recommendation
UNION ALL
SELECT 'Affiliate Traffic Quality', 2, 16527, 283109.35,
  'Audit affiliate partners, restructure commission model'
UNION ALL
SELECT 'Mobile Conversion Gap', 3, 166173, 156484.00,
  'Mobile UX overhaul, add Google Pay and UPI'
ORDER BY priority;


-- End of file — 13 queries total
-- Created by Mohd Imran

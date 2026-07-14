# E-Commerce Checkout Funnel & Payment Drop-off Analysis

> Analyzed 903,653 sessions from the Google Merchandise Store using BigQuery SQL to identify $1.49M in recoverable revenue from checkout funnel drop-offs. Built an interactive Power BI dashboard to communicate findings to business stakeholders.

---

## Project Overview

This project analyzes the checkout funnel of the Google Merchandise Store to identify exactly where users drop off during the purchase journey and quantify the revenue impact of each drop-off point.

**Business Problem:** The store was experiencing lower than expected purchase completions despite healthy traffic volumes. The Product Manager needed to understand where users were abandoning the checkout process and why.

**My Role:** Data and Product Analyst — responsible for defining business questions, writing SQL queries in BigQuery, performing segmentation analysis, quantifying revenue impact, and delivering actionable recommendations.

---

## Tools and Technologies

| Tool                            | Purpose                                             |
|---------------------------------|-----------------------------------------------------|
| Google BigQuery                 | Cloud data warehouse — all SQL analysis             |
| Google Analytics Sample Dataset | Real e-commerce clickstream data                    |
| Power BI                        | Interactive dashboard creation                      |
| SQL                             | Funnel construction, segmentation, window functions |
| Advanced Excel | Funnel pivot analysis, device comparison, 
executive summary dashboard, conditional formatting |
---

## Dataset

- **Source:** Google Analytics Sample Dataset (BigQuery Public Data)
- **Table:** `bigquery-public-data.google_analytics_sample.ga_sessions_*`
- **Period:** August 2016 to August 2017
- **Size:** 903,653 sessions across 714,167 unique users
- **Key Challenge:** Data is stored in nested ARRAY and STRUCT fields — required UNNEST operations in BigQuery to extract individual checkout events from within session rows

---

## Business Questions Answered

1. What does our checkout funnel look like end to end?
2. At which step do we lose the most users?
3. What is our overall funnel conversion rate?
4. Which device type has the worst drop-off?
5. Which traffic source brings the lowest quality users?
6. Which geographies are failing to convert?
7. What is the total revenue opportunity from fixing these drop-offs?

---

## Key Findings

### 1. Checkout Funnel Performance

| Step              | Users | Drop-off Rate |
|-------------------|-------|---------------|
| Product View      | 99,256 |   --         |
| Add to Cart       | 39,817 | 59.88%       |
| Checkout Started  | 18,280 | 54.09%       |
| Purchase Complete | 10,022 | 45.18%       |

Only 10.1% of users who viewed a product completed a purchase. The most critical drop-off is Step 3 to Step 4 — where 8,258 high-intent users who had already started checkout never completed their purchase.

---

### 2. Device Analysis

| Device | Sessions | Conversion Rate | Revenue    | AOV    |
|--------|----------|-----------------|------------|--------|
| Desktop| 523,690  | 2.11%           | $1,480,864 | $133.76|
| Mobile | 166,173  | 0.52%           | $49,785    | $57.49 |
| Tablet | 24,304   | 0.73%           | $9,421     | $52.93 |

Mobile represents 28% of all traffic but generates only 3.2% of total revenue — a 9x imbalance. Mobile also shows a flat 67% drop-off at every funnel step regardless of depth, suggesting a systemic platform-level UX problem rather than a specific checkout step failure.

---

### 3. Traffic Source Analysis

| Medium | Completion Rate | Transactions |
|--------|--- -------------|--------------|
| Direct | 13.53%          | 7,584        |
| CPM    | 10.67%          | 120          |
| CPC    | 9.57%           | 236          |
| Organic| 5.82%           | 1,951        |
|Referral| 3.47%           | 263          |
|Affiliate| 0.53%          | 9            |

Affiliate traffic generated only 9 transactions from 1,695 product viewers. A 93.28% abandonment rate at the final checkout step suggests fundamental expectation mismatch — not checkout friction.

---

### 4. Geography

- United States generates 94% of all revenue despite representing only 40% of total traffic
- Five countries with over 500 sessions each recorded zero transactions (Croatia, Bulgaria, Latvia, Belarus, Costa Rica)
- International users face compounding barriers — currency conversion, limited payment methods, and international shipping costs

---

## Revenue Opportunity Sizing

| Priority | Opportunity               | Users Affected | Revenue Opportunity |
|----------|---------------------------|----------------|---------------------|
| 1        | Checkout Abandonment      | 8,258          | $1,049,756          |
| 2        | Affiliate Traffic Quality | 16,527         | $283,109            |
| 3        | Mobile Conversion Gap     | 166,173        | $156,484            |
|          | **Total**                 |                | **$1,489,349**      |

Note: These figures represent the theoretical maximum recovery assuming 100% conversion improvement. Even recovering 10 to 20% of checkout abandonment would represent $100,000 to $200,000 in additional annual revenue.

---

## Recommendations

**Priority 1 — Fix Checkout Abandonment ($1.05M opportunity)**

Audit checkout form for friction points. Simplify required fields, implement address autofill, and surface all costs including shipping before the final step to eliminate price shock abandonment. A/B test a simplified one-page checkout flow.

**Priority 2 — Affiliate Partner Audit ($283K opportunity)**

Restructure affiliate commission model to reward completed purchases rather than clicks — this aligns partner incentives with actual business outcomes. Audit all affiliate partnerships for misleading promotional content that creates expectation mismatch.

**Priority 3 — Mobile UX Overhaul ($156K opportunity)**

Implement mobile-optimized checkout with Google Pay and local digital wallet integrations. Conduct a full mobile UX audit focusing on form field sizing, button tap targets, and checkout step count reduction.

---
---

## Excel Analysis

A three-sheet Excel workbook was built to demonstrate 
data analysis and presentation skills.

**File:** `excel/funnel_analysis.xlsx`

### Sheet 1 — Funnel Analysis
- Imported funnel data from BigQuery results
- Applied conditional formatting — red for high drop-off
- Built clustered bar chart showing user drop-off by step
- Key finding: 45.18% drop-off at checkout initiation

### Sheet 2 — Device Performance
- Comparison table of desktop vs mobile vs tablet
- Conditional formatting heatmap on conversion rates
- Column chart showing 4x mobile conversion gap
- Key insight: Mobile drives 23% of traffic but only 
  3.2% of revenue — a 7x revenue imbalance

### Sheet 3 — Executive Summary
- One-page business summary for non-technical stakeholders
- 5 KPI cards: Sessions, Transactions, Conversion Rate, 
  Revenue, AOV
- Key findings with color-coded priority recommendations
- Priority 1: $1,049,756 checkout abandonment opportunity
- Priority 2: $283,109 affiliate traffic quality fix
- Priority 3: $156,484 mobile UX overhaul
 ---

## Data Challenges and Solutions

| Challenge              | What Happened                           | How I Solved It                                     |
|------------------------|-----------------------------------------|-----------------------------------------------------|
| Nested ARRAY hits field| Could not query checkout events directly| Used UNNEST(hits) to flatten the array into         |                                                                          |                                         |  individual rows                                    |
|action_type 7 unreliable| Purchase Complete step returned 0 users | Investigated and switched to totals.transactions>= 1|                                                                          |                                         |which is the reliable purchase signal                |
| NULL transaction values| SUM was returning incorrect totals      |Applied IFNULL(transactions, 0) to treat null as zero|
| Small sample countries | Tiny countries showing misleading 100% conversion | Filtered with HAVING COUNT(*) > 200 for   |                                                                                                                               statistical significance                   |

This section reflects real analytical work on a real dataset. Production data is never clean — these were genuine problems that required investigation and solutions.

---

## SQL Concepts Used

- UNNEST for flattening nested ARRAY fields
- Window functions — FIRST_VALUE, LEAD, OVER, PARTITION BY
- UNION ALL for combining funnel steps
- IFNULL and NULLIF for null handling
- Wildcard table syntax with _TABLE_SUFFIX for querying partitioned tables
- COUNT DISTINCT for accurate unique user counts
- Subqueries for multi-step calculations

---
## Excel Skills Demonstrated
- Data import from CSV using Power Query
- Conditional formatting with color scales and data bars
- Pivot table analysis
- Chart creation with custom formatting
- Executive summary design for stakeholder presentation
---

## Dashboard Preview

![Dashboard](03_screenshots/dashboard.png)

---

## Project Structure

```
ecommerce-checkout-funnel-analysis/
│
|
│
├── 01_queries/
│   └── all_queries.sql
│
├── 02_results/
│   ├── 01_funnel_overview.csv
│   ├── 02_device_performance.csv
│   ├── 03_traffic_source.csv
│   ├── 04_device_funnel.csv
│   ├── 05_geography.csv
│   ├── 06_opportunity_summary.csv
│   └── 07_headline_kpis.csv
│
│
└── 03_screenshots/
    ├── dashboard_overview.png
    ├── bigquery_funnel_query.png
    └── funnel_closeup.png
|
|__ 04_dashboard/
|    |__ecommerce_funnel_dashboard.pbix
|
|___README.md
├── excel/
│   └── funnel_analysis.xlsx

'''
...

## Author
*Mohd Imran**
Data and Product Analyst

Connect with me on LinkedIn: [www.linkedin.com/in/mohd-imran-55348a325]

# E-Commerce Checkout Funnel & Product Performance Analysis

## Project Overview

An e-commerce analytics project using Google Analytics data to understand customer shopping behaviour, checkout progression, device performance, traffic sources and revenue contribution.

The objective was to identify where customers drop off during the shopping journey and highlight areas where the business could investigate improvements in conversion performance.

## Business Questions

- Where do customers drop off in the shopping journey?
- Which devices generate the highest conversion and revenue?
- Which traffic sources bring more valuable sessions?
- Which geographical markets contribute the most revenue?
- What areas should the business prioritize for further investigation?

## Dataset

- **Source:** Google Analytics Sample Dataset – Google Merchandise Store
- **Platform:** Google BigQuery Public Dataset
- **Date range:** August 2016 – August 2017
- **Data type:** Universal Analytics session-level data

## Tools & Technologies

- **BigQuery SQL:** Data extraction, transformation and analysis
- **Microsoft Excel:** Data review and analysis
- **Power BI:** Interactive dashboard and business reporting

## Analysis Performed

1. Overall e-commerce performance and conversion metrics.
2. Ordered shopping funnel analysis.
3. Device-level session, conversion and revenue analysis.
4. Traffic source performance comparison.
5. Geographic revenue and transaction analysis.

## Key Findings

### 1. Overall Performance

| Metric | Result |
|---|---:|
| Total Sessions | 903,653 |
| Unique Visitors | 714,167 |
| Transactions | 12,115 |
| Session Conversion Rate | 1.34% |
| Total Revenue | $1,540,071.24 |
| Average Order Value | $127.12 |

### 2. Checkout Funnel

The ordered session funnel measures sessions progressing through the following stages:

| Stage | Sessions |
|---|---:|
| Product View | 124,053 |
| Add to Cart | 42,502 |
| Checkout | 16,215 |
| Purchase | 8,500 |

- 34.26% of product-view sessions progressed to add to cart.
- 38.15% of add-to-cart sessions progressed to checkout.
- 52.42% of checkout sessions progressed to purchase.

The largest proportional drop-off occurred between product view and add to cart.

### 3. Device Performance

| Device | Sessions | Conversion Rate | Revenue |
|---|---:|---:|---:|
| Desktop | 664,479 | 1.67% | $1,480,864 |
| Mobile | 208,725 | 0.41% | $49,786 |
| Tablet | 30,449 | 0.58% | $9,421 |

Mobile contributed approximately 23.1% of sessions but only 3.23% of revenue, indicating a significant device-level performance gap worth investigating.

### 4. Traffic Source Performance

| Traffic Medium | Sessions | Transactions | Conversion Rate |
|---|---:|---:|---:|
| Direct | 371,467 | 9,160 | 2.47% |
| Referral | 262,022 | 326 | 0.12% |
| Organic | 234,381 | 2,221 | 0.95% |
| CPC | 13,079 | 248 | 1.90% |
| CPM | 6,184 | 150 | 2.43% |
| Affiliate | 16,403 | 9 | 0.05% |

Direct traffic generated the highest transaction volume, while referral and affiliate traffic showed comparatively low conversion rates.

### 5. Geographic Performance

The United States generated approximately 94.3% of total revenue, with 364,744 sessions and 11,440 transactions.

This highlights the importance of the US market in the store's overall revenue performance.

## Business Recommendations

Based on the observed patterns:

1. Investigate product-page engagement and the transition from product views to cart additions.
2. Examine the mobile shopping and checkout experience.
3. Investigate referral and affiliate traffic sources with low observed conversion rates.
4. Understand the factors contributing to the strong revenue performance of the US market.

These are areas for further investigation, not proven causes of customer behaviour.

## Dashboard

The Power BI dashboard presents:

- Overall business KPIs
- Ordered checkout funnel
- Device session and revenue comparison
- Device conversion rates
- Traffic source performance
- Geographic performance

## Project Files

- `all_queries.sql` – SQL queries used for analysis
- `funnel_analysis.xlsx` – Excel analysis and summaries
- `E-commerce checkout funnel dashboard.pbix` – Power BI dashboard
- `dashboard.png` – Dashboard screenshot

## Limitations

- The analysis uses historical Universal Analytics sample data from 2016–2017.
- The ordered funnel counts sessions progressing through the selected actions in sequence.
- The 8,500 ordered purchase sessions and 12,115 total transactions represent different metrics.
- Observed differences do not establish causation.
- Revenue opportunity estimates and payment-failure analysis are not included.

---

**Project Focus:** E-commerce Analytics | Funnel Analysis | Customer Behaviour | Business Intelligence

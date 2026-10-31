# E-Commerce Checkout Funnel & Payment Drop-off Analysis

> Analyzed 903,653 sessions from the Google Analytics Sample Dataset using BigQuery SQL to examine e-commerce purchasing behaviour, device performance, and checkout activity. Built a Power BI dashboard to communicate analytical findings.

## Project Overview

This portfolio project explores user behaviour across the Google Merchandise Store, focusing on product interactions, shopping activity, transactions, and differences in device performance.

**Business Problem:** How do purchasing patterns differ across devices and traffic sources, and where do users disengage during the shopping journey?

**My Role:** Portfolio project — performed SQL-based data extraction and analysis, examined device and traffic-source performance, and developed a Power BI dashboard.

## Dataset

- **Source:** Google Analytics Sample Dataset
- **Platform:** Google Merchandise Store
- **Dataset period:** August 2016 – August 2017
- **Total sessions:** 903,653
- **Total transactions:** 12,115
- **Total revenue:** $1,540,071.24

## Tools & Technologies

- **SQL:** Google BigQuery
- **Data Visualization:** Microsoft Power BI
- **Data Analysis:** Excel
- **Data Source:** Google Analytics public sample data

## Analysis Performed

- Explored e-commerce traffic and purchasing behaviour.
- Examined product views, cart interactions, checkout activity, and completed purchases.
- Compared device-level sessions, transactions, and revenue.
- Analyzed traffic-source performance.
- Reviewed differences in average order value across devices.
- Developed dashboard views to communicate key findings.

## Key Findings

- The dataset contained 903,653 sessions and 12,115 transactions.
- Total recorded revenue was approximately $1.54 million.
- Desktop generated a higher average order value than mobile.
- Mobile accounted for approximately 23.1% of sessions but contributed a smaller share of recorded revenue.
- Purchasing behaviour varied across devices and traffic sources.

*These findings are descriptive observations from the historical dataset, not proof of the causes behind user behaviour.*

## Dashboard

The Power BI dashboard presents the analysis through visualizations covering:

- Overall e-commerce performance
- Device-level performance
- Traffic-source analysis
- Shopping and checkout activity

See the `03_dashboard` folder for the dashboard files.

## Project Structure

```text
ecommerce-checkout-funnel-analysis/
│
├── 01_queries/
├── 02_results/
├── 03_dashboard/
├── 04_excel_analysis/
├── 05_notebooks/
├── 06_documentation/
│
├── README.md
├── LICENSE
└── .gitignore
```

## Limitations

- The dataset is historical and does not represent current e-commerce behaviour.
- The analysis is observational and cannot establish why users abandoned purchases.
- Action counts across the full dataset should not automatically be interpreted as a sequential, same-session conversion funnel.
- Revenue opportunity estimates and potential recovery figures are not included because they require additional validation and assumptions.

## Skills Demonstrated

SQL querying, data extraction, exploratory data analysis, e-commerce analytics, device segmentation, business analysis, dashboard development, and data storytelling.

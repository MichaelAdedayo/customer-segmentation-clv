# Building the Power BI Dashboard

## 1. Load the Data

Power BI Desktop → **Get Data** → **Text/CSV** → load the customer-level output from
`02_rfm_feature_engineering.ipynb` and `03_clustering.ipynb` (e.g. `data/customer_segments.csv`,
containing one row per customer with `customer_id`, `recency`, `frequency`, `monetary`,
`cluster`, `segment_name`, and `clv` columns).

## 2. Recommended Pages

**Page 1 — Overview**
- KPI cards: Total Customers, Total Revenue, Number of Segments, Avg CLV
- Donut chart: Customers by Segment

**Page 2 — Segment Profiles**
- Clustered bar chart: Avg Recency, Avg Frequency, Avg Monetary — one group of bars per segment
  (this is the core "who are these segments" visual)
- Table: Segment name, customer count, % of customer base, % of revenue

**Page 3 — Revenue Concentration & Churn Risk**
- Bar chart: Revenue share by segment (highlights if revenue is concentrated in one segment)
- Bar/KPI: At-risk customers (recency > 90 days) — count and their combined lifetime spend

**Page 4 — Customer Lifetime Value**
- Bar chart: Average CLV by segment
- Scatter chart: Frequency (x-axis) vs. Monetary (y-axis), colored by segment — visually shows
  cluster separation

## 3. Recommended DAX Measures

```dax
Total Customers = DISTINCTCOUNT(customer_segments[customer_id])

Total Revenue = SUM(customer_segments[monetary])

Avg CLV = AVERAGE(customer_segments[clv])

At-Risk Customers = 
CALCULATE(COUNTROWS(customer_segments), customer_segments[recency] > 90)

At-Risk Revenue % = 
DIVIDE(
    CALCULATE(SUM(customer_segments[monetary]), customer_segments[recency] > 90),
    [Total Revenue]
)
```

## 4. Add a Business-Insight Text Box

On the Overview page, summarize the top finding — e.g. "X% of revenue comes from the top
segment ([segment name]), while Y% of customers show churn risk (90+ days since last
purchase), representing ₦Z in at-risk revenue."

## 5. Save and Screenshot

Save as `Segmentation_Dashboard.pbix` in this folder, and export screenshots of each page to
`../visuals/` since GitHub can't render `.pbix` files directly.

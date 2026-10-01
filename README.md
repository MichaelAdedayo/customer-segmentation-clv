# Customer Segmentation & Lifetime Value Analysis

An unsupervised learning project that segments customers using RFM (Recency, Frequency,
Monetary) analysis and K-Means clustering, then estimates Customer Lifetime Value (CLV) per
segment — turning a transaction log into a set of actionable customer groups a retention or
marketing team could act on directly.

## Business Framing

> **Which customers are most valuable, which are at risk of churning, and how should retention
> effort and marketing spend be allocated across customer segments?**

Every classification/recommender project treats customers as data points to predict something
about. This project treats customers as a population to *understand and act on* — the output
isn't a single prediction, but a small number of named, interpretable segments with a
recommended action per segment.

## Dataset

**Source:** [UCI Online Retail Dataset](https://archive.ics.uci.edu/dataset/352/online+retail)
— transactional data from a UK-based online retailer, covering transactions across 4,338
customers (after cleaning) between December 2010 and December 2011.

## Business Questions

1. **Segmentation** — What natural customer groups emerge from purchase behavior?
2. **Value concentration** — How much of total revenue comes from the top segment(s)?
3. **Churn risk** — Which segment(s) show signs of disengagement, and how large is that group?
4. **Lifetime value** — What's the estimated value of each segment, and how should retention
   spend be prioritized accordingly?

## Project Structure

```
customer-segmentation-clv/
├── README.md
├── requirements.txt
├── data/
│   └── online_retail.xlsx            # download from UCI, not committed to git
├── notebooks/
│   ├── 01_data_cleaning.ipynb        # handle missing CustomerID, returns/cancellations, duplicates
│   ├── 02_rfm_feature_engineering.ipynb  # compute Recency, Frequency, Monetary per customer
│   ├── 03_clustering.ipynb           # K-Means, elbow method, silhouette score, segment profiling
│   └── 04_clv_analysis.ipynb         # estimate CLV per customer and per segment
├── sql/
│   └── segmentation_queries.sql      # RFM calculation and segment summaries in SQL
├── dashboard/
│   └── README.md                     # instructions for building the Power BI dashboard
├── visuals/
│   ├── rfm_distributions.png
│   ├── elbow_method.png
│   ├── cluster_scatter.png
│   ├── segment_profiles.png
│   └── clv_by_segment.png
└── reports/
    └── Segmentation_Insights.md      # findings + recommendations (export to PDF)
```

## Steps to Run

1. **Set up environment**
   ```bash
   python -m venv venv
   source venv/bin/activate        # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Download the data** from UCI and place it in `data/online_retail.xlsx`

3. **Run the notebooks in order** — `01` → `02` → `03` → `04`

4. **(Optional) Run the SQL version** — same RFM logic in `sql/segmentation_queries.sql`

5. **Build the dashboard** — follow `dashboard/README.md`

## Why RFM + K-Means (and Not Just "High/Medium/Low Spenders")

A lot of beginner segmentation projects just bucket customers into spend tiers. This project
does the fundamentals properly instead:
- **RFM captures behavior, not just value** — two customers can spend the same total amount,
  but one buys weekly and one bought once a year ago; raw spend alone can't distinguish them
- **Determining K properly** — using both the elbow method and silhouette score, rather than
  arbitrarily picking a number of segments
- **Feature scaling before clustering** — K-Means is distance-based, so Recency, Frequency,
  and Monetary (all on very different scales) are standardized first
- **Segments are named from their actual data, not guessed** — names are derived
  programmatically from each cluster's real RFM profile, avoiding mislabeling
- **Segments are profiled and prioritized, not just listed** — the analysis goes further than
  "here are 4 groups" to identify which specific customers within each group represent the
  most urgent business risk

## Key Results

**Clustering:** K=4 was selected using the elbow method (clear bend at K=3-4) and confirmed
with silhouette scores (K=4 scored 0.535, a negligible drop from K=3's 0.540, while offering
more actionable granularity than K=2's 0.660).

| Segment | Customers | % of Customers | Revenue Share | Avg Recency (days) | Avg Frequency | Avg CLV |
|---|---|---|---|---|---|---|
| Champions | 108 | 2.5% | 23.7% | 18.1 | 23.7 | ₦45,495 |
| Potential Loyalists | 556 | 12.8% | 34.6% | 21.9 | 10.7 | ₦12,901 |
| At-Risk | 2,636 | 60.8% | 35.1% | 48.2 | 2.8 | ₦2,757 |
| New / Low-Engagement | 1,038 | 23.9% | 6.6% | 250.6 | 1.5 | ₦1,320 |

Total revenue across all segments: **₦6,908,082.2**.

**Revenue concentration:** The top 10% of customers generate **50.4%** of total revenue; the
top 20% generate **67.4%** — a sharply unequal distribution that roughly mirrors the combined
size of the Champions + Potential Loyalists segments (664 customers, 15.3% of the base).

**Churn risk:** 1,449 customers (33.4% of the base) have not purchased in over 90 days,
representing ₦930,249.35 in historical revenue at risk. This risk is heavily skewed by value,
not just count:

| Segment | At-Risk Customers | At-Risk Revenue | Revenue per At-Risk Customer |
|---|---|---|---|
| Champions | 4 | ₦64,732.67 | ₦16,183 |
| Potential Loyalists | 14 | ₦74,437.67 | ₦5,317 |
| At-Risk (segment) | 393 | ₦334,211.72 | ₦851 |
| New / Low-Engagement | 1,038 | ₦456,867.29 | ₦440 |

Only 18 customers (4 Champions + 14 Potential Loyalists) have gone quiet, but they represent
₦139,170.34 in at-risk revenue — roughly **19x** the per-customer stakes of the
New/Low-Engagement group. Churn risk here is large in count but concentrated in value among a
small, identifiable group of previously high-value customers.

## Recommendations Summary

1. **Immediately flag and personally re-engage the 18 at-risk Champions and Potential
   Loyalists** (₦139,170.34 at risk) — a small, specific, high-value list justifying direct
   outreach rather than a broad campaign.
2. **Protect the Champions segment proactively** — 2.5% of customers drive ~24% of revenue;
   losing even a few would have an outsized impact.
3. **Use low-cost, automated win-back for the New/Low-Engagement group** — 1,038 customers but
   only ₦440 at-risk revenue each; high-touch retention here wouldn't be cost-effective.
4. **Re-run this segmentation quarterly** — customer behavior shifts, and a Champion today can
   become At-Risk in months.

*(Full findings and recommendations in `reports/Segmentation_Insights.md`.)*

## Tech Stack

Python, Pandas, NumPy, Scikit-learn (K-Means, StandardScaler), Matplotlib, Seaborn, Jupyter
Notebook, SQL, Power BI

## Author

## Michael Adedayo — Data Analyst, Data Scientist, Machine Learning.
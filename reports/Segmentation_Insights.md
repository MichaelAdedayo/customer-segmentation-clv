# Customer Segmentation & CLV — Insights & Recommendations

## Business Question

Which customers are most valuable, which are at risk of churning, and how should retention
effort and marketing spend be allocated across customer segments?

## Methodology

Analysis of 4,338 customers from the UCI Online Retail dataset, covering transactions between
December 2010 and December 2011. Cancelled orders (negative quantities) and transactions with
missing Customer ID were removed prior to analysis, since segmentation requires attributing
purchases to a known customer. RFM (Recency, Frequency, Monetary) features were computed per
customer, scaled using StandardScaler, and clustered using K-Means. The optimal number of
clusters (K=4) was determined using the elbow method (a clear bend at K=3-4) and confirmed
with a silhouette score of 0.535 — a negligible drop from K=3's 0.540, while offering more
actionable granularity than the technically higher-scoring K=2 (0.660), which was rejected for
being too coarse to support differentiated retention strategies. Segment names were derived
programmatically from each cluster's actual RFM profile (ranked by recency, frequency, and
monetary jointly) rather than assigned by manual guess, avoiding mislabeling.

## Findings

### 1. Segments Identified
K-Means clustering produced 4 distinct customer segments, ranking consistently together across
recency, frequency, and monetary value — this customer base shows a clean, linear relationship
between engagement and value rather than the more complex patterns (e.g. a distinct "high-value
but stale" group) that RFM segmentation sometimes surfaces elsewhere:

- **Champions** — 108 customers (2.5% of base): avg recency 18.1 days, avg frequency 23.7,
  avg monetary ₦15,165 — the retailer's most engaged and most valuable customers.
- **Potential Loyalists** — 556 customers (12.8% of base): avg recency 21.9 days, avg
  frequency 10.7, avg monetary ₦4,300 — solidly engaged customers with room to grow into
  Champions.
- **At-Risk** — 2,636 customers (60.8% of base): avg recency 48.2 days, avg frequency 2.8,
  avg monetary ₦919 — the largest segment, with declining engagement and modest spend.
- **New / Low-Engagement** — 1,038 customers (23.9% of base): avg recency 250.6 days, avg
  frequency 1.5, avg monetary ₦440 — customers with minimal engagement and a very long time
  since last purchase.

### 2. Revenue Concentration
Revenue is concentrated at the top: the top 10% of customers generate 50.4% of total revenue,
and the top 20% generate 67.4%. This closely mirrors the combined size of the Champions and
Potential Loyalists segments (664 customers, 15.3% of the base), which together account for
58.3% of total revenue (23.7% + 34.6%) out of ₦6,908,082.2 in total revenue across all
segments — confirming that a relatively small share of customers drives the majority of the
business.

### 3. Churn Risk
1,449 customers (33.4% of the base) have not purchased in over 90 days, representing
₦930,249.35 in historical revenue now at risk. This risk is large in count but heavily skewed
in value:

| Segment | At-Risk Customers | At-Risk Revenue | Revenue per At-Risk Customer |
|---|---|---|---|
| Champions | 4 | ₦64,732.67 | ₦16,183 |
| Potential Loyalists | 14 | ₦74,437.67 | ₦5,317 |
| At-Risk (segment) | 393 | ₦334,211.72 | ₦851 |
| New / Low-Engagement | 1,038 | ₦456,867.29 | ₦440 |

Only 18 customers (4 Champions + 14 Potential Loyalists) have gone quiet, but they represent
₦139,170.34 in at-risk revenue — roughly 19x the per-customer stakes of the New/Low-Engagement
group. Churn risk here is large in count but concentrated in value among a small, identifiable
group of previously high-value customers.

### 4. Customer Lifetime Value
Average CLV varies dramatically by segment: Champions average ₦45,495 per customer compared to
₦1,320 for New/Low-Engagement — a roughly 34x difference. Potential Loyalists (₦12,901) and
At-Risk (₦2,757) sit between these extremes, underscoring how differently retention and
marketing spend should be allocated across segments rather than treated uniformly.

## Recommendations

1. **Immediately flag and personally re-engage the 18 at-risk Champions and Potential
   Loyalists.** These customers represent ₦139,170.34 in at-risk revenue — a small, specific,
   high-value list that justifies direct outreach (account manager call, tailored offer)
   rather than a broad campaign, given their historical value.

2. **Protect and reward the Champions segment proactively — don't take them for granted.**
   This segment is only 2.5% of the customer base but drives 23.7% of total revenue; losing
   even a handful of these customers would have an outsized revenue impact. A loyalty program
   or early access to new products could reduce their churn risk further.

3. **Use low-cost, automated win-back for the New/Low-Engagement segment.** With 1,038
   customers but only ₦440 at-risk revenue each, expensive high-touch retention here would not
   be cost-effective — an automated email nurture sequence or modest discount is a better fit
   for this group's value level.

4. **Design a distinct conversion path for Potential Loyalists.** This segment (556 customers,
   34.6% of revenue) sits closest to Champions in behavior and represents the clearest
   opportunity to grow existing engagement into top-tier value through targeted incentives
   (e.g. loyalty tier upgrades tied to frequency).

5. **Re-run this segmentation quarterly.** Customer behavior shifts — a Champion today can
   become At-Risk in a few months. Treating this as a recurring analysis rather than a
   one-time snapshot allows the business to catch behavior shifts, like the early signs seen
   in the 18 at-risk high-value customers, before they fully churn.

## Limitations

This analysis is based on purchase transaction data only — it does not incorporate customer
service interactions, marketing engagement (email opens, site visits), or stated customer
preferences, all of which would sharpen segmentation further. CLV here is estimated from
historical spend patterns (average order value × frequency × an assumed 3-year customer
lifespan) rather than a full predictive CLV model incorporating churn probability, so it
should be treated as a directional estimate rather than a precise forecast of future value.
Revenue share and CLV figures are also drawn from a single 12-month window (December 2010 to
December 2011); segment behavior could shift materially outside this period, reinforcing the
recommendation to re-run this analysis on a recurring basis.
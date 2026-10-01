-- ============================================================================
-- Customer Segmentation & CLV — SQL Queries
-- Assumes a table `retail_transactions` loaded from the cleaned CSV, with columns:
-- invoice_no, stock_code, description, quantity, invoice_date, unit_price,
-- customer_id, country, line_total (quantity * unit_price)
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Q1: RFM Calculation per Customer
-- Recency: days since last purchase (relative to the day after the last date
-- in the dataset, so "today" is fixed and reproducible)
-- Frequency: number of distinct invoices (purchase occasions)
-- Monetary: total amount spent
-- ----------------------------------------------------------------------------
WITH snapshot AS (
    SELECT DATE(MAX(invoice_date), '+1 day') AS snapshot_date
    FROM retail_transactions
)
SELECT
    customer_id,
    CAST(julianday((SELECT snapshot_date FROM snapshot)) - julianday(MAX(invoice_date)) AS INTEGER) AS recency_days,
    COUNT(DISTINCT invoice_no) AS frequency,
    ROUND(SUM(line_total), 2) AS monetary
FROM retail_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary DESC;


-- ----------------------------------------------------------------------------
-- Q2: Simple RFM Scoring (quartile-based, 1-4 scale, without clustering)
-- Useful as a sanity check against the K-Means clusters from the notebook
-- ----------------------------------------------------------------------------
WITH snapshot AS (
    SELECT DATE(MAX(invoice_date), '+1 day') AS snapshot_date
),
rfm AS (
    SELECT
        customer_id,
        CAST(julianday((SELECT snapshot_date FROM snapshot)) - julianday(MAX(invoice_date)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(line_total) AS monetary
    FROM retail_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS recency_score,   -- lower recency = higher score
    NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
FROM rfm
ORDER BY monetary DESC;


-- ----------------------------------------------------------------------------
-- Q3: Revenue Concentration — what share of total revenue comes from the top
-- 10% / 20% of customers? (checks for dangerous revenue concentration)
-- ----------------------------------------------------------------------------
WITH customer_totals AS (
    SELECT customer_id, SUM(line_total) AS monetary
    FROM retail_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        monetary,
        NTILE(10) OVER (ORDER BY monetary DESC) AS decile
    FROM customer_totals
)
SELECT
    decile,
    COUNT(*) AS customers_in_decile,
    ROUND(SUM(monetary), 2) AS decile_revenue,
    ROUND(100.0 * SUM(monetary) / (SELECT SUM(monetary) FROM customer_totals), 2) AS pct_of_total_revenue
FROM ranked
GROUP BY decile
ORDER BY decile;


-- ----------------------------------------------------------------------------
-- Q4: Churn Risk — customers with no purchase in the last 90 days
-- ----------------------------------------------------------------------------
WITH snapshot AS (
    SELECT DATE(MAX(invoice_date), '+1 day') AS snapshot_date
),
last_purchase AS (
    SELECT customer_id, MAX(invoice_date) AS last_date, SUM(line_total) AS lifetime_spend
    FROM retail_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    last_date,
    CAST(julianday((SELECT snapshot_date FROM snapshot)) - julianday(last_date) AS INTEGER) AS days_since_last_purchase,
    ROUND(lifetime_spend, 2) AS lifetime_spend
FROM last_purchase
WHERE julianday((SELECT snapshot_date FROM snapshot)) - julianday(last_date) > 90
ORDER BY lifetime_spend DESC;


-- Count and value of at-risk customers as a share of the whole base
WITH snapshot AS (
    SELECT DATE(MAX(invoice_date), '+1 day') AS snapshot_date
),
last_purchase AS (
    SELECT customer_id, MAX(invoice_date) AS last_date, SUM(line_total) AS lifetime_spend
    FROM retail_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    SUM(CASE WHEN julianday((SELECT snapshot_date FROM snapshot)) - julianday(last_date) > 90 THEN 1 ELSE 0 END) AS at_risk_customers,
    COUNT(*) AS total_customers,
    ROUND(100.0 * SUM(CASE WHEN julianday((SELECT snapshot_date FROM snapshot)) - julianday(last_date) > 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_at_risk,
    ROUND(SUM(CASE WHEN julianday((SELECT snapshot_date FROM snapshot)) - julianday(last_date) > 90 THEN lifetime_spend ELSE 0 END), 2) AS at_risk_revenue
FROM last_purchase;

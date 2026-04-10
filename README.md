# 🔍 Search Feature Performance Analysis (SQL Case Study)

## 📌 Business Problem

Search is a critical feature for product discovery. Poor search performance can lead to user frustration, reduced engagement, and lost revenue.

This analysis evaluates search performance to identify issues in:

* user engagement
* ranking quality
* query effectiveness

---

## 📊 Dataset Overview

The dataset simulates user interaction with a product search feature and includes:

* **1,210 searches**
* **8,224 search results**
* **1,024 clicks**
* **250 users**

Tables:

* `searches` — user queries and metadata
* `search_results` — ranked results per search
* `clicks` — user interactions
* `users` — user segmentation data

---

## 📈 Key Metrics

### Overall Search Engagement

```sql
SELECT
    COUNT(DISTINCT s.search_id) AS total_searches,
    COUNT(DISTINCT c.search_id) AS searches_with_click,
    ROUND(
        100.0 * COUNT(DISTINCT c.search_id) / COUNT(DISTINCT s.search_id),
        2
    ) AS ctr_pct
FROM searches s
LEFT JOIN clicks c
    ON s.search_id = c.search_id;
```

* **CTR: 67.17%**
* ~33% of searches result in no clicks

---

### Abandonment Rate

```sql
SELECT
    COUNT(DISTINCT s.search_id) AS total_searches,
    COUNT(DISTINCT CASE WHEN c.search_id IS NULL THEN s.search_id END) AS abandoned_searches,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN c.search_id IS NULL THEN s.search_id END)
        / COUNT(DISTINCT s.search_id),
        2
    ) AS abandonment_rate_pct
FROM searches s
LEFT JOIN clicks c
    ON s.search_id = c.search_id;
```

* **Abandonment Rate: 32.83%**

---

### CTR by Position (Ranking Effectiveness)

```sql
SELECT
    sr.position,
    COUNT(*) AS times_shown,
    COUNT(c.click_id) AS clicks,
    ROUND(100.0 * COUNT(c.click_id) / COUNT(*), 2) AS ctr_pct
FROM search_results sr
LEFT JOIN clicks c
    ON sr.search_id = c.search_id
   AND sr.result_id = c.result_id
GROUP BY sr.position
ORDER BY sr.position;
```

---

## 🔍 Key Insights

### 1. Moderate Engagement, High Drop-off

* CTR is **67%**, but **~33% of searches are abandoned**
* Indicates issues with relevance or result quality

---

### 2. Ranking Algorithm Issue

* Position 1 CTR: **31.9%**
* Position 2 CTR: **37.5% (highest)**

👉 The top result is not the most relevant

---

### 3. Sharp Attention Drop After Top Results

* Positions 6–10 receive **near-zero engagement**
* Majority of value is concentrated in top 5 results

---

### 4. Query Quality Drives Performance

* Poor queries:

  * *xyz product* → **13% CTR**
  * *random abc item* → **16% CTR**

* Strong queries:

  * *phone charger* → **63% CTR**
  * *travel mug* → **63% CTR**

👉 Indicates gaps in query understanding and catalog coverage

---

### 5. Premium Users Show Lower Engagement

* Free users CTR: **68.3%**
* Premium users CTR: **63.2%**

👉 Suggests higher expectations or unmet intent among premium users

---

### 6. Zero-Result Searches

* **3.72%** of searches return no results
* These queries show extremely low engagement

---

## 💡 Recommendations

* Improve ranking algorithm to prioritize relevant results at position 1
* Implement query understanding improvements (synonyms, typo handling)
* Address zero-result queries with fallback suggestions
* Focus optimization on top 5 results where engagement is concentrated
* Analyze premium user behavior to better meet expectations

---

## 🧠 Skills Demonstrated

* SQL (joins, aggregations, conditional logic)
* Product and behavioral analytics
* Funnel and engagement analysis
* Data storytelling and insight generation
* Translating data into business recommendations

---

## 🚀 Next Steps

* Develop dashboard visualizations (Tableau / Power BI)
* Analyze query refinement behavior
* Design A/B testing framework for ranking improvements

---

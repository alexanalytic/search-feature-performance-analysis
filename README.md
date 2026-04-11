# 🔍 Search Feature Performance Analysis (SQL Case Study)
**Goal:** Evaluate search performance and identify opportunities to improve ranking quality and user engagement.
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

* `searches` —> user queries and metadata
* `search_results` —> ranked results per search
* `clicks` —> user interactions
* `users` —> user segmentation data

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
**Result:**

<img width="269" height="51" alt="image" src="https://github.com/user-attachments/assets/b10705e4-1ef3-464f-9839-3b297dbea184" />



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
**Result:**

<img width="369" height="51" alt="image" src="https://github.com/user-attachments/assets/8201d7b8-f360-455d-835c-829ec5b2fd67" />


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
**Result:**

<img width="231" height="285" alt="image" src="https://github.com/user-attachments/assets/c419b28e-dbab-493c-9e86-c42098025dd4" />

* **Position 1 CTR: 31.86%**
* **Position 2 CTR: 37.49%** (highest)
* **Positions 6–10: ~0%** engagement

### Query CTR Ranking

```sql
WITH query_ctr AS (
    SELECT
        s.query,
        COUNT(DISTINCT s.search_id) AS searches,
        COUNT(DISTINCT c.search_id) AS searches_with_click,
        ROUND(
            100.0 * COUNT(DISTINCT c.search_id) / COUNT(DISTINCT s.search_id),
            2
        ) AS ctr_pct
    FROM searches s
    LEFT JOIN clicks c
        ON s.search_id = c.search_id
    GROUP BY s.query
    HAVING COUNT(DISTINCT s.search_id) >= 10
)
SELECT
    query,
    searches,
    searches_with_click,
    ctr_pct,
    RANK() OVER (ORDER BY ctr_pct DESC) AS ctr_rank
FROM query_ctr
ORDER BY ctr_rank, query;
```
**Result:**

<img width="449" height="750" alt="image" src="https://github.com/user-attachments/assets/56ae5cad-ad71-4929-8e29-263bc5c1ff09" />


**Key Takeaways:**
* Queries show significant variation in CTR, highlighting differences in user intent and result relevance  
* Ranking queries using a window function enables quick identification of top- and low-performing search terms  
* Low-performing queries represent clear opportunities to improve search relevance and query handling  

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

## 🧠 Analytical Approach

* SQL (joins, aggregations, conditional logic)
* Product and behavioral analytics
* Funnel and engagement analysis
* Data storytelling and insight generation
* Translating data into business recommendations

---

-- CTR
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

-- Abandonment
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

-- CTR by position
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

-- Zero-result rate
SELECT
    COUNT(*) AS total_searches,
    SUM(CASE WHEN results_returned = 0 THEN 1 ELSE 0 END) AS zero_result_searches,
    ROUND(
        100.0 * SUM(CASE WHEN results_returned = 0 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS zero_result_rate_pct
FROM searches;

-- Query performance - worst queries
SELECT
    s.query,
    COUNT(DISTINCT s.search_id) AS searches,
    COUNT(DISTINCT c.search_id) AS searches_with_click,
    ROUND(
        100.0 * COUNT(DISTINCT c.search_id) / COUNT(DISTINCT s.search_id),
        2
    ) AS query_ctr_pct
FROM searches s
LEFT JOIN clicks c
    ON s.search_id = c.search_id
GROUP BY s.query
HAVING COUNT(DISTINCT s.search_id) >= 10
ORDER BY query_ctr_pct ASC, searches DESC
LIMIT 10;

-- User segmentation - free vs premium
SELECT
    u.user_type,
    COUNT(DISTINCT s.search_id) AS total_searches,
    COUNT(DISTINCT c.search_id) AS searches_with_click,
    ROUND(
        100.0 * COUNT(DISTINCT c.search_id) / COUNT(DISTINCT s.search_id),
        2
    ) AS ctr_pct
FROM searches s
JOIN users u
    ON s.user_id = u.user_id
LEFT JOIN clicks c
    ON s.search_id = c.search_id
GROUP BY u.user_type;

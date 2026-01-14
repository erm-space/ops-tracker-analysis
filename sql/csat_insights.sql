/*
06_csat_insights.sql
Goal: CSAT analysis.
Assumption: csat_surveys has (rating, submitted_at, agent_id, ticket_id, customer_id)
*/

USE ops_tracker;

-- Overall CSAT
SELECT
  COUNT(*) AS surveys,
  ROUND(AVG(rating), 2) AS avg_rating
FROM csat_surveys;

-- CSAT by agent (only agents with enough surveys)
SELECT
  a.full_name,
  COUNT(*) AS surveys,
  ROUND(AVG(c.rating), 2) AS avg_rating
FROM csat_surveys c
JOIN agents a ON c.agent_id = a.agent_id
GROUP BY a.full_name
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- CSAT by channel
SELECT
  ch.channel_name,
  COUNT(*) AS surveys,
  ROUND(AVG(c.rating), 2) AS avg_rating
FROM csat_surveys c
JOIN tickets t ON c.ticket_id = t.ticket_id
JOIN channels ch ON t.channel_id = ch.channel_id
GROUP BY ch.channel_name
ORDER BY avg_rating DESC;

-- CSAT vs resolution time buckets
SELECT
  CASE
    WHEN TIMESTAMPDIFF(HOUR, t.created_at, t.resolved_at) < 4 THEN '<4h'
    WHEN TIMESTAMPDIFF(HOUR, t.created_at, t.resolved_at) < 24 THEN '4-24h'
    WHEN TIMESTAMPDIFF(HOUR, t.created_at, t.resolved_at) < 72 THEN '1-3d'
    ELSE '3d+'
  END AS resolution_bucket,
  COUNT(*) AS surveys,
  ROUND(AVG(c.rating), 2) AS avg_rating
FROM csat_surveys c
JOIN tickets t ON c.ticket_id = t.ticket_id
WHERE t.resolved_at IS NOT NULL
GROUP BY resolution_bucket
ORDER BY surveys DESC;
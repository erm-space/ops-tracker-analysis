/*
02_volume_trends.sql
Goal: Ticket volume trends + composition.
*/

USE ops_tracker;

-- Tickets over time (monthly)
SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS month,
  COUNT(*) AS tickets
FROM tickets
GROUP BY month
ORDER BY month;

-- Tickets by channel
SELECT
  ch.channel_name,
  COUNT(*) AS tickets
FROM tickets t
JOIN channels ch ON t.channel_id = ch.channel_id
GROUP BY ch.channel_name
ORDER BY tickets DESC;

-- Tickets by product + category (top combos)
SELECT
  p.product_name,
  cat.category_name,
  COUNT(*) AS tickets
FROM tickets t
JOIN products p ON t.product_id = p.product_id
JOIN categories cat ON t.category_id = cat.category_id
GROUP BY p.product_name, cat.category_name
ORDER BY tickets DESC
LIMIT 20;

-- Status distribution
SELECT status, COUNT(*) AS tickets
FROM tickets
GROUP BY status
ORDER BY tickets DESC;

-- Priority distribution
SELECT priority, COUNT(*) AS tickets
FROM tickets
GROUP BY priority
ORDER BY tickets DESC;
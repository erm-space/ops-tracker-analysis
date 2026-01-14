/*
05_customer_insights.sql
Goal: Customer behavior + repeat contact + plan segmentation.
Assumption: customers has (plan, state/country) etc.
*/

USE ops_tracker;

-- Tickets per customer (repeat contact)
SELECT
  c.customer_id,
  c.full_name,
  c.plan,
  COUNT(t.ticket_id) AS tickets
FROM customers c
JOIN tickets t ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.plan
ORDER BY tickets DESC
LIMIT 50;

-- Tickets by plan
SELECT
  c.plan,
  COUNT(*) AS tickets
FROM tickets t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.plan
ORDER BY tickets DESC;

-- Tickets by customer location (top states)
SELECT
  c.state,
  COUNT(*) AS tickets
FROM tickets t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.state
ORDER BY tickets DESC
LIMIT 15;
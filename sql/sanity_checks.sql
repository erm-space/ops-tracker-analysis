/*
01_sanity_checks.sql
Goal: Confirm the database is complete + joins behave.
No schema changes. Read-only queries.
*/

USE ops_tracker;

-- 1) Row counts (fast confidence check)

SELECT 'tickets' AS table_name, COUNT(*) AS rows_count FROM tickets
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'agents', COUNT(*) FROM agents
UNION ALL
SELECT 'ticket_events', COUNT(*) FROM ticket_events
UNION ALL
SELECT 'csat_surveys', COUNT(*) FROM csat_surveys
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'channels', COUNT(*) FROM channels
UNION ALL
SELECT 'priorities', COUNT(*) FROM priorities
UNION ALL
SELECT 'sla_targets', COUNT(*) FROM sla_targets;

-- 2) Null checks on key columns (should be low/zero)
SELECT
  SUM(ticket_id IS NULL) AS null_ticket_id,
  SUM(customer_id IS NULL) AS null_customer_id,
  SUM(created_at IS NULL) AS null_created_at
FROM tickets;

-- 3) FK integrity checks (should be 0)
SELECT COUNT(*) AS tickets_missing_customer
FROM tickets t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS tickets_missing_agent
FROM tickets t
LEFT JOIN agents a ON t.agent_id = a.agent_id
WHERE t.agent_id IS NOT NULL
  AND a.agent_id IS NULL;

-- 4) Quick sample join preview
SELECT
  t.ticket_id,
  c.full_name AS customer,
  a.full_name AS agent,
  t.priority,
  t.status,
  t.created_at
FROM tickets t
JOIN customers c ON t.customer_id = c.customer_id
LEFT JOIN agents a ON t.agent_id = a.agent_id
ORDER BY t.created_at DESC
LIMIT 20;
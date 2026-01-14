/*
03_sla_performance.sql
Goal: SLA performance using sla_targets table.
Assumption: sla_targets has (priority, first_response_minutes, resolution_minutes)
*/

USE ops_tracker;

-- Avg first response time (minutes) by priority
SELECT
  t.priority,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at)), 2) AS avg_first_response_min
FROM tickets t
WHERE t.first_response_at IS NOT NULL
GROUP BY t.priority
ORDER BY avg_first_response_min;

-- Avg resolution time (minutes) by priority
SELECT
  t.priority,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)), 2) AS avg_resolution_min
FROM tickets t
WHERE t.resolved_at IS NOT NULL
GROUP BY t.priority
ORDER BY avg_resolution_min;

-- First-response SLA compliance %
SELECT
  t.priority,
  COUNT(*) AS tickets_with_first_response,
  SUM(
    TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at) <= s.first_response_minutes
  ) AS met_sla,
  ROUND(
    100 * SUM(
      TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at) <= s.first_response_minutes
    ) / COUNT(*), 2
  ) AS sla_met_pct
FROM tickets t
JOIN sla_targets s ON t.priority = s.priority
WHERE t.first_response_at IS NOT NULL
GROUP BY t.priority
ORDER BY sla_met_pct DESC;

-- Resolution SLA compliance %
SELECT
  t.priority,
  COUNT(*) AS tickets_resolved,
  SUM(
    TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_minutes
  ) AS met_sla,
  ROUND(
    100 * SUM(
      TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_minutes
    ) / COUNT(*), 2
  ) AS sla_met_pct
FROM tickets t
JOIN sla_targets s ON t.priority = s.priority
WHERE t.resolved_at IS NOT NULL
GROUP BY t.priority
ORDER BY sla_met_pct DESC;
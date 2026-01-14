/*
04_agent_performance.sql
Goal: Agent + team performance.
*/

USE ops_tracker;

-- Tickets handled per agent
SELECT
  a.full_name,
  te.team_name,
  COUNT(*) AS tickets_handled
FROM tickets t
JOIN agents a ON t.agent_id = a.agent_id
JOIN teams te ON a.team_id = te.team_id
GROUP BY a.full_name, te.team_name
ORDER BY tickets_handled DESC
LIMIT 20;

-- Avg resolution hours per agent (only resolved tickets)
SELECT
  a.full_name,
  ROUND(AVG(TIMESTAMPDIFF(HOUR, t.created_at, t.resolved_at)), 2) AS avg_resolution_hours,
  COUNT(*) AS resolved_tickets
FROM tickets t
JOIN agents a ON t.agent_id = a.agent_id
WHERE t.resolved_at IS NOT NULL
GROUP BY a.full_name
HAVING COUNT(*) >= 50
ORDER BY avg_resolution_hours;

-- First response minutes per agent
SELECT
  a.full_name,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at)), 2) AS avg_first_response_min,
  COUNT(*) AS tickets_with_response
FROM tickets t
JOIN agents a ON t.agent_id = a.agent_id
WHERE t.first_response_at IS NOT NULL
GROUP BY a.full_name
HAVING COUNT(*) >= 50
ORDER BY avg_first_response_min;
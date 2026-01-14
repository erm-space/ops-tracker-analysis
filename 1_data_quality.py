import os
from db import query_df

os.makedirs("outputs/csv", exist_ok=True)

sql = """
SELECT 'agents' AS table_name, COUNT(*) AS rows_count FROM agents
UNION ALL SELECT 'teams', COUNT(*) FROM teams
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'tickets', COUNT(*) FROM tickets
UNION ALL SELECT 'ticket_events', COUNT(*) FROM ticket_events
UNION ALL SELECT 'ticket_tags', COUNT(*) FROM ticket_tags
UNION ALL SELECT 'ticket_tag_map', COUNT(*) FROM ticket_tag_map
UNION ALL SELECT 'csat_surveys', COUNT(*) FROM csat_surveys
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'channels', COUNT(*) FROM channels
UNION ALL SELECT 'priorities', COUNT(*) FROM priorities
UNION ALL SELECT 'sla_targets', COUNT(*) FROM sla_targets;
"""

df_counts = query_df(sql)
print(df_counts)

df_counts.to_csv("outputs/csv/table_row_counts.csv", index=False)

# quick missing checks on key fields
sql_missing = """
SELECT
  SUM(customer_id IS NULL) AS missing_customer_id,
  SUM(agent_id IS NULL) AS missing_agent_id,
  SUM(first_response_at IS NULL) AS missing_first_response_at,
  SUM(resolved_at IS NULL) AS missing_resolved_at
FROM tickets;
"""
df_missing = query_df(sql_missing)
print(df_missing)
df_missing.to_csv("outputs/csv/missing_values_tickets.csv", index=False)

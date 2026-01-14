import os
from db import query_df

os.makedirs("outputs/csv", exist_ok=True)

df_master = query_df("""
SELECT
  t.ticket_id,
  t.created_at,
  t.resolved_at,
  t.status,
  t.priority,
  ch.channel_name,
  cat.category_name,
  p.product_name,
  a.full_name AS agent_name,
  te.team_name
FROM tickets t
LEFT JOIN channels ch ON t.channel_id = ch.channel_id
LEFT JOIN categories cat ON t.category_id = cat.category_id
LEFT JOIN products p ON t.product_id = p.product_id
LEFT JOIN agents a ON t.agent_id = a.agent_id
LEFT JOIN teams te ON a.team_id = te.team_id
LIMIT 5000;
""")

df_master.to_csv("outputs/csv/tickets_master_sample_5000.csv", index=False)
print("Exported tickets_master_sample_5000.csv ✅")
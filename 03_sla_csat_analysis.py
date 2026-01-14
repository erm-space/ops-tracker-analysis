import os
from db import query_df

os.makedirs("outputs/csv", exist_ok=True)

# SLA compliance: first response and resolution (minutes)
df_sla = query_df("""
SELECT
  t.priority,
  COUNT(*) AS total_tickets,
  AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at)) AS avg_first_response_min,
  AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) AS avg_resolution_min
FROM tickets t
WHERE t.first_response_at IS NOT NULL
  AND t.resolved_at IS NOT NULL
GROUP BY t.priority
ORDER BY total_tickets DESC;
""")
print(df_sla)
df_sla.to_csv("outputs/csv/sla_by_priority.csv", index=False)

# CSAT average by channel
df_csat_channel = query_df("""
SELECT
  ch.channel_name,
  COUNT(*) AS responses,
  AVG(c.rating) AS avg_rating
FROM csat_surveys c
JOIN tickets t ON c.ticket_id = t.ticket_id
JOIN channels ch ON t.channel_id = ch.channel_id
WHERE c.rating IS NOT NULL
GROUP BY ch.channel_name
ORDER BY avg_rating DESC;
""")
print(df_csat_channel)
df_csat_channel.to_csv("outputs/csv/csat_by_channel.csv", index=False)
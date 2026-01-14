import os
from db import query_df

os.makedirs("outputs/csv", exist_ok=True)

df_events = query_df("""
SELECT event_type, COUNT(*) AS events
FROM ticket_events
GROUP BY event_type
ORDER BY events DESC;
""")
print(df_events)
df_events.to_csv("outputs/csv/events_by_type.csv", index=False)

df_status_flow = query_df("""
SELECT old_status, new_status, COUNT(*) AS transitions
FROM ticket_events
WHERE old_status IS NOT NULL AND new_status IS NOT NULL
GROUP BY old_status, new_status
ORDER BY transitions DESC
LIMIT 20;
""")
print(df_status_flow)
df_status_flow.to_csv("outputs/csv/top_20_status_transitions.csv", index=False)
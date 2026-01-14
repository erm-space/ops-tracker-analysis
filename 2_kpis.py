import os
import matplotlib.pyplot as plt
from db import query_df

os.makedirs("outputs/charts", exist_ok=True)
os.makedirs("outputs/csv", exist_ok=True)

# Ticket volume by status
df_status = query_df("""
SELECT status, COUNT(*) AS tickets
FROM tickets
GROUP BY status
ORDER BY tickets DESC;
""")
print(df_status)
df_status.to_csv("outputs/csv/tickets_by_status.csv", index=False)

plt.figure()
plt.bar(df_status["status"], df_status["tickets"])
plt.xticks(rotation=30, ha="right")
plt.title("Tickets by Status")
plt.tight_layout()
plt.savefig("outputs/charts/tickets_by_status.png")
plt.close()

# Tickets by channel
df_channel = query_df("""
SELECT ch.channel_name, COUNT(*) AS tickets
FROM tickets t
JOIN channels ch ON t.channel_id = ch.channel_id
GROUP BY ch.channel_name
ORDER BY tickets DESC;
""")
df_channel.to_csv("outputs/csv/tickets_by_channel.csv", index=False)

plt.figure()
plt.bar(df_channel["channel_name"], df_channel["tickets"])
plt.xticks(rotation=30, ha="right")
plt.title("Tickets by Channel")
plt.tight_layout()
plt.savefig("outputs/charts/tickets_by_channel.png")
plt.close()

print("Saved CSV + charts ✅")

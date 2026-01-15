import pandas as pd
from sqlalchemy import text
from db import engine


def read_sql(query: str) -> pd.DataFrame:
    """Run a SQL query and return a pandas DataFrame."""
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)


def pct(part: int, whole: int) -> float:
    return (part / whole * 100) if whole else 0.0


def main():
    print("BUSINESS ANALYSIS REPORT")
    print("-" * 60)

    # 1) Total tickets + status breakdown
    status_df = read_sql("""
        SELECT
            LOWER(TRIM(status)) AS status,
            COUNT(*) AS tickets
        FROM tickets
        GROUP BY LOWER(TRIM(status))
        ORDER BY tickets DESC;
    """)
    total_tickets = int(status_df["tickets"].sum())

    print(f"Total tickets: {total_tickets}\n")
    print("Tickets by status:")
    for _, r in status_df.iterrows():
        s = str(r["status"])
        c = int(r["tickets"])
        print(f"  - {s}: {c} ({pct(c, total_tickets):.1f}%)")

    print("\n" + "-" * 60)

    # 2) Channel usage (volume + share)
    channel_df = read_sql("""
        SELECT
            c.channel_name AS channel,
            COUNT(*) AS tickets
        FROM tickets t
        LEFT JOIN channels c ON t.channel_id = c.channel_id
        GROUP BY c.channel_name
        ORDER BY tickets DESC;
    """)
    print("Tickets by channel:")
    for _, r in channel_df.iterrows():
        channel = r["channel"] if pd.notna(r["channel"]) else "unknown"
        c = int(r["tickets"])
        print(f"  - {channel}: {c} ({pct(c, total_tickets):.1f}%)")

    print("\n" + "-" * 60)

    # 3) Priority overview
    priority_df = read_sql("""
        SELECT
            LOWER(TRIM(priority)) AS priority,
            COUNT(*) AS tickets
        FROM tickets
        GROUP BY LOWER(TRIM(priority))
        ORDER BY tickets DESC;
    """)
    print("Tickets by priority:")
    for _, r in priority_df.iterrows():
        p = str(r["priority"])
        c = int(r["tickets"])
        print(f"  - {p}: {c} ({pct(c, total_tickets):.1f}%)")

    print("\n" + "-" * 60)

    # 4) Response & resolution time (overall)
    times_df = read_sql("""
        SELECT
            AVG(TIMESTAMPDIFF(MINUTE, created_at, first_response_at)) AS avg_first_response_min,
            AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)) AS avg_resolution_min
        FROM tickets
        WHERE first_response_at IS NOT NULL
          AND resolved_at IS NOT NULL;
    """)
    avg_fr = float(times_df.loc[0, "avg_first_response_min"])
    avg_res = float(times_df.loc[0, "avg_resolution_min"])
    print(f"Average first response time (min): {avg_fr:.1f}")
    print(f"Average resolution time (min):     {avg_res:.1f}")

    print("\n" + "-" * 60)

    # 5) SLA compliance (based on sla_targets table)
    sla_df = read_sql("""
        SELECT
            LOWER(TRIM(t.priority)) AS priority,
            COUNT(*) AS total_tickets,
            SUM(
                CASE
                    WHEN TIMESTAMPDIFF(MINUTE, t.created_at, t.first_response_at) <= s.first_response_minutes
                    THEN 1 ELSE 0
                END
            ) AS within_first_response_sla,
            SUM(
                CASE
                    WHEN TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at) <= s.resolution_minutes
                    THEN 1 ELSE 0
                END
            ) AS within_resolution_sla
        FROM tickets t
        JOIN sla_targets s ON LOWER(TRIM(t.priority)) = LOWER(TRIM(s.priority))
        WHERE t.first_response_at IS NOT NULL
          AND t.resolved_at IS NOT NULL
        GROUP BY LOWER(TRIM(t.priority))
        ORDER BY total_tickets DESC;
    """)

    print("SLA compliance by priority (only tickets with response+resolution timestamps):")
    for _, r in sla_df.iterrows():
        pr = str(r["priority"])
        tot = int(r["total_tickets"])
        fr_ok = int(r["within_first_response_sla"])
        res_ok = int(r["within_resolution_sla"])
        print(
            f"  - {pr}: "
            f"First response SLA {fr_ok}/{tot} ({pct(fr_ok, tot):.1f}%), "
            f"Resolution SLA {res_ok}/{tot} ({pct(res_ok, tot):.1f}%)"
        )

    print("\n" + "-" * 60)

    # 6) Top 10 agents by ticket volume + avg resolution time
    agents_df = read_sql("""
        SELECT
            a.full_name AS agent,
            COUNT(*) AS tickets,
            AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.resolved_at)) AS avg_resolution_min
        FROM tickets t
        LEFT JOIN agents a ON t.agent_id = a.agent_id
        WHERE t.resolved_at IS NOT NULL
        GROUP BY a.full_name
        ORDER BY tickets DESC
        LIMIT 10;
    """)
    print("Top 10 agents by resolved ticket volume (with avg resolution time):")
    for _, r in agents_df.iterrows():
        agent = r["agent"] if pd.notna(r["agent"]) else "unknown"
        c = int(r["tickets"])
        avg_m = float(r["avg_resolution_min"]) if pd.notna(r["avg_resolution_min"]) else 0.0
        print(f"  - {agent}: {c} tickets, avg resolution {avg_m:.1f} min")

    print("\n" + "-" * 60)

    # 7) Time-based: tickets by weekday
    weekday_df = read_sql("""
        SELECT
            DAYNAME(created_at) AS weekday,
            COUNT(*) AS tickets
        FROM tickets
        GROUP BY DAYNAME(created_at)
        ORDER BY tickets DESC;
    """)
    print("Tickets by weekday (created):")
    for _, r in weekday_df.iterrows():
        day = str(r["weekday"])
        c = int(r["tickets"])
        print(f"  - {day}: {c}")

    print("\nDONE.")


if __name__ == "__main__":
    main()

from pathlib import Path
import pandas as pd

# ----------------------------
# FINAL SUMMARY (reads CSV outputs)
# ----------------------------

BASE_DIR = Path(__file__).resolve().parent
OUTPUTS_DIR = BASE_DIR / "outputs"
CSV_DIR = OUTPUTS_DIR / "csv"


def read_csv_safe(path: Path) -> pd.DataFrame:
    """Read CSV safely + return empty df if missing."""
    if not path.exists():
        print(f"[WARN] Missing file: {path.name}")
        return pd.DataFrame()
    return pd.read_csv(path)


def pick_existing_col(df: pd.DataFrame, candidates: list[str]) -> str | None:
    """Return first column that exists in df."""
    for c in candidates:
        if c in df.columns:
            return c
    return None


print("FINAL SUMMARY ✅")

# ----------------------------
# 1) Most common status
# ----------------------------
status_df = read_csv_safe(CSV_DIR / "tickets_by_status.csv")
if not status_df.empty:
    # your CSV could be: status + tickets (or count)
    status_col = pick_existing_col(status_df, ["status", "ticket_status"])
    metric_col = pick_existing_col(status_df, ["tickets", "count", "total_tickets"])

    if status_col and metric_col:
        top = status_df.sort_values(metric_col, ascending=False).iloc[0]
        print(f"- Most common status: {top[status_col]} ({int(top[metric_col])} tickets)")
    else:
        print(f"[WARN] tickets_by_status.csv columns found: {list(status_df.columns)}")

# ----------------------------
# 2) Most used channel
# ----------------------------
channel_df = read_csv_safe(CSV_DIR / "tickets_by_channel.csv")
if not channel_df.empty:
    # your CSV could be: channel + tickets
    channel_col = pick_existing_col(channel_df, ["channel", "channel_name"])
    metric_col = pick_existing_col(channel_df, ["tickets", "count", "total_tickets"])

    if channel_col and metric_col:
        top = channel_df.sort_values(metric_col, ascending=False).iloc[0]
        print(f"- Most used channel: {top[channel_col]} ({int(top[metric_col])} tickets)")
    else:
        print(f"[WARN] tickets_by_channel.csv columns found: {list(channel_df.columns)}")

# ----------------------------
# 3) SLA overview by priority
# ----------------------------
sla_df = read_csv_safe(CSV_DIR / "sla_by_priority.csv")
if not sla_df.empty:
    # Expecting columns like:
    # priority, total_tickets, avg_first_response_min, avg_resolution_min
    print("\nSLA overview (top rows):")
    # Print nicely even if column names differ slightly
    cols_to_show = []
    for c in ["priority", "total_tickets", "avg_first_response_min", "avg_resolution_min"]:
        if c in sla_df.columns:
            cols_to_show.append(c)

    if cols_to_show:
        print(sla_df[cols_to_show].head(10).to_string(index=False))
    else:
        print(sla_df.head(10).to_string(index=False))

# ----------------------------
# 4) Most common status transition (FIX nan → nan)
# ----------------------------
trans_df = read_csv_safe(CSV_DIR / "top_20_status_transitions.csv")
if not trans_df.empty:
    # Your file shows: old_status, new_status, transitions
    old_col = pick_existing_col(trans_df, ["old_status", "from_status", "old"])
    new_col = pick_existing_col(trans_df, ["new_status", "to_status", "new"])
    metric_col = pick_existing_col(trans_df, ["transitions", "count", "tickets", "events", "transition_count"])

    if old_col and new_col and metric_col:
        # Clean missing/blank values
        trans_df[old_col] = trans_df[old_col].astype(str).str.strip().replace({"": None, "nan": None})
        trans_df[new_col] = trans_df[new_col].astype(str).str.strip().replace({"": None, "nan": None})
        trans_df = trans_df.dropna(subset=[old_col, new_col])

        if not trans_df.empty:
            top = trans_df.sort_values(metric_col, ascending=False).iloc[0]
            print(f"\n- Most common status transition: {top[old_col]} → {top[new_col]} ({int(top[metric_col])})")
        else:
            print("\n[WARN] All status transition rows had missing statuses after cleaning.")
    else:
        print(f"\n[WARN] top_20_status_transitions.csv columns found: {list(trans_df.columns)}")

# ----------------------------
# 5) Table row counts (sanity check)
# ----------------------------
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
COUNTS_PATH = BASE_DIR / "outputs" / "csv" / "table_row_counts.csv"

if COUNTS_PATH.exists():
    counts = pd.read_csv(COUNTS_PATH)

    # Normalize column names (so no warning + future-proof)
    counts.columns = [c.strip().lower() for c in counts.columns]

    rename_map = {
        "rows_count": "rows",
        "row_count": "rows",
        "count": "rows",
        "rowscount": "rows",
    }
    counts = counts.rename(columns=rename_map)

    # Ensure we have the standard names
    if "table_name" in counts.columns and "rows" in counts.columns:
        # Example: print them nicely (optional)
        # print("\nLoaded table row counts ✅")
        # print(counts.sort_values("rows", ascending=False).head(20).to_string(index=False))
        pass
    else:
        print(f"[WARN] table_row_counts.csv columns found: {list(counts.columns)}")
else:
    print("[WARN] table_row_counts.csv not found")

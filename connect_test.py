from sqlalchemy import create_engine, text

engine = create_engine(
    "mysql+pymysql://ops_user:OpsTracker%232026%21@127.0.0.1:3306/ops_tracker"
)

with engine.connect() as conn:
    print("Connected ✅", conn.execute(text("SELECT DATABASE()")).scalar())
    print("Tickets:", conn.execute(text("SELECT COUNT(*) FROM tickets")).scalar())
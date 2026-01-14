-- 1) Create a dedicated user for your project
CREATE USER IF NOT EXISTS 'ops_user'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'OpsTracker#2026!';

-- 2) Give it access to your database
GRANT ALL PRIVILEGES ON ops_tracker.* TO 'ops_user'@'localhost';

FLUSH PRIVILEGES;
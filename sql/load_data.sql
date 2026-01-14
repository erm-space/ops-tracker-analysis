/* ============================================================
   02_load_data.sql
   Purpose:
   - Truncate tables
   - Reload data from CSV files
   - Handle NULLs and duplicates
   ============================================================ */

USE ops_tracker;
SET FOREIGN_KEY_CHECKS = 0;

/* =======================
   AGENTS
   ======================= */
TRUNCATE TABLE agents;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agents.csv'
INTO TABLE agents
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(agent_id, full_name, team_id, shift, hire_date, email);

SELECT COUNT(*) AS agents_count FROM agents;


/* =======================
   TEAMS
   ======================= */
TRUNCATE TABLE teams;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/teams.csv'
INTO TABLE teams
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(team_id, team_name);

SELECT COUNT(*) AS teams_count FROM teams;


/* =======================
   PRODUCTS
   ======================= */
TRUNCATE TABLE products;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, tier);

SELECT COUNT(*) AS products_count FROM products;


/* =======================
   CATEGORIES
   ======================= */
TRUNCATE TABLE categories;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(category_id, category_name);

SELECT COUNT(*) AS categories_count FROM categories;


/* =======================
   CHANNELS
   ======================= */
TRUNCATE TABLE channels;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/channels.csv'
INTO TABLE channels
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(channel_id, channel_name);

SELECT COUNT(*) AS channels_count FROM channels;


/* =======================
   PRIORITIES
   ======================= */
TRUNCATE TABLE priorities;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/priorities.csv'
INTO TABLE priorities
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(priority, priority_rank);

SELECT COUNT(*) AS priorities_count FROM priorities;


/* =======================
   SLA TARGETS
   ======================= */
TRUNCATE TABLE sla_targets;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sla_targets.csv'
INTO TABLE sla_targets
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(priority, first_response_minutes, resolution_minutes);

SELECT COUNT(*) AS sla_targets_count FROM sla_targets;


/* =======================
   CUSTOMERS
   ======================= */
TRUNCATE TABLE customers;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
IGNORE
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, full_name, email, phone, city, state, country, plan, created_at);

SELECT COUNT(*) AS customers_count FROM customers;


/* =======================
   TICKETS
   ======================= */
TRUNCATE TABLE tickets;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tickets.csv'
INTO TABLE tickets
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  ticket_id,
  customer_id,
  @agent_id,
  @product_id,
  @category_id,
  @channel_id,
  priority,
  status,
  subject,
  created_at,
  @first_response_at,
  @resolved_at
)
SET
  agent_id          = NULLIF(@agent_id,''),
  product_id        = NULLIF(@product_id,''),
  category_id       = NULLIF(@category_id,''),
  channel_id        = NULLIF(@channel_id,''),
  first_response_at = NULLIF(@first_response_at,''),
  resolved_at       = NULLIF(@resolved_at,'');

SELECT COUNT(*) AS tickets_count FROM tickets;


/* =======================
   TICKET EVENTS
   ======================= */
TRUNCATE TABLE ticket_events;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ticket_events.csv'
INTO TABLE ticket_events
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(event_id, ticket_id, event_type, old_status, new_status, note, created_at);

SELECT COUNT(*) AS ticket_events_count FROM ticket_events;


/* =======================
   TICKET TAGS
   ======================= */
TRUNCATE TABLE ticket_tags;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ticket_tags.csv'
INTO TABLE ticket_tags
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(tag_id, tag_name);

SELECT COUNT(*) AS ticket_tags_count FROM ticket_tags;


/* =======================
   TICKET TAG MAP
   ======================= */
TRUNCATE TABLE ticket_tag_map;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ticket_tag_map.csv'
IGNORE
INTO TABLE ticket_tag_map
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ticket_tag_map_id, ticket_id, tag_id);

SELECT COUNT(*) AS ticket_tag_map_count FROM ticket_tag_map;


/* =======================
   CSAT SURVEYS
   ======================= */
TRUNCATE TABLE csat_surveys;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/csat_surveys.csv'
INTO TABLE csat_surveys
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  csat_id,
  ticket_id,
  customer_id,
  @agent_id,
  @rating,
  comment,
  @submitted_at
)
SET
  agent_id     = NULLIF(@agent_id,''),
  rating       = NULLIF(@rating,''),
  submitted_at = NULLIF(@submitted_at,'');

SELECT COUNT(*) AS csat_surveys_count FROM csat_surveys;

SET FOREIGN_KEY_CHECKS = 1;

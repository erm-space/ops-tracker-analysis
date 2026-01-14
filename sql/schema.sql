CREATE DATABASE IF NOT EXISTS ops_tracker;
USE ops_tracker;

CREATE TABLE IF NOT EXISTS teams (
  team_id INT PRIMARY KEY,
  team_name VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS agents (
  agent_id INT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  team_id INT NOT NULL,
  shift VARCHAR(20) NOT NULL,
  hire_date DATE NOT NULL,
  INDEX idx_agents_team(team_id),
  CONSTRAINT fk_agents_team FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE IF NOT EXISTS products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(80) NOT NULL,
  tier VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
  category_id INT PRIMARY KEY,
  category_name VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS channels (
  channel_id INT PRIMARY KEY,
  channel_name VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS priorities (
  priority VARCHAR(10) PRIMARY KEY,
  priority_rank INT NOT NULL
);

CREATE TABLE IF NOT EXISTS sla_targets (
  priority VARCHAR(10) PRIMARY KEY,
  first_response_minutes INT NOT NULL,
  resolution_minutes INT NOT NULL,
  CONSTRAINT fk_sla_priority FOREIGN KEY (priority) REFERENCES priorities(priority)
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state VARCHAR(10) NOT NULL,
  country VARCHAR(40) NOT NULL,
  plan VARCHAR(20) NOT NULL,
  created_at DATETIME NOT NULL,
  UNIQUE KEY uq_customers_email(email)
);

CREATE TABLE IF NOT EXISTS tickets (
  ticket_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  agent_id INT NULL,
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  channel_id INT NOT NULL,
  priority VARCHAR(10) NOT NULL,
  status VARCHAR(10) NOT NULL,
  subject VARCHAR(220) NOT NULL,
  created_at DATETIME NOT NULL,
  first_response_at DATETIME NULL,
  resolved_at DATETIME NULL,
  INDEX idx_tickets_created(created_at),
  INDEX idx_tickets_agent(agent_id),
  INDEX idx_tickets_status(status),
  INDEX idx_tickets_priority(priority),
  CONSTRAINT fk_tickets_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_tickets_agent FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
  CONSTRAINT fk_tickets_product FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_tickets_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
  CONSTRAINT fk_tickets_channel FOREIGN KEY (channel_id) REFERENCES channels(channel_id),
  CONSTRAINT fk_tickets_priority FOREIGN KEY (priority) REFERENCES priorities(priority)
);

CREATE TABLE IF NOT EXISTS ticket_events (
  event_id INT PRIMARY KEY,
  ticket_id INT NOT NULL,
  event_type VARCHAR(20) NOT NULL,
  old_status VARCHAR(10) NULL,
  new_status VARCHAR(10) NULL,
  note VARCHAR(255) NULL,
  created_at DATETIME NOT NULL,
  INDEX idx_events_ticket(ticket_id),
  INDEX idx_events_created(created_at),
  CONSTRAINT fk_events_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

CREATE TABLE IF NOT EXISTS ticket_tags (
  tag_id INT PRIMARY KEY,
  tag_name VARCHAR(40) NOT NULL,
  UNIQUE KEY uq_tag_name(tag_name)
);

CREATE TABLE IF NOT EXISTS ticket_tag_map (
  ticket_tag_map_id INT PRIMARY KEY,
  ticket_id INT NOT NULL,
  tag_id INT NOT NULL,
  UNIQUE KEY uq_ticket_tag(ticket_id, tag_id),
  INDEX idx_tag_map_ticket(ticket_id),
  CONSTRAINT fk_tag_map_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
  CONSTRAINT fk_tag_map_tag FOREIGN KEY (tag_id) REFERENCES ticket_tags(tag_id)
);

CREATE TABLE IF NOT EXISTS csat_surveys (
  csat_id INT PRIMARY KEY,
  ticket_id INT NOT NULL,
  customer_id INT NOT NULL,
  agent_id INT NOT NULL,
  rating TINYINT NOT NULL,
  comment VARCHAR(255) NULL,
  submitted_at DATETIME NOT NULL,
  INDEX idx_csat_ticket(ticket_id),
  CONSTRAINT fk_csat_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
  CONSTRAINT fk_csat_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

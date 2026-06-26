CREATE DATABASE IF NOT EXISTS smart_grid_db;
USE smart_grid_db;

-- 1. Users
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL -- 'ADMIN' or 'OPERATOR'
);

-- 2. Grid Nodes
CREATE TABLE IF NOT EXISTS grid_nodes (
    node_id INT PRIMARY KEY AUTO_INCREMENT,
    node_name VARCHAR(100) NOT NULL,
    zone VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'ACTIVE', 'FAULT', 'OVERLOADED'
    capacity_kw DOUBLE NOT NULL
);

-- 3. Consumers
CREATE TABLE IF NOT EXISTS consumers (
    consumer_id INT PRIMARY KEY AUTO_INCREMENT,
    consumer_name VARCHAR(100) NOT NULL,
    meter_id INT UNIQUE NOT NULL,
    node_id INT,
    address VARCHAR(255),
    FOREIGN KEY (node_id) REFERENCES grid_nodes(node_id) ON DELETE SET NULL
);

-- 4. Power Readings
CREATE TABLE IF NOT EXISTS power_readings (
    reading_id INT PRIMARY KEY AUTO_INCREMENT,
    node_id INT,
    voltage DOUBLE NOT NULL,
    current_draw DOUBLE NOT NULL,
    power_kw DOUBLE NOT NULL,
    reading_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (node_id) REFERENCES grid_nodes(node_id) ON DELETE CASCADE
);

-- 5. Fault Records
CREATE TABLE IF NOT EXISTS fault_records (
    fault_id INT PRIMARY KEY AUTO_INCREMENT,
    node_id INT,
    fault_type VARCHAR(50) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL, -- 'OPEN', 'RESOLVED'
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (node_id) REFERENCES grid_nodes(node_id) ON DELETE CASCADE
);

-- 6. Outage Records
CREATE TABLE IF NOT EXISTS outage_records (
    outage_id INT PRIMARY KEY AUTO_INCREMENT,
    node_id INT,
    outage_type VARCHAR(20) NOT NULL, -- 'PLANNED', 'UNPLANNED'
    description TEXT,
    status VARCHAR(20) NOT NULL, -- 'ACTIVE', 'RESTORED'
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    restored_at TIMESTAMP NULL,
    FOREIGN KEY (node_id) REFERENCES grid_nodes(node_id) ON DELETE CASCADE
);

-- 7. Consumption History
CREATE TABLE IF NOT EXISTS consumption_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    consumer_id INT,
    kwh_consumed DOUBLE NOT NULL,
    reading_date DATE NOT NULL,
    FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id) ON DELETE CASCADE
);

-- Populate initial roles & nodes
INSERT INTO users (username, password, role) VALUES 
('admin', 'admin123', 'ADMIN'),
('operator', 'operator123', 'OPERATOR')
ON DUPLICATE KEY UPDATE username=username;

INSERT INTO grid_nodes (node_name, zone, status, capacity_kw) VALUES 
('Substation Alpha', 'Zone A', 'ACTIVE', 500.0),
('Substation Beta', 'Zone B', 'ACTIVE', 450.0),
('Substation Gamma', 'Zone C', 'FAULT', 300.0)
ON DUPLICATE KEY UPDATE node_name=node_name;

INSERT INTO consumers (consumer_name, meter_id, node_id, address) VALUES
('John Doe', 1001, 1, '123 Main St'),
('Alice Smith', 1002, 1, '456 Elm St'),
('Bob Johnson', 1003, 2, '789 Oak St')
ON DUPLICATE KEY UPDATE meter_id=meter_id;

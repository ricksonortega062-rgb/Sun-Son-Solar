-- =====================================================================
-- Sun Son Solar — database
-- Engine: MySQL / MariaDB (works with CodeIgniter)
-- Founder: Katherine Singaraw | Office: Pasig City
-- =====================================================================

CREATE DATABASE IF NOT EXISTS sun_son_solar
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sun_son_solar;

-- Drop in reverse dependency order so the script can be re-run
DROP TABLE IF EXISTS time_logs;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS users;

-- ---------------------------------------------------------------------
-- USERS  (customers, employees and admins all live here)
-- Every user has a primary key: user_id
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username       VARCHAR(50)  NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,              -- bcrypt hash, never plain text
    role           ENUM('customer','employee','admin') NOT NULL DEFAULT 'customer',
    first_name     VARCHAR(60)  NOT NULL,
    last_name      VARCHAR(60)  NOT NULL,
    middle_name    VARCHAR(60)  NULL,
    birthdate      DATE         NULL,
    gender         ENUM('Female','Male','Other') NULL,
    email          VARCHAR(120) NULL,
    phone          VARCHAR(30)  NULL,
    address        VARCHAR(255) NULL,
    is_active      TINYINT(1)   NOT NULL DEFAULT 1,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_username (username),
    UNIQUE KEY uq_users_email (email),
    CONSTRAINT chk_username_len CHECK (CHAR_LENGTH(username) >= 5)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- EMPLOYEES  (extra details for users with role employee/admin)
-- ---------------------------------------------------------------------
CREATE TABLE employees (
    employee_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id     INT UNSIGNED NOT NULL,
    department  ENUM('Field Operations - Technician','Dispatch','IT','Sales','Administration') NOT NULL,
    PRIMARY KEY (employee_id),
    UNIQUE KEY uq_employees_user (user_id),
    CONSTRAINT fk_employees_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- TIME LOGS  (the one-tap "Time In" button: name, time, coordinates)
-- full_name is a snapshot so the log stays readable if a name changes
-- ---------------------------------------------------------------------
CREATE TABLE time_logs (
    log_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    INT UNSIGNED NOT NULL,
    full_name  VARCHAR(150) NOT NULL,
    time_in    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    latitude   DECIMAL(10,7) NOT NULL,
    longitude  DECIMAL(10,7) NOT NULL,
    PRIMARY KEY (log_id),
    KEY idx_timelogs_user_time (user_id, time_in),
    CONSTRAINT fk_timelogs_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_lat CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_lng CHECK (longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PRODUCT CATEGORIES + PRODUCTS  (customers can easily browse products)
-- ---------------------------------------------------------------------
CREATE TABLE product_categories (
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name        VARCHAR(80) NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_category_name (name)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_id  INT UNSIGNED NOT NULL,
    name         VARCHAR(150) NOT NULL,
    description  TEXT NULL,
    price        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    stock        INT UNSIGNED NOT NULL DEFAULT 0,
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    KEY idx_products_category (category_id),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES product_categories (category_id) ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- SERVICES
-- ---------------------------------------------------------------------
CREATE TABLE services (
    service_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    description TEXT NULL,
    PRIMARY KEY (service_id),
    UNIQUE KEY uq_service_name (name)
) ENGINE=InnoDB;

-- =====================================================================
-- SEED DATA
-- =====================================================================

INSERT INTO product_categories (name) VALUES
    ('Solar Panels'),
    ('Inverters'),
    ('Batteries'),
    ('Racking and Mounting'),
    ('Wires and Cables');

INSERT INTO services (name, description) VALUES
    ('Designing',    'Custom solar system design for your home or business.'),
    ('Permitting',   'We handle the permits and paperwork.'),
    ('Installation', 'Professional installation by our field technicians.'),
    ('Maintenance',  'Scheduled maintenance to keep your system performing.'),
    ('Repair',       'Diagnosis and repair of solar system issues.'),
    ('Monitoring',   'Remote monitoring of your system''s performance.');

-- First registered users (passwords stored as bcrypt hashes)
--   KittyKat16 / K@tSunshine16   -> Katherine Singaraw, founder (admin)
--   admin      / admin123        -> Sol Solis, IT head (admin) — change after handover
-- Details not provided yet (birthdate, gender, email, phone, address) are left NULL.
INSERT INTO users (username, password_hash, role, first_name, last_name) VALUES
    ('KittyKat16', '$2y$10$cGD6tUNc4Fw6Ls2IIOsqH.pSqrAFayED8nUdM6BaxEDIdAuRHpQWW', 'admin', 'Katherine', 'Singaraw'),
    ('admin',      '$2y$10$iRntCC1Xfa6QwvjvtaNngulRmvXfsqE3.aHmQLU/auAzJJ6Kyv97W', 'admin', 'Sol',       'Solis');

INSERT INTO employees (user_id, department)
SELECT user_id, 'Administration' FROM users WHERE username = 'KittyKat16';

INSERT INTO employees (user_id, department)
SELECT user_id, 'IT' FROM users WHERE username = 'admin';

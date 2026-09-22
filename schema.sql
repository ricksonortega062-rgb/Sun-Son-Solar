-- ============================================================
-- Sun Son Solar — users table (reference schema)
-- Not set up for you — run this yourself in phpMyAdmin against
-- an empty `sunson_solar` database when you're ready.
-- ============================================================

CREATE DATABASE IF NOT EXISTS sunson_solar CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE sunson_solar;

-- One table for customers AND employees, told apart by `role`.
-- user_id is the required primary key.
CREATE TABLE users (
	user_id      INT AUTO_INCREMENT PRIMARY KEY,
	role         ENUM('customer','employee','admin') NOT NULL,
	department   VARCHAR(50) NULL,              -- employees & admins only
	first_name   VARCHAR(80)  NOT NULL,
	last_name    VARCHAR(80)  NOT NULL,
	middle_name  VARCHAR(80)  NULL,
	birthdate    DATE NOT NULL,
	gender       ENUM('Male','Female','Other') NOT NULL,
	email        VARCHAR(150) NOT NULL UNIQUE,
	phone        VARCHAR(30)  NOT NULL,
	address      VARCHAR(255) NOT NULL,
	username     VARCHAR(50)  NOT NULL UNIQUE,
	password     VARCHAR(255) NOT NULL,          -- always store via PHP password_hash()
	created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

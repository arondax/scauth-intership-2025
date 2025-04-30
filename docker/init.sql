-- USERS table
CREATE TABLE users (
  email VARCHAR(255) PRIMARY KEY,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  role VARCHAR(20) DEFAULT 'user'  -- possible values: 'admin', 'user'
);

-- CREDENTIALS table for WebAuthn (e.g., smartcards)
CREATE TABLE webauthn_credentials (
  id SERIAL PRIMARY KEY,
  user_email VARCHAR(255) REFERENCES users(email),
  credential_id TEXT UNIQUE NOT NULL,
  public_key TEXT NOT NULL,
  device_type VARCHAR(50),       -- e.g., 'smartcard', 'security_key'
  origin TEXT,
  sign_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- GLOBAL SYSTEM CONFIGURATION table
CREATE TABLE system_configuration (
  id SERIAL PRIMARY KEY,
  last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  access_type VARCHAR(50) NOT NULL -- e.g., 'smartcard', 'password', '2FA'
);
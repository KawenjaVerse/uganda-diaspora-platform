-- Uganda Diaspora Platform — Full Schema
-- Run with: psql "postgresql://diaspora:PASSWORD@localhost:5432/uganda_diaspora" -f /opt/uganda-diaspora/deploy/schema.sql

CREATE TABLE IF NOT EXISTS users (
  id              SERIAL PRIMARY KEY,
  email           TEXT NOT NULL UNIQUE,
  password_hash   TEXT NOT NULL,
  full_name       TEXT NOT NULL,
  role            TEXT NOT NULL DEFAULT 'member',
  country         TEXT,
  profession      TEXT,
  bio             TEXT,
  avatar_url      TEXT,
  is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS news_categories (
  id    SERIAL PRIMARY KEY,
  name  TEXT NOT NULL,
  slug  TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS news (
  id           SERIAL PRIMARY KEY,
  title        TEXT NOT NULL,
  content      TEXT NOT NULL,
  summary      TEXT,
  category     TEXT NOT NULL DEFAULT 'general',
  image_url    TEXT,
  is_featured  BOOLEAN NOT NULL DEFAULT FALSE,
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  author_name  TEXT,
  view_count   INTEGER NOT NULL DEFAULT 0,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  published_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS embassies (
  id                   SERIAL PRIMARY KEY,
  country              TEXT NOT NULL,
  city                 TEXT NOT NULL,
  continent            TEXT,
  region               TEXT,
  address              TEXT,
  phone                TEXT,
  email                TEXT,
  website              TEXT,
  image_url            TEXT,
  flag_url             TEXT,
  ambassador_name      TEXT,
  ambassador_image_url TEXT,
  office_hours         TEXT,
  services_offered     TEXT,
  emergency_contact    TEXT,
  latitude             REAL,
  longitude            REAL,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mdas (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT,
  logo_url    TEXT,
  website     TEXT,
  category    TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tourism_attractions (
  id             SERIAL PRIMARY KEY,
  name           TEXT NOT NULL,
  description    TEXT,
  category       TEXT NOT NULL DEFAULT 'attraction',
  location       TEXT,
  image_url      TEXT,
  gallery        TEXT,
  latitude       REAL,
  longitude      REAL,
  entry_fee      TEXT,
  opening_hours  TEXT,
  contact_phone  TEXT,
  website        TEXT,
  is_featured    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS webinars (
  id                  SERIAL PRIMARY KEY,
  title               TEXT NOT NULL,
  description         TEXT,
  youtube_url         TEXT,
  thumbnail_url       TEXT,
  category            TEXT,
  speaker_name        TEXT,
  scheduled_at        TIMESTAMP,
  is_live             BOOLEAN NOT NULL DEFAULT FALSE,
  is_published        BOOLEAN NOT NULL DEFAULT TRUE,
  view_count          INTEGER NOT NULL DEFAULT 0,
  registration_count  INTEGER NOT NULL DEFAULT 0,
  created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id                 SERIAL PRIMARY KEY,
  title              TEXT NOT NULL,
  description        TEXT,
  location           TEXT,
  image_url          TEXT,
  category           TEXT,
  start_date         TIMESTAMP NOT NULL,
  end_date           TIMESTAMP,
  registration_url   TEXT,
  is_virtual         BOOLEAN NOT NULL DEFAULT FALSE,
  is_published       BOOLEAN NOT NULL DEFAULT TRUE,
  registration_count INTEGER NOT NULL DEFAULT 0,
  created_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS posts (
  id                SERIAL PRIMARY KEY,
  content           TEXT NOT NULL,
  image_url         TEXT,
  author_name       TEXT NOT NULL DEFAULT 'Anonymous',
  author_avatar_url TEXT,
  like_count        INTEGER NOT NULL DEFAULT 0,
  comment_count     INTEGER NOT NULL DEFAULT 0,
  is_moderated      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comments (
  id                SERIAL PRIMARY KEY,
  post_id           INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  content           TEXT NOT NULL,
  author_name       TEXT NOT NULL DEFAULT 'Anonymous',
  author_avatar_url TEXT,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
  id         SERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  type       TEXT,
  audience   TEXT,
  sent_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS opportunities (
  id               SERIAL PRIMARY KEY,
  title            TEXT NOT NULL,
  description      TEXT,
  type             TEXT NOT NULL DEFAULT 'job',
  organization     TEXT,
  location         TEXT,
  deadline         TEXT,
  application_url  TEXT,
  image_url        TEXT,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS diaspora_registrations (
  id                   SERIAL PRIMARY KEY,
  full_name            TEXT NOT NULL,
  date_of_birth        TEXT,
  gender               TEXT,
  national_id          TEXT,
  country              TEXT,
  city                 TEXT,
  phone                TEXT,
  email                TEXT,
  profession           TEXT,
  years_abroad         TEXT,
  reason_for_diaspora  TEXT,
  created_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  email      TEXT NOT NULL,
  subject    TEXT,
  message    TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'unread',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS activity_log (
  id          SERIAL PRIMARY KEY,
  type        TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Default admin user (password: Admin@2024!)
INSERT INTO users (email, password_hash, full_name, role, is_verified, is_active)
VALUES (
  'admin@ugandadiaspora.go.ug',
  '451d839d59acbabbd596a56d54a62d3d71a7662845bde3cc50ab7b55f101ff3b',
  'Platform Administrator',
  'admin',
  TRUE,
  TRUE
)
ON CONFLICT (email) DO NOTHING;

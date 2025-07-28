-- Event Planning Application: PostgreSQL Schema & Seed Data

-- =========================
-- USERS TABLE
-- =========================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'attendee', -- attendee, organizer, admin
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- EVENTS TABLE
-- =========================
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    organizer_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    location VARCHAR(200),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- scheduled, ongoing, completed, cancelled
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- SCHEDULES TABLE
-- =========================
CREATE TABLE schedules (
    schedule_id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    item_title VARCHAR(100) NOT NULL,
    item_description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL
);

-- =========================
-- ATTENDEES TABLE
-- =========================
CREATE TABLE attendees (
    attendee_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    event_id INTEGER NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    rsvp_status VARCHAR(20) NOT NULL DEFAULT 'pending', -- going, interested, not_going, pending
    checkin_time TIMESTAMP,
    UNIQUE(user_id, event_id)
);

-- =========================
-- RESOURCES TABLE
-- =========================
CREATE TABLE resources (
    resource_id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    resource_name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50), -- e.g. projector, room, catering
    allocated_to INTEGER REFERENCES schedules(schedule_id),
    description TEXT
);

-- =========================
-- NOTIFICATIONS TABLE
-- =========================
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    event_id INTEGER REFERENCES events(event_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    read_status BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- EVENT TAGS TABLE (supporting)
-- =========================
CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE event_tags (
    event_id INTEGER NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY(event_id, tag_id)
);

-- =========================
-- AUDIT LOG TABLE (supporting)
-- =========================
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- =========================
-- INITIAL SEED DATA
-- =========================

-- Users: admin/organizer/demo attendee
INSERT INTO users (username, email, password_hash, full_name, role, is_active)
VALUES
('adminuser', 'admin@eventsuite.com', 'hashed_pw_admin', 'Admin User', 'admin', TRUE),
('organizer1', 'organizer1@eventsuite.com', 'hashed_pw_org1', 'Organizer One', 'organizer', TRUE),
('johndoe', 'john@doe.com', 'hashed_pw_att1', 'John Doe', 'attendee', TRUE);

-- Events
INSERT INTO events (title, description, organizer_id, location, start_time, end_time, status)
VALUES
('Annual Tech Summit', 'A summit for tech enthusiasts and professionals.', 2, 'Tech Hall A', '2024-12-01 09:00:00', '2024-12-01 17:00:00', 'scheduled'),
('Marketing Strategy Workshop', 'Workshop on modern marketing strategies.', 2, 'Conference Room 2', '2024-12-03 13:00:00', '2024-12-03 16:00:00', 'scheduled');

-- Schedules
INSERT INTO schedules (event_id, item_title, item_description, start_time, end_time)
VALUES
(1, 'Registration', 'Attendee check-in and badge pickup.', '2024-12-01 09:00:00', '2024-12-01 10:00:00'),
(1, 'Keynote', 'Keynote address by leading tech innovator.', '2024-12-01 10:00:00', '2024-12-01 11:00:00'),
(2, 'Welcome', 'Greetings and agenda overview.', '2024-12-03 13:00:00', '2024-12-03 13:30:00');

-- Attendees
INSERT INTO attendees (user_id, event_id, rsvp_status)
VALUES
(3, 1, 'going'),
(3, 2, 'interested');

-- Resources
INSERT INTO resources (event_id, resource_name, resource_type, description)
VALUES
(1, 'Main Projector', 'projector', 'High-res projector for presentations'),
(1, 'Coffee Service', 'catering', 'Complimentary coffee and pastries'),
(2, 'Breakout Room 1', 'room', 'For group sessions');

-- Tags & Event Tags
INSERT INTO tags (tag_name) VALUES ('Technology'), ('Networking'), ('Workshop');

INSERT INTO event_tags (event_id, tag_id)
VALUES (1, 1), (1, 2), (2, 3);

-- Notifications
INSERT INTO notifications (user_id, event_id, message, read_status)
VALUES
(3, 1, 'Welcome to the Annual Tech Summit!', FALSE),
(3, 2, 'You have RSVP\'d as Interested for the Marketing Strategy Workshop.', FALSE);

-- ==========================
-- Indexes for performance
-- ==========================
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_attendees_event_id ON attendees(event_id);
CREATE INDEX idx_attendees_user_id ON attendees(user_id);
CREATE INDEX idx_schedules_event_id ON schedules(event_id);
CREATE INDEX idx_resources_event_id ON resources(event_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_event_id ON notifications(event_id);

-- ==========================
-- End of Schema
-- ==========================

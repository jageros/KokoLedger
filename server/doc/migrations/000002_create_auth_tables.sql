-- +goose Up
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nickname text NOT NULL,
    avatar_url text,
    email text,
    phone text,
    password_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_nickname_not_blank CHECK (length(btrim(nickname)) > 0),
    CONSTRAINT users_email_or_phone_required CHECK (email IS NOT NULL OR phone IS NOT NULL),
    CONSTRAINT users_email_not_blank CHECK (email IS NULL OR length(btrim(email)) > 0),
    CONSTRAINT users_phone_not_blank CHECK (phone IS NULL OR length(btrim(phone)) > 0),
    CONSTRAINT users_password_hash_not_blank CHECK (length(btrim(password_hash)) > 0)
);

CREATE UNIQUE INDEX users_email_lower_unique_idx
    ON users (lower(email))
    WHERE email IS NOT NULL;

CREATE UNIQUE INDEX users_phone_unique_idx
    ON users (phone)
    WHERE phone IS NOT NULL;

CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TABLE auth_sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash text NOT NULL,
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    last_used_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT auth_sessions_token_hash_not_blank CHECK (length(btrim(token_hash)) > 0),
    CONSTRAINT auth_sessions_expires_after_created CHECK (expires_at > created_at)
);

CREATE UNIQUE INDEX auth_sessions_token_hash_unique_idx
    ON auth_sessions (token_hash);

CREATE INDEX auth_sessions_user_active_idx
    ON auth_sessions (user_id, expires_at)
    WHERE revoked_at IS NULL;

-- +goose Down
DROP TABLE IF EXISTS auth_sessions;
DROP TRIGGER IF EXISTS users_set_updated_at ON users;
DROP TABLE IF EXISTS users;

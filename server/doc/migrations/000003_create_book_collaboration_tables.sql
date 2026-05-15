-- +goose Up
CREATE TABLE books (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    note text,
    default_currency_code varchar(3) NOT NULL DEFAULT 'CNY',
    owner_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    archived_at timestamptz,
    CONSTRAINT books_name_length CHECK (length(btrim(name)) BETWEEN 1 AND 40),
    CONSTRAINT books_default_currency_code_length CHECK (length(default_currency_code) = 3)
);

CREATE INDEX books_owner_active_idx
    ON books (owner_id, updated_at DESC)
    WHERE archived_at IS NULL;

CREATE TRIGGER books_set_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TABLE book_members (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role text NOT NULL,
    joined_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT book_members_role_check CHECK (role IN ('readonly', 'editor')),
    CONSTRAINT book_members_book_user_unique UNIQUE (book_id, user_id)
);

CREATE INDEX book_members_user_idx
    ON book_members (user_id);

CREATE TABLE book_invites (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    invite_code text NOT NULL,
    invite_link text,
    invited_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    role text NOT NULL,
    status text NOT NULL DEFAULT 'pending',
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    accepted_at timestamptz,
    CONSTRAINT book_invites_invite_code_not_blank CHECK (length(btrim(invite_code)) > 0),
    CONSTRAINT book_invites_role_check CHECK (role IN ('readonly', 'editor')),
    CONSTRAINT book_invites_status_check CHECK (status IN ('pending', 'joined', 'expired', 'revoked')),
    CONSTRAINT book_invites_expires_after_created CHECK (expires_at > created_at)
);

CREATE UNIQUE INDEX book_invites_invite_code_unique_idx
    ON book_invites (invite_code);

CREATE INDEX book_invites_book_status_idx
    ON book_invites (book_id, status, expires_at DESC);

CREATE INDEX book_invites_invited_by_user_idx
    ON book_invites (invited_by_user_id);

-- +goose Down
DROP TABLE IF EXISTS book_invites;
DROP TABLE IF EXISTS book_members;
DROP TRIGGER IF EXISTS books_set_updated_at ON books;
DROP TABLE IF EXISTS books;

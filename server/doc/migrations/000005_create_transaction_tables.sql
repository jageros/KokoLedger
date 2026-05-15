-- +goose Up
CREATE TABLE ledger_transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    type text NOT NULL,
    amount_minor bigint NOT NULL,
    currency_code varchar(3) NOT NULL DEFAULT 'CNY',
    category_level1_id uuid NOT NULL,
    category_level2_id uuid NOT NULL,
    occurred_at timestamptz NOT NULL,
    note text,
    created_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,
    CONSTRAINT ledger_transactions_type_check CHECK (type IN ('income', 'expense')),
    CONSTRAINT ledger_transactions_amount_positive CHECK (amount_minor > 0),
    CONSTRAINT ledger_transactions_currency_code_length CHECK (length(currency_code) = 3),
    CONSTRAINT ledger_transactions_distinct_categories CHECK (category_level1_id <> category_level2_id),
    CONSTRAINT ledger_transactions_level1_category_fk
        FOREIGN KEY (category_level1_id, book_id, type)
        REFERENCES transaction_categories(id, book_id, type)
        ON DELETE RESTRICT,
    CONSTRAINT ledger_transactions_level2_category_fk
        FOREIGN KEY (category_level2_id, book_id, type)
        REFERENCES transaction_categories(id, book_id, type)
        ON DELETE RESTRICT
);

CREATE INDEX ledger_transactions_book_occurred_at_idx
    ON ledger_transactions (book_id, occurred_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX ledger_transactions_book_type_occurred_at_idx
    ON ledger_transactions (book_id, type, occurred_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX ledger_transactions_category_level1_idx
    ON ledger_transactions (book_id, category_level1_id, occurred_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX ledger_transactions_category_level2_idx
    ON ledger_transactions (book_id, category_level2_id, occurred_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX ledger_transactions_created_by_idx
    ON ledger_transactions (created_by, occurred_at DESC)
    WHERE deleted_at IS NULL;

CREATE TRIGGER ledger_transactions_set_updated_at
    BEFORE UPDATE ON ledger_transactions
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- +goose Down
DROP TRIGGER IF EXISTS ledger_transactions_set_updated_at ON ledger_transactions;
DROP TABLE IF EXISTS ledger_transactions;

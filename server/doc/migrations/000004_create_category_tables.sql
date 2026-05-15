-- +goose Up
CREATE TABLE transaction_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    name text NOT NULL,
    type text NOT NULL,
    level text NOT NULL,
    parent_id uuid,
    icon text,
    color_hex text,
    sort_order integer NOT NULL DEFAULT 0,
    is_archived boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT transaction_categories_name_length CHECK (length(btrim(name)) BETWEEN 1 AND 20),
    CONSTRAINT transaction_categories_type_check CHECK (type IN ('income', 'expense')),
    CONSTRAINT transaction_categories_level_check CHECK (level IN ('level1', 'level2')),
    CONSTRAINT transaction_categories_parent_level_check CHECK (
        (level = 'level1' AND parent_id IS NULL)
        OR (level = 'level2' AND parent_id IS NOT NULL)
    ),
    CONSTRAINT transaction_categories_sort_order_non_negative CHECK (sort_order >= 0),
    CONSTRAINT transaction_categories_not_self_parent CHECK (parent_id IS NULL OR parent_id <> id),
    CONSTRAINT transaction_categories_identity_for_fk UNIQUE (id, book_id, type)
);

ALTER TABLE transaction_categories
    ADD CONSTRAINT transaction_categories_parent_fk
    FOREIGN KEY (parent_id, book_id, type)
    REFERENCES transaction_categories(id, book_id, type)
    ON DELETE RESTRICT;

CREATE INDEX transaction_categories_book_type_archived_idx
    ON transaction_categories (book_id, type, is_archived, level, sort_order);

CREATE INDEX transaction_categories_parent_idx
    ON transaction_categories (parent_id, sort_order)
    WHERE parent_id IS NOT NULL;

CREATE TRIGGER transaction_categories_set_updated_at
    BEFORE UPDATE ON transaction_categories
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- +goose Down
DROP TRIGGER IF EXISTS transaction_categories_set_updated_at ON transaction_categories;
DROP TABLE IF EXISTS transaction_categories;

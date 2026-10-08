BEGIN;

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- SCHEMA
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS matching;

-- ============================================================================
-- MERCHANTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.merchants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,
    normalized_name TEXT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_merchants_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_merchants_normalized_name
    ON matching.merchants(normalized_name);

-- ============================================================================
-- CATEGORIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,
    
    normalized_name TEXT NOT NULL,

    firefly_id VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_categories_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_categories_normalized_name
    ON matching.categories(normalized_name);

-- ============================================================================
-- BUDGETS
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,
    normalized_name TEXT NOT NULL,

    firefly_id VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_budgets_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_budgets_normalized_name
    ON matching.budgets(normalized_name);

-- ============================================================================
-- TAGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,
    normalized_name TEXT NOT NULL,

    firefly_id VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_tags_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_tags_normalized_name
    ON matching.tags(normalized_name);

-- ============================================================================
-- CLASSIFICATION EXAMPLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.classification_examples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    description TEXT NOT NULL,
    normalized_description TEXT NOT NULL,

    raw_transaction JSONB,

    amount NUMERIC(18,2),

    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',

    iban VARCHAR(100),

    merchant_id UUID
        REFERENCES matching.merchants(id),

    merchant_name_snapshot TEXT,

    category_id UUID
        REFERENCES matching.categories(id),

    budget_id UUID
        REFERENCES matching.budgets(id),

    source VARCHAR(20) NOT NULL
        CHECK (
            source IN (
                'ai',
                'manual',
                'imported'
            )
        ),

    confidence NUMERIC(5,4) NOT NULL DEFAULT 1.0000
        CHECK (
            confidence >= 0
            AND confidence <= 1
        ),

    usage_count INTEGER NOT NULL DEFAULT 0,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    embedding VECTOR(384),

    embedding_model VARCHAR(100) NOT NULL
        DEFAULT 'all-MiniLM-L6-v2',

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_classification_examples_merchant
    ON matching.classification_examples(merchant_id);

CREATE INDEX IF NOT EXISTS idx_classification_examples_category
    ON matching.classification_examples(category_id);

CREATE INDEX IF NOT EXISTS idx_classification_examples_budget
    ON matching.classification_examples(budget_id);

CREATE INDEX IF NOT EXISTS idx_classification_examples_normalized_description
    ON matching.classification_examples(normalized_description);

CREATE INDEX IF NOT EXISTS idx_classification_examples_description_trgm
    ON matching.classification_examples
    USING gin (normalized_description gin_trgm_ops);

-- ============================================================================
-- VECTOR INDEX
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_classification_examples_embedding
    ON matching.classification_examples
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- ============================================================================
-- EXAMPLE TAGS (M:N)
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.classification_example_tags (
    classification_example_id UUID NOT NULL
        REFERENCES matching.classification_examples(id)
        ON DELETE CASCADE,

    tag_id UUID NOT NULL
        REFERENCES matching.tags(id)
        ON DELETE CASCADE,

    PRIMARY KEY (
        classification_example_id,
        tag_id
    )
);

CREATE INDEX IF NOT EXISTS idx_classification_example_tags_tag
    ON matching.classification_example_tags(tag_id);

-- ============================================================================
-- IMPORTED TRANSACTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.imported_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    transaction_hash VARCHAR(128) NOT NULL,

    external_id VARCHAR(255),

    firefly_transaction_id VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_imported_transactions_hash
        UNIQUE (transaction_hash)
);

CREATE INDEX IF NOT EXISTS idx_imported_transactions_external_id
    ON matching.imported_transactions(external_id);

-- ============================================================================
-- AI CLASSIFICATION LOG
-- ============================================================================

CREATE TABLE IF NOT EXISTS matching.ai_classification_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    description TEXT NOT NULL,

    merchant TEXT,
    category TEXT,
    budget TEXT,

    tags JSONB,

    model_name TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);



ALTER TABLE matching.classification_examples
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

ALTER TABLE matching.tags
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

ALTER TABLE matching.budgets
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

ALTER TABLE matching.categories
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

ALTER TABLE matching.merchants
ALTER COLUMN id
SET DEFAULT gen_random_uuid();

-- recommended ANN index for the 384-d cosine search:
CREATE INDEX ON matching.classification_examples
  USING hnsw (embedding vector_cosine_ops);

COMMIT;
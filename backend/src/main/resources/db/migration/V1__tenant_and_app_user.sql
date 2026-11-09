CREATE TABLE tenant (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app_user (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id      uuid        NOT NULL REFERENCES tenant (id),
    email          text        NOT NULL,
    password_hash  text        NOT NULL,
    role           text        NOT NULL CHECK (role IN ('OWNER', 'ACCOUNTANT', 'VIEWER')),
    created_at     timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, email)
);

CREATE INDEX idx_app_user_tenant ON app_user (tenant_id);

ALTER TABLE tenant   ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_user ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON tenant
    USING (id = current_setting('app.current_tenant', true)::uuid);

CREATE POLICY tenant_isolation ON app_user
    USING      (tenant_id = current_setting('app.current_tenant', true)::uuid)
    WITH CHECK (tenant_id = current_setting('app.current_tenant', true)::uuid); 
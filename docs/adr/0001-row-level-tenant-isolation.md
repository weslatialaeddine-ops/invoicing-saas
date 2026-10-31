# 1. Row-level tenant isolation with PostgreSQL RLS

Date: 2026-10-31
Status: Accepted

## Context

The invoicing platform is multi-tenant: many companies share one
application and one database. Each company's data (clients, invoices,
payments) must never be visible to another company. A leak between
tenants would be the most serious bug this product can have, so the
isolation strategy must be both safe and practical to operate.

Options considered:

1. **Row-level**: shared schema, a `tenant_id` column on every
   tenant-owned table.
2. **Schema-per-tenant**: one PostgreSQL schema per company.
3. **Database-per-tenant**: one database per company.

## Decision

We use **row-level isolation**: every tenant-owned table has a non-null
`tenant_id` column. Isolation is enforced in two layers:

- **Application layer**: every query is scoped by the current tenant,
  resolved from the authenticated user.
- **Database layer**: PostgreSQL Row-Level Security (RLS) policies
  restrict rows to the current tenant. The application connects with a
  restricted role that does not own the tables, because table owners and
  superusers bypass RLS.

## Consequences

- Simple operations and migrations: one schema to evolve, one connection
  pool, easy cross-tenant admin reporting.
- A missing tenant filter is a high-risk bug. RLS acts as a safety net,
  and we will add automated tests that try to read another tenant's data.
- Isolation is logically enforced, not physically separated, so it is
  weaker than schema- or database-per-tenant. Acceptable at our scale; we
  can revisit if a customer requires physical isolation.
- Every table, index and unique constraint must account for `tenant_id`
  (for example, invoice numbers are unique per tenant, not globally).

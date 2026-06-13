# pg-manager Specification

## Purpose

PostgreSQL cluster lifecycle management for Termux and Linux environments. Handles init, start, stop, status, database CRUD, and user management by detecting the appropriate pg_ctl variant.

## Requirements

### Requirement: pg_ctl detection

The system MUST detect the PostgreSQL control command at load time. On Termux, SHALL use `pg_ctl` directly. On Linux, SHALL probe `pg_ctlcluster` first and fall back to `pg_ctl` if unavailable.

#### Scenario: Termux uses pg_ctl directly

- GIVEN `NEXUS_ENV` is `termux`
- WHEN the pg module loads
- THEN `NEXUS_PG_CTL` MUST be set to `pg_ctl`

#### Scenario: Linux prefers pg_ctlcluster

- GIVEN `NEXUS_ENV` is `linux`
- AND `pg_ctlcluster` is in PATH
- WHEN the pg module loads
- THEN `NEXUS_PG_CTL` MUST be set to `pg_ctlcluster`

#### Scenario: Linux falls back to pg_ctl

- GIVEN `NEXUS_ENV` is `linux`
- AND `pg_ctlcluster` is NOT in PATH
- WHEN the pg module loads
- THEN `NEXUS_PG_CTL` MUST be set to `pg_ctl`

### Requirement: Cluster init and lifecycle

`nexus_pg_init <datadir>` MUST create a new PostgreSQL cluster. `nexus_pg_start` and `nexus_pg_stop` MUST start/stop the cluster using the detected pg_ctl variant. `nexus_pg_status` MUST report running or stopped.

#### Scenario: Init creates data directory

- GIVEN a target data directory path
- WHEN `nexus_pg_init /data/pg` runs
- THEN `initdb` MUST create the cluster at `/data/pg`
- AND return exit code 0 on success

#### Scenario: Start on stopped cluster

- GIVEN the cluster is initialized but stopped
- WHEN `nexus_pg_start` runs
- THEN the detected `$NEXUS_PG_CTL` MUST start the cluster
- AND `nexus_pg_status` MUST report running

#### Scenario: Stop running cluster

- GIVEN the cluster is running
- WHEN `nexus_pg_stop` runs
- THEN the cluster MUST be stopped gracefully
- AND `nexus_pg_status` MUST report stopped

### Requirement: Database management

`nexus_pg_create_db <name>` and `nexus_pg_drop_db <name>` MUST create and drop PostgreSQL databases via `createdb`/`dropdb` or equivalent SQL.

#### Scenario: Create database

- GIVEN the cluster is running
- WHEN `nexus_pg_create_db myapp` runs
- THEN database `myapp` MUST exist in the cluster
- AND return exit code 0

#### Scenario: Drop database

- GIVEN database `myapp` exists
- WHEN `nexus_pg_drop_db myapp` runs
- THEN database `myapp` MUST be removed
- AND return exit code 0

### Requirement: User management

`nexus_pg_create_user <name>` MUST create a PostgreSQL role via `createuser` or equivalent SQL.

#### Scenario: Create user

- GIVEN the cluster is running
- AND user `appuser` does not exist
- WHEN `nexus_pg_create_user appuser` runs
- THEN role `appuser` MUST be created
- AND return exit code 0

#### Scenario: Duplicate user error

- GIVEN user `appuser` already exists
- WHEN `nexus_pg_create_user appuser` runs
- THEN it MUST print a non-fatal warning
- AND return exit code 0 (idempotent)

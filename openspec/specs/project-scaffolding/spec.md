# project-scaffolding Specification

## Purpose

Template-based project generation via `nxai create <type> <name>`. Supports local templates and remote generators via npx. Templates live in `templates/`.

## Requirements

### Requirement: CLI subcommand routing

The system MUST register `create` as a subcommand in `core/nexus.sh`. `nxai create` SHALL route to the project scaffolding logic. Unknown types MUST print an error and show available types.

#### Scenario: Create routes to scaffolding

- GIVEN the user runs `nxai create vite my-app`
- WHEN the case branch matches `create`
- THEN it MUST source the scaffolding library
- AND pass `vite` and `my-app` as arguments

#### Scenario: Unknown type shows available list

- GIVEN the user runs `nxai create unknown my-app`
- WHEN no matching template or generator is found
- THEN the system MUST print "Tipo de proyecto desconocido"
- AND show the list of available types
- AND exit with code 1

### Requirement: npx verification

The system MUST verify `npx` is available before attempting any scaffolding operation. If missing, MUST print an install instruction message and exit.

#### Scenario: npx available

- GIVEN `npx --version` succeeds
- WHEN `nxai create` runs
- THEN scaffolding proceeds

#### Scenario: npx missing

- GIVEN `npx --version` fails (not in PATH)
- WHEN `nxai create` runs
- THEN the system MUST print "npx no esta instalado. Instala Node.js."
- AND exit with code 1

### Requirement: Project generation by type

Each type MUST invoke the appropriate generator. `nextjs` SHALL run `npx create-next-app`, `vite` SHALL run `npx create-vite`, `express` SHALL copy a local template from `templates/express/`, `nestjs` SHALL run `npx @nestjs/cli new`.

#### Scenario: Vite generation

- GIVEN npx is available
- WHEN `nxai create vite my-app` runs
- THEN `npx create-vite my-app` MUST execute
- AND the project directory MUST be created

#### Scenario: Express local template

- GIVEN `templates/express/` exists with a package.json stub
- WHEN `nxai create express my-api` runs
- THEN the template contents MUST be copied to `./my-api/`
- AND no npx invocation SHALL occur

#### Scenario: NestJS generation

- GIVEN npx is available
- WHEN `nxai create nestjs my-api` runs
- THEN `npx @nestjs/cli new my-api` MUST execute
- AND the project directory MUST be created

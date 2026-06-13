# c-helper Specification

## Purpose

GLIBC loader wrapper C program compilation. Generates, compiles, and places small C programs that use GLIBC loader (ld-linux) to run dynamically linked binaries inside proot/Termux where the system linker may not be at the expected path.

## Requirements

### Requirement: Architecture detection

The system MUST auto-detect CPU architecture before compilation. SHALL use `uname -m`, normalize to `aarch64` or `x86_64`. Any other value MUST abort with a supported-architectures error message.

#### Scenario: aarch64 detected

- GIVEN `uname -m` returns `aarch64`
- WHEN `nexus_c_build` runs
- THEN the generated C code MUST reference `ld-linux-aarch64.so.1`

#### Scenario: x86_64 detected

- GIVEN `uname -m` returns `x86_64`
- WHEN `nexus_c_build` runs
- THEN the generated C code MUST reference `ld-linux-x86-64.so.2`

#### Scenario: Unsupported architecture

- GIVEN `uname -m` returns `armv7l`
- WHEN `nexus_c_check_deps` runs
- THEN it MUST print an error listing supported architectures
- AND exit with code 1

### Requirement: C program generation and compilation

`nexus_c_build` MUST generate a C source file that invokes the GLIBC loader with the target binary path. It MUST compile with `clang -O2 -o <output> <source>` and place the output binary in a predefined location.

#### Scenario: Build succeeds

- GIVEN clang is in PATH and arch is supported
- WHEN `nexus_c_build` runs
- THEN a `.c` source file MUST be generated
- AND `clang -O2` MUST compile it without errors
- AND the output binary MUST be placed at the expected path

#### Scenario: Build with missing clang

- GIVEN clang is NOT in PATH
- WHEN `nexus_c_build` runs
- THEN it MUST print a descriptive error message
- AND exit with code 1

### Requirement: Dependency check

`nexus_c_check_deps` MUST verify that required tools (clang) and expected paths exist before attempting a build. It SHALL return 0 when all deps are satisfied, 1 otherwise.

#### Scenario: All deps present

- GIVEN clang is installed and arch is supported
- WHEN `nexus_c_check_deps` runs
- THEN it MUST return exit code 0

#### Scenario: Missing dependency

- GIVEN clang is NOT installed
- WHEN `nexus_c_check_deps` runs
- THEN it MUST return exit code 1
- AND print which dependency is missing

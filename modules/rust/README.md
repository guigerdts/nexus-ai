# Rust

## Descripcion

Lenguaje de programacion de sistemas con enfasis en seguridad,
concurrencia y rendimiento. Incluye rustc (compilador) y cargo
(gestor de paquetes y build system).

## Instalacion

```bash
nxai install rust
```

O manualmente:

```bash
pkg install rust      # Termux (rustc + cargo via rust package)
apt install rustc    # proot-Ubuntu
```

## Uso

```bash
rustc --version
cargo --version
cargo new mi-proyecto
cargo build
```

## Notas para Termux

```bash
pkg install rust
```

El paquete `rust` en Termux incluye rustc, cargo y rustup.

## Notas para proot-Ubuntu

```bash
apt install rustc cargo
```

Para la version mas reciente, usa rustup:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

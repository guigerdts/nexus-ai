# Clang — Compilador de C/C++

## Descripcion

Clang es un compilador para C, C++, Objective-C y Objective-C++ basado en
LLVM. Ofrece mensajes de error claros y rapidos tiempos de compilacion.

## Instalacion

```bash
nxai install clang
```

O manualmente:

```bash
pkg install clang      # Termux
apt install clang      # proot-Ubuntu
```

## Uso

```bash
clang programa.c -o programa
clang++ programa.cpp -o programa
clang --version
```

## Notas para Termux

```bash
pkg install clang
clang --help
```

## Notas para proot-Ubuntu

```bash
apt install clang
clang --help
```

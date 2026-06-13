# MiMo Code — CLI de codigo asistido por Xiaomi AI

## Descripcion

MiMo Code es un asistente de codigo nativo de terminal, open source, con memoria
persistente entre sesiones, manejo inteligente de contexto, sistema de subagentes
y modo composicion para desarrollo guiado por especificaciones.

Es un fork de [OpenCode](https://github.com/opencode-ai/opencode) con capacidades
adicionales de memoria, goal-driven loops, y auto-mejora via dream/distill.

## Instalacion

```bash
nxai install mimo-code
```

O via el instalador oficial:

```bash
curl -fsSL https://mimo.xiaomi.com/install | bash
```

## Uso

```bash
cd <proyecto>
mimo
```

## Requisitos

- curl (para descarga del binario)
- En Termux: glibc + clang (se instalan automaticamente)

## Caracteristicas principales

- **Multiples agentes**: build (default), plan (read-only), compose (orquestacion)
- **Memoria persistente**: SQLite FTS5 entre sesiones
- **Contexto inteligente**: checkpoints automaticos, reconstruccion de contexto
- **Subagentes**: creacion bajo demanda con ejecucion en paralelo
- **Goal/Stop Condition**: detencion automatica cuando se cumple el objetivo
- **Compose Mode**: desarrollo guiado por specs (SDD)
- **Dream & Distill**: auto-mejora y descubrimiento de patrones
- **Voz**: entrada de voz en tiempo real con TenVAD + MiMo ASR

## Enlaces

- GitHub: https://github.com/XiaomiMiMo/MiMo-Code
- Documentacion: https://mimo.xiaomi.com/coder/docs
- Sitio web: https://mimo.xiaomi.com/en/mimocode

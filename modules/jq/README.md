# jq

## Descripcion

Procesador JSON de linea de comandos ligero y portable. Permite
filtrar, transformar y formatear datos JSON con expresiones
simples y potentes.

## Instalacion

```bash
nxai install jq
```

O manualmente:

```bash
pkg install jq       # Termux
apt install jq       # proot-Ubuntu
```

## Uso

```bash
jq '.name' archivo.json
echo '{"foo": 1}' | jq '.foo'
jq '.[] | select(.age > 18)' personas.json
```

## Notas para Termux

```bash
pkg install jq
```

## Notas para proot-Ubuntu

```bash
apt install jq
```

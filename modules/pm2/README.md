# PM2

## Descripcion

Administrador de procesos Node.js en produccion. Mantiene aplicaciones
vivas, ofrece balanceo de carga y reinicio automatico ante fallos.

## Instalacion

```bash
nxai install pm2
```

O manualmente:

```bash
npm install -g pm2
```

## Uso

```bash
pm2 start app.js
pm2 list
pm2 monit
pm2 logs
```

## Notas para Termux

```bash
pkg install nodejs
npm install -g pm2
```

PM2 funciona correctamente en Termux para procesos Node.js.

## Notas para proot-Ubuntu

```bash
apt install nodejs npm
npm install -g pm2
```

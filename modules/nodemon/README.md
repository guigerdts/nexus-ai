# Nodemon

## Descripcion

Monitor de desarrollo que reinicia automaticamente aplicaciones Node.js
cuando detecta cambios en archivos del directorio.

## Instalacion

```bash
nxai install nodemon
```

O manualmente:

```bash
npm install -g nodemon
```

## Uso

```bash
nodemon app.js
nodemon --watch src/ app.js
```

## Notas para Termux

```bash
pkg install nodejs
npm install -g nodemon
```

## Notas para proot-Ubuntu

```bash
apt install nodejs npm
npm install -g nodemon
```

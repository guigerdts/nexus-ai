# Golang (Go)

## Descripcion

Lenguaje de programacion compilado y tipado estaticamente diseñado
por Google. Concurrencia nativa, compilacion rapida y una biblioteca
estandar poderosa.

## Instalacion

```bash
nxai install golang
```

O manualmente:

```bash
pkg install golang    # Termux
apt install golang   # proot-Ubuntu
```

## Uso

```bash
go version
go run main.go
go build -o bin/app
go test ./...
```

## Notas para Termux

```bash
pkg install golang
```

Go funciona correctamente en Termux. Configura tu GOPATH:
```bash
mkdir -p ~/go
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
```

## Notas para proot-Ubuntu

```bash
apt install golang
```

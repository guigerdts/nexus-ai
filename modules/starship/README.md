# Starship — Prompt minimalista

## Descripcion

Starship es un prompt para terminal increiblemente rapido, minimalista
e infinitamente personalizable. Funciona con cualquier shell (bash, zsh,
fish) y muestra informacion contextual del proyecto.

## Instalacion

```bash
nxai install starship
```

O manualmente:

```bash
curl -sS https://starship.rs/install.sh | sh
```

## Uso

```bash
# Anadir al final de ~/.bashrc o ~/.zshrc:
eval "$(starship init bash)"   # para bash
eval "$(starship init zsh)"    # para zsh

# Configuracion en ~/.config/starship.toml
```

## Notas para Termux

```bash
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

## Notas para proot-Ubuntu

```bash
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

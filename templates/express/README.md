# Express App

Express.js application scaffolded with **NEXUS AI**.

## Quick Start

```bash
# Install dependencies
npm install

# Start server
npm start

# Development mode with auto-reload
npm run dev
```

## Project Structure

```
express-app/
├── package.json
├── src/
│   └── index.js
├── .gitignore
└── README.md
```

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm start` | Start production server |
| `npm run dev` | Start development server with auto-reload |

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |

## Created with

This project was generated using `nxai create express <name>` from NEXUS AI.
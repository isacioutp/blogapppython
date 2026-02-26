# Blog Médico (Demo) - Flask + Docker
##
Demo estilo 2014-2016, server-rendered con Flask, SQLite, RSS y panel admin clasico.

## Funcionalidades

- Publicacion de posts con estados `draft` y `published`.
- Programacion de publicacion (`publish_at` en UTC).
- Soft delete de posts.
- Comentarios con moderacion desde admin.
- Tags (many-to-many) y vista por tag: `/tag/<name>`.
- Busqueda simple por `LIKE` con paginacion: `/search?q=...`.
- Archivo por mes: `/archive/<year>/<month>`.
- Feed RSS: `/feed.xml`.
- Endpoint de salud: `/healthz`.

## Stack

- Flask 3
- Flask-Login
- Flask-WTF (CSRF)
- Flask-SQLAlchemy / SQLAlchemy 2
- Gunicorn
- SQLite (por defecto)

## Requisitos

- Docker + Docker Compose

Opcional para correr sin Docker:

- Python 3.11+

## Ejecutar con Docker

```bash
docker compose up --build
```

URLs locales:

- Blog: `http://localhost:8000/`
- Login: `http://localhost:8000/login`
- Admin posts: `http://localhost:8000/admin`
- Admin comentarios: `http://localhost:8000/admin/comments`
- RSS: `http://localhost:8000/feed.xml`
- Healthcheck: `http://localhost:8000/healthz`

## Variables de entorno principales

- `SECRET_KEY` o `FLASK_SECRET_KEY`: clave de Flask (minimo recomendado: 32 caracteres).
- `ADMIN_PASSWORD`: password del usuario `admin` (obligatoria para `flask initdb`, minimo 12 caracteres).
- `DATABASE_URL`: por defecto `sqlite:////data/blog.db`.
- `LOG_LEVEL`: `INFO`, `WARNING`, etc.
- `LOG_FORMAT`: `json` o `text`.
- `ENABLE_FILE_LOG`: `true/false` para escribir logs en `/data/logs/app.log`.
- `AUTO_INIT_DB`: `true/false` (ejecuta `flask initdb` al iniciar contenedor).
- `AUTO_SEED_DB`: `true/false` (ejecuta `flask seed` al iniciar contenedor).
- `SESSION_COOKIE_SECURE`: `true/false`.
- `TRUSTED_HOSTS`: hosts permitidos, separados por coma.

## Importante sobre `ADMIN_PASSWORD`

`flask initdb` exige `ADMIN_PASSWORD` con al menos 12 caracteres cuando crea el usuario admin por primera vez.

Ejemplo seguro:

```bash
export ADMIN_PASSWORD='cambia-esto-por-uno-seguro-123'
export SECRET_KEY='cambia-esto-por-una-clave-larga-y-unica'
docker compose up --build
```

## Ejecucion sin Docker (opcional)

```bash
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt

export FLASK_APP=app.py
export FLASK_SECRET_KEY='clave-larga-y-unica'
export ADMIN_PASSWORD='password-admin-seguro'

flask initdb
flask seed
python app.py
```

## Persistencia

- Base SQLite: `/data/blog.db`
- Volumen Docker: `blogdata`

## Deploy (DigitalOcean App Platform)

- Spec: `.do/app.yaml`
- Workflow GitHub Actions: `.github/workflows/deploy-logs.yml`
- Rama configurada actualmente para deploy automatico: `logs-testing`

## Seguridad (resumen)

- CSRF habilitado en formularios.
- Cookies de sesion `HttpOnly` y `SameSite=Lax`.
- `ProxyFix` para ejecucion detras de proxy reverso.
- `MAX_CONTENT_LENGTH` de 1 MB.
- Rate limiting de intentos de login por IP.

## Aviso medico

Contenido informativo y educativo. No sustituye diagnostico ni consulta medica profesional.

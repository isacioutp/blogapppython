# Blog Médico (Demo) - Flask + Docker

Demo server-rendered con Flask, SQLite, RSS y panel admin clasico.

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

## Resumen de seguridad

- Nivel actual: baseline robusto para despliegue inicial.
- Controles activos: CSRF, cookies seguras, `SECRET_KEY` obligatorio, password admin minimo, `TRUSTED_HOSTS`, rate limit de login, CSP para scripts y validaciones de formularios.
- Riesgos principales pendientes: rate limiting no distribuido entre replicas, uso de `style-src 'unsafe-inline'`, y falta de pipeline automatizado completo (SAST/SCA/DAST).
- Recomendacion operativa: mantener secretos fuertes por entorno, monitorear logs estructurados y ejecutar escaneo de seguridad en CI antes de cada release.

## Estado de seguridad (actualizado: 2026-02-25)

Estado actual: baseline robusto para despliegue inicial.

Hardening aplicado:
- Mitigacion de Stored XSS en contenido renderizado.
- Cookies de sesion seguras por defecto (`SESSION_COOKIE_SECURE=true`).
- `SECRET_KEY`/`FLASK_SECRET_KEY` obligatorio con longitud minima.
- `ADMIN_PASSWORD` obligatorio y minimo 12 caracteres en `flask initdb`.
- `TRUSTED_HOSTS` configurable por entorno.
- Rate limiting basico de login por IP.
- CSP restrictiva para scripts (`script-src 'self'`).
- Logout por `POST` con CSRF.
- Formularios de borrado admin por `POST` con CSRF.
- Contenedor ejecutando como usuario no root.

Riesgos residuales:
- Rate limiting en memoria (no distribuido entre replicas).
- `style-src 'unsafe-inline'` aun presente por estilos inline en templates.
- Sin pipeline automatizado completo de SAST/SCA/DAST.

## Variables de entorno principales

- `SECRET_KEY` o `FLASK_SECRET_KEY`: clave de Flask (minimo recomendado: 32 caracteres).
- `ADMIN_PASSWORD`: password del usuario `admin` (obligatoria para `flask initdb`, minimo 12 caracteres).
- `DATABASE_URL`: por defecto `sqlite:////data/blog.db`.
- `SESSION_COOKIE_SECURE`: `true/false`.
- `TRUSTED_HOSTS`: hosts permitidos, separados por coma.
- `LOGIN_RATE_LIMIT_WINDOW_SECONDS`: ventana para rate limit.
- `LOGIN_RATE_LIMIT_MAX_ATTEMPTS`: intentos maximos por IP.
- `LOG_LEVEL`: `INFO`, `WARNING`, etc.
- `LOG_FORMAT`: `json` o `text`.
- `ENABLE_FILE_LOG`: `true/false` para escribir logs en `/data/logs/app.log`.
- `AUTO_INITDB`: `true/false` (ejecuta `flask initdb` al iniciar contenedor).
- `ENABLE_DEMO_SEED`: `true/false` (ejecuta `flask seed` al iniciar contenedor).

## Ejecutar con Docker

Configura variables (ejemplo):

```bash
export SECRET_KEY='cambia-esto-por-una-clave-larga-y-unica'
export ADMIN_PASSWORD='cambia-esto-por-un-password-seguro'
```

Levanta la app:

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

## Aviso medico

Contenido informativo y educativo. No sustituye diagnostico ni consulta medica profesional.

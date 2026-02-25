# Blog Médico (Demo) — Flask + Docker
Demo server-rendered con Flask, SQLite, templates, RSS y panel admin clásico.

## Estado de seguridad (actualizado: 2026-02-24)
Estado actual: **baseline robusto para despliegue inicial** con hardening aplicado.

## Hardening aplicado
- Eliminado `|safe` en contenido de posts y comentarios (mitigación de Stored XSS).
- Cookies de sesión seguras por defecto (`SESSION_COOKIE_SECURE=true` por default en app).
- `SECRET_KEY` obligatorio y con longitud mínima (>=32 chars), salvo modo explícito `ALLOW_INSECURE_DEV_DEFAULTS=true`.
- `ADMIN_PASSWORD` obligatorio y con mínimo 12 caracteres en `initdb`.
- `TRUSTED_HOSTS` configurado por defecto y configurable por entorno.
- Rate limiting básico de login por IP (ventana e intentos configurables por env).
- CSP endurecida (`script-src 'self'`), sin inline script en templates activas.
- Logout corregido a `POST` con CSRF real.
- Formularios admin de borrado corregidos (`POST` + CSRF por item).
- `entrypoint` endurecido: sin `|| true`, seed solo opcional.
- Contenedor corre con usuario no root.
- Dependencias movidas a rangos modernos mantenidos.

## Riesgos residuales
- El rate limiting actual es en memoria por proceso (no distribuido entre múltiples réplicas/instancias).
- `style-src 'unsafe-inline'` sigue activo por uso extensivo de estilos inline en plantillas.
- Falta pipeline de pruebas/escaneo de seguridad automatizado (SAST/SCA/DAST).

## Configuración recomendada (producción)
Variables mínimas:
- `SECRET_KEY`: aleatorio largo (>=32 bytes).
- `ADMIN_PASSWORD`: fuerte (>=12, recomendado >=16).
- `SESSION_COOKIE_SECURE=true`
- `TRUSTED_HOSTS=tu-dominio.com,www.tu-dominio.com`
- `LOGIN_RATE_LIMIT_WINDOW_SECONDS=900`
- `LOGIN_RATE_LIMIT_MAX_ATTEMPTS=5`
- `LOG_LEVEL=INFO`
- `LOG_FORMAT=json`

## Features
- Tags (many-to-many) y vista por tag: `/tag/<name>`
- Búsqueda simple (SQL LIKE): `/search?q=...` (con paginación)
- Archivo por mes: `/archive/<year>/<month>`
- RSS: `/feed.xml`
- Admin:
  - Draft / Published
  - Scheduled publish (`publish_at` futuro no se ve en público)
  - Soft delete
  - Moderación de comentarios

## Aviso médico
Contenido informativo / educativo. No sustituye diagnóstico ni consulta médica.

## Correr con Docker
Primero crea `.env` desde la plantilla:
```bash
cp .env.example .env
```

Genera credenciales fuertes y reemplaza valores:
```bash
python -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(48))"
python -c "import secrets; print('ADMIN_PASSWORD=' + secrets.token_urlsafe(24))"
```

Luego levanta:
```bash
docker compose up --build
```

- Blog: http://localhost:8000/
- Login: http://localhost:8000/login
- Admin: http://localhost:8000/admin
- Comentarios: http://localhost:8000/admin/comments
- RSS: http://localhost:8000/feed.xml

## Persistencia
SQLite en `/data/blog.db` (volume `blogdata`).

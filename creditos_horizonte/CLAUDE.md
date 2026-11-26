# Proyecto: Créditos Horizonte

Hereda todas las reglas de `claudehome/CLAUDE.md`. Este archivo agrega contexto específico del proyecto.

## Contexto del negocio
Fullstack para "Créditos Horizonte", empresa peruana pequeña dedicada a préstamos. La app gestiona todo lo relacionado a la operación: agentes, clientes, préstamos, pagos, devoluciones, kardex, caja, balances, reportes, simulador de créditos.

- Para boletas se usan documentos internos.
- Para temas tributarios (facturación electrónica) se usa la API de **Nubefact** desde el backend (módulo `loan`).
- Zona horaria de negocio: `America/Lima`.

Faltan más detalles de negocio que se irán agregando durante el desarrollo.

## Estructura
```
creditos_horizonte/
├── backend/    (repo: xsp4ce/creditos-horizonte-backend)
└── frontend/   (repo: xsp4ce/creditos-horizonte-frontend)
```

## Stack — Backend
- Java 21, Spring Boot 4.0.2
- Programación reactiva: WebFlux + R2DBC (no JPA/JDBC bloqueante)
- Base de datos: PostgreSQL 17 en Railway (vía R2DBC). Producción: host `trolley.proxy.rlwy.net`; base anterior de pruebas: `metro.proxy.rlwy.net`
- Seguridad: OAuth2 resource server con JWT (issuer configurado por `OKTA_ISSUER_URI`, pero el proveedor real de auth es **Auth0**, ver frontend)
- Storage de archivos: Cloudflare R2 (API S3-compatible), URLs presignadas
- Integración externa: Nubefact (facturación electrónica Perú)
- Build: Maven (`mvnw`)

Módulos (`src/main/java/com/creditoshorizonte/backend/`): `agent`, `balance`, `generalbalance`, `cashbox`, `catalog`, `customer`, `kardex`, `loan`, `notification`, `payment`, `realtime`, `refund`, `report`, `simulator`, `system`, `shared`, `config`.

Tiempo real: `GET /api/v1/events` (SSE, `realtime`) emite solo el tópico (`loans`, `payments`, `refunds`, `agent-records`, `cash-box`, `balances`, `general-balances`, `notifications`) desde los services al terminar cada cambio; el frontend (`lib/realtime.ts`) invalida las queries de ese tópico. Funciona con una sola instancia del backend.

Config local vía variables de entorno (ver `application.yml`): `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `CRYPTO_AES_KEY`, `CRYPTO_HMAC_KEY`, `NUBEFACT_URL`, `NUBEFACT_TOKEN`, `R2_*`, `CORS_ALLOWED_ORIGINS` (default `http://localhost:3000`, debe matchear el puerto del frontend).

## Stack — Frontend
- Next.js 15 (App Router), React 18, TypeScript estricto
- Auth: `@auth0/nextjs-auth0`
- UI: Radix UI + Tailwind (shadcn-style, ver `components.json`)
- Data fetching: TanStack Query + axios
- Forms: react-hook-form + zod
- Node 22.x requerido (gestionado con nvm, ya instalado y seteado como default)
- Package manager: npm en local (`npm run dev` levanta con turbopack), pero Railway construye con **pnpm** porque existe `pnpm-lock.yaml`: al cambiar dependencias actualizar `package-lock.json` y `pnpm-lock.yaml` (`corepack pnpm@9 install --lockfile-only`)

Módulos (`features/`): `agent`, `balance`, `cash-box`, `customer`, `dashboard`, `kardex`, `loan`, `payment`, `refund`, `report`, `simulator`, `system`, `taxes`. Coinciden 1:1 con los módulos del backend.

## Entorno ya configurado
- SSH con GitHub: OK (usuario `xsp4ce`, key ed25519 en `~/.ssh/id_ed25519`)
- Java 21 LTS: instalado (apt)
- Node 22 + npm: instalado vía nvm
- Se eliminó `.claude/` del repo del frontend (venía commiteado de una sesión anterior, no se usa)

## Despliegue
- Producción en Railway (backend, frontend y PostgreSQL) detrás de Cloudflare, dominio `https://www.creditoshorizonte.com`. Cada push a `main` despliega.
- Backend: `nixpacks.toml` fija JDK 21; Maven compila también los tests. Variables con los nombres de `application.yml` (`DB_URL` con prefijo `r2dbc:`, `CRYPTO_*`, `NUBEFACT_*`, `R2_*`, `OKTA_ISSUER_URI`, `CORS_ALLOWED_ORIGINS`, `SPRING_PROFILES_ACTIVE=prod`).
- Frontend: el navegador no llama al backend directo; todo pasa por el proxy de Next `app/api/backend/[...path]/route.ts`, que agrega el token de la sesión de Auth0 en el servidor (no existe cookie `access_token` legible por JS). Variable de servidor `BACKEND_URL` = URL del backend (puede ser `*.railway.internal`); si falta, usa `NEXT_PUBLIC_BACKEND_URL` y en desarrollo `http://localhost:8080`. `next build` falla con cualquier error de `tsc`.
- Detalle completo en `PROJECT.md` (sección DESPLIEGUE). Credenciales pendientes de rotar: ver memoria.
- Herramientas instaladas en este PC: `postgresql-client` 16 (`psql`), sirve contra el PostgreSQL 17 de Railway; `pg_dump` 16 no.

## Documentación y migraciones
- Documentación en `creditos_horizonte/docs` (repo `creditos-horizonte-docs`, `credentials.txt` fuera de git): `PROJECT.md`, `DATABASE.md`, `DDL.txt` (esquema de BD) y `CREAR_USUARIO.md` (manual de usuario para el cliente, lenguaje formal y no técnico).
- Migraciones SQL en `docs/ddl/`, formato `V0XX__descripcion.sql` (última: V037), se ejecutan manualmente en PostgreSQL (sin Flyway/Liquibase), antes de desplegar el backend que las usa. Al cambiar la BD, actualizar también `DDL.txt` y `DATABASE.md`.
- La carpeta `docs` solo existe en este PC; en la laptop se trabaja con notas que luego se procesan aquí.
- Al cambiar reglas del formulario de clientes, actualizar `CREAR_USUARIO.md`.

## Notas
- Commits: mensajes cortos, en inglés y en minúsculas (ej. `move guarantor to personal info step`).
- Las reglas de validación del alta de clientes se aplican igual en front (zod) y back (`CustomerValidator` + anotaciones en los records del request).

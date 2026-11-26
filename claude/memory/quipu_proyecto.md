---
name: quipu-proyecto
description: "Quipu, app personal de finanzas (PWA) del usuario; decisiones en quipu/PROYECTO.md"
metadata:
  node_type: memory
  type: project
  originSessionId: 6a960ad4-2b29-4bf8-b505-0355397cab76
  modified: 2026-11-22T00:14:11.618Z
---

Quipu es la app personal de finanzas del usuario, iniciada el 2026-11-21. Es una PWA hecha con SvelteKit + TypeScript + Drizzle + Postgres de Railway + Better Auth (passkeys). Tiene 8 fases y todas las decisiones están en `claudehome/quipu/PROYECTO.md`.

**Why:** el usuario pidió explícitamente la mejor recomendación técnica sin basarse en sus preferencias (no Java/Spring).
**How to apply:** leer PROYECTO.md al retomar. Fase 1 ya definida (alcance + modelo multiusuario). Borrado de gastos definitivo. Credenciales en quipu/.env (nunca leer ni mostrar). Estructura creada y migración 0000_phase1_initial aplicada en Railway (2026-11-21). Better Auth configurado (SvelteKit 3: env en src/env.ts + $app/env/private, Handle en @sveltejs/kit/hooks, imports #lib con extensión .ts). Script npm run user:create listo (lo corre el usuario). FASE 1 COMPLETA 2026-11-21 (probada en iPhone vía red local; guard de auth en hooks.server.ts, UI en español). PWA lista (manifest + íconos generados con script sin dependencias). Deploy: GitHub (rama main) con autodeploy de Railway, el usuario hace commits/push. Prod y dev comparten la misma BD (aceptado). Fase 1 desplegada y passkeys OK. FASE 2 código escrito sin probar ni revisar tipos (ver "Estado de la fase 2" en PROYECTO.md). npm run check OK. Migraciones 0001-0003 APLICADAS 2026-11-21 (prod caída hasta push de fase 2). Al retomar: leer sección "Retomar aquí" de PROYECTO.md. No mezclar con creditos_horizonte.

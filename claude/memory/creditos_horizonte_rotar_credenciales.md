---
name: creditos_horizonte_rotar_credenciales
description: Credenciales de creditos_horizonte expuestas en chats que el usuario debe rotar al terminar la config de producción (pendiente desde 2026-10-26)
metadata:
  node_type: memory
  type: project
  originSessionId: cb0e6812-e5ac-4b64-88ef-65edbadd808b
  modified: 2026-10-26T08:07:00.573Z
---

El 2026-10-26 el usuario pegó en el chat (sesión cb0e6812) credenciales reales de producción. Decidió NO rotarlas todavía: lo hará cuando termine toda la configuración del deploy en Railway. Aquí no se guarda ningún valor, solo qué rotar.

Rotar:
- Contraseña de la BD de producción nueva (Postgres Railway, host `trolley.proxy.rlwy.net`). Luego actualizar `DB_PASSWORD` del backend en Railway.
- Contraseña de la BD anterior (Postgres Railway, host `metro.proxy.rlwy.net`), también usada en su `.env` local.
- Token de Nubefact: había dos distintos (el de Railway y el del `.env` local); rotar el vigente y eliminar el otro. Actualizar `NUBEFACT_TOKEN`.
- Claves de Cloudflare R2: `R2_SECRET_ACCESS_KEY` (y `R2_ACCESS_KEY_ID`, se regeneran juntas). Actualizar en Railway y en local.
- Las notas de la laptop (2026-10-20) ya avisaban de credenciales compartidas en otro chat: mismas claves.

No rotar después de que haya clientes:
- `CRYPTO_AES_KEY` / `CRYPTO_HMAC_KEY`: solo se pueden cambiar mientras la BD de producción esté vacía; después requieren migrar datos cifrados y hashes.

El 2026-11-13 (sesión a6185016) el usuario volvió a pegar en el chat todas las variables del backend local (BD metro, CRYPTO_*, Nubefact, R2): son las mismas de esta lista, no hay nada nuevo que rotar. Ese transcript también tiene los valores en texto plano.

Extra: el transcript `~/.claude/projects/-home-space-claudehome/cb0e6812-e5ac-4b64-88ef-65edbadd808b.jsonl` contiene todas esas credenciales en texto plano; ofrecer borrarlo cuando ya no haga falta retomar el chat.

**Why:** quedaron expuestas en el historial local y en la conversación con Anthropic.
**How to apply:** cuando el usuario diga que terminó la config de producción (o al retomar creditos_horizonte), recordarle esta lista antes de seguir. Nunca mostrar ni pedir los valores. Ver [[creditos_horizonte_pendientes_clientes]].

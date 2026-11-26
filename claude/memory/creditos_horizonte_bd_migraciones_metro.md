---
name: creditos_horizonte_bd_migraciones_metro
description: 2026-11-13 se aplicaron V011-V016 adaptadas y V033 (bank_balance) en la BD metro; pendiente preguntar al usuario por producción (trolley) y por actualizar DDL.txt/DATABASE.md
metadata:
  type: project
---

El 2026-11-13 la BD `metro.proxy.rlwy.net` (la que usa el backend local) no tenía aplicadas V011-V016 (tenía V017-V032). Por eso falló el alta de registros de agente (`agent_sub` NOT NULL). Con autorización del usuario se aplicaron V011-V016 adaptadas en una sola transacción, sin los `ADD COLUMN created_by_name/updated_by_name`, que ya existían:
- cash_box: UNIQUE(created_by, date) + índice + created_at/updated_at a TIMESTAMPTZ.
- agent_daily_records: drop agent_sub + UNIQUE(created_by, date) + índice + TIMESTAMPTZ.
- balance_daily_records: columnas renombradas al inglés + drop agent_sub. Los índices viejos sobre agent_sub se borraron junto con la columna.

El mismo día se separó `SaveBalanceDailyRecordRequest` en Create/Update (como en agentes) y el frontend pasó a enviar claves en inglés y `version`.

También el 2026-11-13 se creó y aplicó en metro `V033__add_bank_balance_to_agent_daily_records.sql` (columna nullable; los registros viejos quedan en NULL). En agentes, el ITF ahora se calcula a partir del saldo bancario.

Preguntar al usuario más adelante (lo pidió explícitamente):
1. ¿La BD de producción (`trolley`) tiene V011-V016 y V033? Si se creó a partir de `DDL.txt`, probablemente no; revisarlo antes de desplegar este cambio.
2. Actualizar `DDL.txt` y `DATABASE.md` (en `docs`), que todavía muestran agent_sub, las columnas de balance en español, timestamps sin zona y no tienen bank_balance.

**Why:** el usuario pidió explícitamente que se lo recordara para decidir después.
**How to apply:** al retomar creditos_horizonte, o antes de un push/deploy de backend, preguntar por estos dos puntos. Ver [[creditos_horizonte_pendientes_clientes]] y [[creditos_horizonte_rotar_credenciales]].
- V034, V035, V036 (loan_refunds.refunded_by) y V037 (notifications) aplicadas en metro (V036 y V037 el 2026-11-16). Prod (trolley) pendiente, ver docs/PASE_PRODUCCION.md.

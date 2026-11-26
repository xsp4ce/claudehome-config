---
name: creditos_horizonte_agentes_caja_20261113
description: "Cambios del 2026-11-13 en agentes (cargo neto, ITF manual + saldo bancario obligatorio), balance (DTOs separados) y cómo calcula caja el saldo esperado; preguntar al usuario por lo pendiente"
metadata:
  node_type: memory
  type: project
  originSessionId: a6185016-f0a9-44cd-a4cd-8dc433ec7147
  modified: 2026-11-13T22:22:32.375Z
---

Resumen de la sesión del 2026-11-13 en creditos_horizonte. El usuario pidió dejarlo registrado para preguntarle después. Nada se compiló ni se probó con tests; el usuario probó a mano contra la BD `metro`.

## Agentes (`backend/.../agent`, `frontend/features/agent`)
- El frontend enviaba claves en español (`cargo`, `cobranza`…). Ahora usa las mismas que el backend (`charge`, `collections`…) y manda `version` al editar.
- **Cargo neto**: el usuario ingresa el cargo bruto (ej. 12075) y la cobranza (1653); se guarda `charge = cargo − cobranza` (10422). Total ingresos = cargo neto + comisión + depósitos + cobranza + otros (= 12075). Al editar, el formulario muestra el bruto (`charge + collections`). La cobranza no puede superar el cargo (`@AssertTrue` en `AgentDailyRecordFields` + aviso en el formulario).
- **Saldo bancario** (`bank_balance`, obligatorio): el ITF se ingresa a mano y saldo = saldo anterior + ingresos − (retiros + ITF + sobrante + abono). Si el saldo ≠ saldo bancario, el backend responde 409 (`AgentErrorMessages.BALANCE_MISMATCH`) y el formulario muestra "No coincide (diferencia: X)" con Guardar deshabilitado. Antes se probó calcular el ITF automáticamente y se descartó.
- El saldo anterior es el `balance` del último registro del mismo usuario con fecha menor (`AgentQueries.FIND_PREVIOUS_BALANCE`), no necesariamente el del día anterior. Endpoint nuevo `GET /api/v1/agents/previous-balance?date=` para la vista previa al crear; al editar se deduce de `balance − totalIncome + totalExpenses`.
- Columna "Saldo bancario" en la tabla.
- Editar un registro **no** recalcula los días siguientes (su saldo anterior queda desactualizado).

## Balance
- `SaveBalanceDailyRecordRequest` se separó en `CreateBalanceDailyRecordRequest` (sin version) y `UpdateBalanceDailyRecordRequest` (con version); se borró el viejo. `BalanceSummaryResponse` ahora expone `version`. Usa `agentCharge` = cargo **neto** del registro de agente (decisión del usuario).

## Caja
- "Saldo esperado" no se guarda: `CashBoxResponseAssembler` toma el `balance` del registro de agente del mismo usuario y fecha. "Coincide" = total contado == ese saldo. Sin registro de agente: saldo vacío y no coincide. Con la regla nueva, ese saldo siempre es igual al saldo bancario.

## BD metro (datos de prueba)
- Migraciones aplicadas: ver [[creditos_horizonte_bd_migraciones_metro]] (V011-V016 y V033 `bank_balance`).
- A los registros viejos se les puso `bank_balance = balance`. El del 2026-03-15 tiene saldo −200 y no puede editarse (falla `@DecimalMin("0")`).
- Registro de prueba 2026-11-12 (saldo 5383.13) creado a mano; los del 13-11 se borraron varias veces durante las pruebas.

## Preguntar al usuario
1. ¿Probó la validación de saldo bancario de punta a punta (crear y editar)?
2. ¿Hay que recalcular los días siguientes al editar un registro?
3. ¿Arreglar o borrar el registro del 2026-03-15 (saldo negativo)?
4. ¿Caja debe seguir comparando contra el saldo del agente (= saldo bancario) o contra otra cosa?
5. Pendientes de producción y docs: ver [[creditos_horizonte_bd_migraciones_metro]].

**Why:** el usuario lo pidió explícitamente para retomarlo después.
**How to apply:** al retomar creditos_horizonte (agentes, caja o balance), leer esto y hacer las preguntas antes de seguir; verificar en el código que siga igual.

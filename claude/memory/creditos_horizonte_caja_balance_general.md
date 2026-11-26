---
name: creditos_horizonte_caja_balance_general
description: "Estado al 2026-11-17 de creditos_horizonte: cambios sin commit/sin probar (proxy Next, NumericInput, registrado por, errores 409/404/400, etc.) y lista de pendientes; LEER PRIMERO al retomar"
metadata:
  node_type: memory
  type: project
  originSessionId: 50d87969-f318-4f70-9b5a-fbdb310eab25
  modified: 2026-11-17T22:24:21.517Z
---

## PRÓXIMA SESIÓN (empezar aquí)
Al decir "vamos a trabajar en creditos horizonte": leer esta nota, correr `git status` en backend y frontend, y retomar.

### Hecho el 2026-11-16/17, SIN PROBAR (el usuario commitea; verificar con git status qué falta)
Commits sugeridos (frontend):
- `disable register cash box button until today's records exist`
- `replace number inputs with numeric text input` (nuevo `components/ui/numeric-input.tsx`, props `decimals`, `maxIntegerDigits`, `max`; 19 inputs reemplazados)
- `show remaining amount due per installment in payment detail` (installments-table: amountDue − paidAmount, PAID = 0)
- `show dash when created by name is missing` (Pagos, Devoluciones, Impuestos, Kardex)
- `print receipts and refunds only on demand` (payment.tsx, pay-loan-dialog, mark-devuelto-dialog)
- `refresh default dates on open and redirect to login on 401` (Caja, Agentes; interceptor 401 + SSE 401)
- `proxy backend calls through next server and drop readable access token cookie` (nuevo `app/api/backend/[...path]/route.ts`, axios baseURL `/api/backend`, middleware borra cookie `access_token` y da 401 JSON en `/api/backend/*` sin sesión)
Commits sugeridos (backend):
- `store creator name on loans, invoices, payments and refunds` (Payment/Loan Service pasan actorName)
- `return proper status for business errors and allow cent payments` (Conflict/NotFound en reverse, discount, system, catalog, recibo; IllegalArgument→400; `@DecimalMin("0.01") @Digits(10,2)`)
Docs actualizadas: `creditos_horizonte/CLAUDE.md` (despliegue frontend con `BACKEND_URL`), `docs/PASE_PRODUCCION.md` secciones 9 (proxy) y 10 (resto).

### 2026-11-17 (tarde), SIN COMMIT ni probar
- Frontend: commit del proxy seguía en staged sin commitear (`app/api/backend/[...path]/route.ts`, axios, realtime, middleware).
- Backend `round expected cash box balance to 10 cents and make version optional`:
  - `CashBoxReconciliationSupport`: saldo esperado = balance de Agentes redondeado a 0.10 con HALF_UP (≤0.04 baja, ≥0.05 sube; regla del usuario). Caja no tiene denominación 0.01.
  - `SaveCashBoxRequest.version` sin `@NotNull` (el frontend nunca la envía → "Validation failed" al crear caja, bug desde junio). `CashBoxUpdateUseCase` solo setea version si llega (sin bloqueo optimista en caja). Opcional a futuro: devolver `version` en CashBoxResponse y enviarla desde el frontend.
- Metro 2026-11-17: Agentes de Javier (auth0|680643e1...) balance 17196.53 → caja esperada 17196.50; `created_by_name` vacío en ese registro. Tabla de caja no se llama `cash_boxes`.
- Al leer credentials.txt se expusieron CRYPTO_AES_KEY/HMAC en salida de tool: sumar a [[creditos_horizonte_rotar_credenciales]]. Leer credenciales solo extrayendo variables, nunca con sed/grep que imprima la línea.
- Siguiente: reiniciar backend, cuadrar caja de Javier, luego "resolver todo" (pendientes de abajo).

### Qué probar
- Caja con cuadre + Notificaciones (claim `name` ya agregado en la Action): botón Registrar caja deshabilitado sin Agentes+Balance de hoy; caja que no cuadra → no guarda y notifica al admin en tiempo real; caja que cuadra → guarda.
- Proxy: Network muestra `/api/backend/api/v1/...`, sin cookie `access_token`, SSE funciona, descargas PDF, sesión vencida → login.
- NumericInput en los 19 campos; pago parcial baja "Total a pagar"; "Registrado por" con nombre en registros nuevos.

### Pendientes (decisiones de negocio, preguntar)
1. Permisos: agente puede cambiar tasas/cargos/catálogos, anular préstamos y aplicar descuentos (todo `HAS_ADMIN_OR_AGENT` salvo Balance General). ¿Qué es solo admin?
2. Fecha de pago libre (futura/antigua) cambia interés y mora. ¿Limitar?
3. Anular préstamo no anula la factura en Nubefact (falta nota de crédito).
4. No existe anulación de pagos.
5. Saldo pendiente (= capital) vs Total a pagar: el usuario dijo dejarlo como está "por ahora"; opción recomendada: columnas "Capital pendiente" + "Total a cancelar hoy".
6. Recibo impreso desde el navegador tras pagar no incluye "Registrado por".
7. Caja General del admin y movimientos admin↔agentes: definir reglas.

### Pendientes técnicos
- Huecos en numeración R/P/I (nextCode fuera de la transacción). Sin urgencia.
- Controlar la app desde navegador: Claude in Chrome no funciona en WSL; opción propuesta Playwright MCP (necesita instalación y saber si tiene Windows 11/WSLg). El usuario lo dejó para después.
- Pase a producción: todo en `docs/PASE_PRODUCCION.md` (migraciones hasta V037, `APP_RATE_LIMIT_REQUESTS_PER_MINUTE=300`, `BACKEND_URL` en frontend, re-login).

## Reglas definidas por el usuario
- Agente = ventanilla, rol `AGENT`, su propia Agentes/Caja/Balance (un agente no ve los de otro). Admin (`ADMIN`, uno solo, "Coco") = Caja General y Balance General, ve todo. Máx. 3 agentes.
- Balance General (admin), cerrado: dinero entregado = Σ withdrawals de agent_daily_records; cobranza = Σ pagos R por paid_date; vales = Σ loans no REVERSED por start_date; devoluciones = Σ DEVUELTO por `refunded_at` (Lima). Recalcular; caja anterior = cash_on_hand del día−1 o 0.
- Balance del agente, cerrado: solo dinero entregado manual; cobranza/vales/devoluciones = lo registrado por ese agente en el día (devoluciones por `refunded_by`); caja anterior = balance de ayer del agente o 0; Recalcular.
- Tiempo real: SSE `GET /api/v1/events`, `lib/realtime.ts` invalida queries por tópico. Una sola instancia.
- Caja del agente: sin saldo esperado; compara total con `balance` de Agentes del día; si no cuadra no se guarda y notifica al admin; sin Agentes+Balance del día, Registrar caja y Guardar deshabilitados.
- Notificaciones: sidebar para todos; por ahora solo el admin recibe (descuadres).
- Recalcular no actualiza días siguientes (aceptado).
- Registros antiguos sin nombre muestran "—".
- Impresión de recibos/devoluciones solo manual.

**Why:** el usuario retoma con una frase corta y espera continuidad sin re-explicar.
**How to apply:** no suponer reglas de negocio de la lista de pendientes; preguntar. Credenciales de metro en `docs/credentials.txt` (nunca mostrar). Ver [[creditos_horizonte_bd_migraciones_metro]], [[creditos_horizonte_agentes_caja_20261113]].

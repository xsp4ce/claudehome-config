---
name: creditos_horizonte_pendientes_clientes
description: "Estado de creditos_horizonte al cierre del 2026-10-26 (producción desplegada, simulador con PDF/ticket, desglose escalado) y pendientes abiertos"
metadata:
  node_type: memory
  type: project
  originSessionId: cb0e6812-e5ac-4b64-88ef-65edbadd808b
  modified: 2026-10-26T08:43:45.958Z
---

El usuario trabaja también desde una MacBook; desde 2026-11-26 los docs están en `claudehome/creditos_horizonte/docs` sincronizados por git (ver [[sincronizacion_pc_laptop]]).

Estado al cierre del 2026-10-26:
- Producción funcionando en Railway + Cloudflare (`https://www.creditoshorizonte.com`). Detalle de deploy en `creditos_horizonte/docs/PROJECT.md` (sección DESPLIEGUE) y en el CLAUDE.md del proyecto.
- BD de producción nueva (host `trolley.proxy.rlwy.net`), creada vacía con catálogos; la base anterior (`metro.proxy.rlwy.net`) queda como pruebas. Ver DATABASE.md.
- Migraciones V025–V032 guardadas en `creditos_horizonte/docs/ddl`.
- Commits del día: frontend (validación por etapa restaurada, next 15.2.8 + pnpm-lock, errores tsc, axios exige `NEXT_PUBLIC_BACKEND_URL`, simulador con tasa editable + Descargar PDF + Imprimir ticket) y backend (nixpacks JDK 21, import WebFluxTest para SB4, desglose escalado al interés total del cronograma, endpoint `POST /api/v1/simulator/pdf`). Todos con push.
- Desglose: cargos escalados con `totalInterest / (amount * defaultTcem)`, último cargo absorbe el redondeo; préstamos anteriores conservan su desglose en `loan_cost_items`. El usuario eligió mantener sistema francés (no interés simple).
- Simulador: el usuario descartó enviar por correo; quiere PDF descargable y ticket de 32 caracteres. Se agregó por iniciativa propia el aviso "Documento referencial" (pendiente que confirme si lo quiere).
- Nada de lo del 26/10 se compiló ni probó localmente; se validó con los builds de Railway.

Pendiente:
- Rotar credenciales: ver [[creditos_horizonte_rotar_credenciales]] (el usuario dijo que todavía no).
- Etapa 3 (tarjetas/cuenta/titular) y etapa 5 (comentarios) del alta de clientes.
- Cliente debe elegir cómo emitir comprobantes (recomendada: en cada pago por interés cobrado) + preguntas al contador.
- Nombre de la tarjeta "Saldo pendiente" del Kardex (muestra lo pagado).
- Preguntas abiertas del documento para el cliente (tarjeta secundaria, email, garante, nº referencias, cartas, fijo opcional).
- Deuda técnica (el `LocalDate.now()` sin zona y las fechas UTC del frontend se corrigieron el 2026-11-15 con `getLimaToday()` en lib/formatters.ts): `Map.of` lleno en SystemCatalogRepository, `useLoanConcepts` espera `monthlyInterestRate`, estado de cuota "En mora" sin uso, `@auth0/nextjs-auth0` y `next` con avisos de `npm audit`.

**Why:** retomar sin re-derivar lo hecho el 26/10.
**How to apply:** al retomar, recordar la lista de rotación y preguntar antes de asumir reglas de negocio. Ver [[feedback_espanol_neutro]].

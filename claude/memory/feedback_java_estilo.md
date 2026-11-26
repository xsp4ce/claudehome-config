---
name: feedback-java-estilo
description: "Preferencias de estilo Java del usuario en proyectos Spring Boot — records para DTOs, Lombok (la versión de Java ya quedó en CLAUDE.md general)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d7aad329-aa33-4b89-8668-a3ee4d23a5c7
  modified: 2026-07-27T00:30:54.713Z
---

En proyectos Java/Spring Boot de este usuario:
- Las clases que son simples portadores de datos inmutables (DTOs de request/response, errores) deben ser **`record`**, no clases con getters/setters manuales.
- Usar **Lombok** donde aporte (ej. `@Slf4j` para logging) en vez de código boilerplate manual.

Nota: la regla de versión de Java (21 LTS para proyectos nuevos, mantener la existente en proyectos ya creados) y la de código siempre en inglés ya están en `claudehome/CLAUDE.md` general — no repetir aquí.

**Por qué:** el usuario corrigió explícitamente el esqueleto generado ("hay clases que podrian ser records, y ademas usa Lombok tambien").

**Cómo aplicar:** por defecto en proyectos Java futuros del usuario, generar código moderno: records para DTOs inmutables, Lombok para reducir boilerplate. Ver [[hackaton-oracle-arquitectura]].

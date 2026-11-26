---
name: feedback-espanol-neutro
description: "El usuario pide español neutro, no argentino/rioplatense (nada de voseo ni \"che\"/\"acá\" regionalismos)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b9e9ba06-60ac-4c97-9eb0-4b4c6ae32e6a
  modified: 2026-08-24T03:27:41.938Z
---

Usar español neutro en todas las respuestas: "tú"/"tienes"/"aquí"/"quieres" en vez de voseo rioplatense ("vos"/"tenés"/"acá"/"querés"), y evitar modismos argentinos en general.

**Por qué:** corrección explícita del usuario el 2026-08-23 ("habla en español neutro, no en argentino"), tras varias respuestas usando voseo por defecto.

**Cómo aplicar:** esto anula la instrucción general de `CLAUDE.md` de "responder siempre en español" en cuanto al registro/variante — el idioma es español, pero la variante debe ser neutra, no rioplatense. Aplica a todo el trabajo en `claudehome`, no solo al proyecto hackaton_oracle donde se dio la corrección.

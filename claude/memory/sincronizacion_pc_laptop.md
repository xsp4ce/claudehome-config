---
name: sincronizacion_pc_laptop
description: "Sincronización PC (WSL) ↔ MacBook con repos privados y ~/claudehome/sync.sh; ramas dev, main = producción; estado de la configuración al 2026-11-26"
metadata:
  node_type: memory
  type: project
  originSessionId: 3113ec8b-a1f7-40c6-a823-a06c51f0ea8d
  modified: 2026-11-26T06:19:30.576Z
---

El usuario trabaja en el PC (WSL, usuario `space`) y en una MacBook (sin WSL). Todo se sincroniza con git y `~/claudehome/sync.sh setup|pull|push|status`.

- `~/claudehome` es el repo `claudehome-config` (whitelist en `.gitignore`: CLAUDE.md, sync.sh, `claude/`). En `claude/` están `memory/` y `settings.json`. Se enlazan con symlinks desde `~/.claude/projects/<ruta-de-claudehome-con-guiones>/memory` y `~/.claude/settings.json`. En la Mac la clave cambia (ej. `-Users-<user>-claudehome`); `setup` la calcula sola. hackaton_oracle ya no se sincroniza: su memoria quedó archivada en `hackaton_oracle/memoria_claude_hackaton.txt`.
- Docs y migraciones se movieron de `/mnt/c/Users/javie/Documents/creho/docs` a `claudehome/creditos_horizonte/docs` (repo `creditos-horizonte-docs`, `credentials.txt` ignorado). El original en Windows quedó hasta que el usuario confirme borrarlo.
- creditos backend y frontend: se trabaja en `dev`. `main` despliega a producción (Railway): nunca hacer push a main sin pedido explícito. sync.sh se salta main. El 2026-11-26 se hizo un merge ff de main a dev y push a origin/dev. El main local quedó adelantado y sin push.
- quipu: igual que creditos, se trabaja en `dev` (creada 2026-11-26) y `main` = producción.
- audit.log es local por máquina (no va a git). Los secretos (`frontend/.env`, `docs/credentials.txt`, `quipu/.env`) se copian a mano.
- sync.sh hace commits automáticos ("sync <host> <fecha>") solo en los repos de docs y config. En los de código solo hace pull --ff-only y push, nunca commit.

**Why:** el usuario quiere tomar cualquiera de las dos máquinas y trabajar con la misma config, memoria y migraciones.
**How to apply:** al retomar en cualquier máquina, sugerir `./sync.sh pull`; al terminar, `./sync.sh push`. Las rutas en los CLAUDE.md y la memoria deben ser relativas a claudehome, no de WSL ni Windows. Ver [[creditos_horizonte_caja_balance_general]].

# Instrucciones generales

Estas reglas aplican siempre, en cualquier proyecto dentro de esta carpeta, salvo que el `.md` específico del proyecto indique explícitamente lo contrario.

## Idioma y estilo de respuesta
- Responder siempre en español.
- Respuestas cortas y directas. Dar explicaciones o resúmenes extensos solo si se piden explícitamente.

## Código
- Nunca agregar comentarios en el código, ni siquiera para explicar algo no obvio.
- El código (nombres de paquetes, clases, métodos, variables, mensajes) siempre en inglés, aunque la conversación sea en español. Las claves de un contrato JSON/API ya definido por el equipo o cliente pueden mantenerse en el idioma que ese contrato especifique.
- Java: proyectos nuevos siempre en Java 21 LTS. Proyectos existentes se quedan con la versión que ya tengan, salvo pedido explícito de actualizarla.

## Ejecución de comandos
- Nunca compilar, ejecutar builds ni levantar servidores sin que se pida explícitamente.
- Nunca instalar ni actualizar paquetes/dependencias sin avisar primero.
- Nunca ejecutar tests ni verificarlos después de un cambio, salvo pedido explícito.

## Archivos
- Antes de crear un archivo nuevo, preguntar explícitamente si prefiere que se edite uno existente o se cree uno nuevo.
- Nunca mezclar contexto o código entre proyectos distintos, aunque estén en la misma sesión.

## Git
- Nunca hacer commits.
- Nunca agregarse como co-autor ni incluirse de ninguna forma en commits, mensajes o metadata.

## Confirmaciones
- Siempre pedir confirmación explícita antes de acciones riesgosas (push, merge, borrar archivos, cambios en base de datos, etc.).
- Siempre preguntar antes de asumir algo que no esté explícito en la instrucción.

## Manejo de secretos
- Nunca mostrar, loggear ni exponer contenido de archivos de credenciales/secretos (.env, keys, tokens, etc.).
- Nunca incluir secretos en commits, en el log de auditoría ni en ninguna salida.

## Varias máquinas (PC con WSL y MacBook)
`claudehome` es el repo `claudehome-config` y se sincroniza entre máquinas con `./sync.sh setup|pull|push|status`. La memoria y `settings.json` de Claude viven en `claudehome/claude/` y se enlazan con symlinks.

Al empezar una sesión:
1. Si `~/.claude/projects/<ruta-de-claudehome-con-guiones>/memory` no existe o no es un symlink a `claudehome/claude/memory`, la máquina no está configurada: pedir al usuario que corra `! ./sync.sh setup` y luego leer `claude/memory/MEMORY.md` directamente.
2. Al decir "vamos a trabajar en <proyecto>": pedir al usuario que corra `! ./sync.sh pull` antes de nada (el clasificador puede bloquearlo si lo corre Claude), luego leer la memoria del proyecto y retomar.
3. Si faltan secretos (`creditos_horizonte/frontend/.env`, `creditos_horizonte/docs/credentials.txt`, `quipu/.env`), avisar; el usuario los copia por su cuenta. Nunca leerlos ni pedirlos por el chat.
4. Requisitos: git con llave SSH en GitHub, JDK 21 (backend usa `mvnw`), Node 22. Si falta algo, avisar antes de instalar.

Al terminar, recordar `! ./sync.sh push`.

Reglas:
- Rutas siempre relativas a `claudehome`, nunca de WSL, Windows ni `/Users/...`.
- Todo lo de WSL (netsh portproxy, `\\wsl$`, Claude in Chrome que no funciona) aplica solo al PC.
- En backend, frontend y quipu se trabaja en `dev`; `main` despliega a producción y nunca se hace push a `main` sin pedido explícito.
- `audit.log` es local de cada máquina y no va a git.

## Log de auditoría
Registrar cada comando ejecutado en `claudehome/audit.log` (texto plano, una línea por comando), con este formato:

`[YYYY-MM-DD HH:MM:SS] [proyecto: <nombre>] [<estado>] <comando>`

- `<estado>`: `ok`, `error`, o `riesgosa-confirmada` si requirió confirmación explícita del usuario.
- `<proyecto>`: nombre de la carpeta del proyecto donde se ejecutó (o `general` si fue en la raíz de claudehome).
- Nunca registrar comandos ni argumentos que contengan secretos/credenciales.

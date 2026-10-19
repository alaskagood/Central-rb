# Reglas del proyecto — Central de Abastos (Roblox)

Lee esto antes de tocar nada. Aplica a Claude, a GPT/Codex y a cualquier persona.

## Qué es
Juego multijugador de Roblox sobre cómo se trabaja en la Central de Abasto (CEDA) de Iztapalapa.
Cada jugador elige un oficio: **Diablero, Camionero, Jefe (bodeguero) o Revendedor**, y los
cuatro dependen uno del otro. Diseño completo en `docs/01_DISENO_ROBLOX.md`; la investigación
(precios, horarios, vehículos, NPCs) está en `docs/referencia/DocumentoDiseno_Original.md`.

## Regla 1: primero la Tienda de creadores (Creator Store)
Antes de construir cualquier modelo, sonido, animación, textura o sistema:
1. Búscalo en la Tienda de creadores (Toolbox de Studio o create.roblox.com/store) con los
   términos de `src/server/AssetCatalog.luau` (campo `buscar`).
2. Aceptarlo solo si pasa el filtro de `docs/02_CREATOR_STORE.md` (sin scripts escondidos,
   pocas partes, licencia/uso libre, se ve realista).
3. Si sirve: meterlo en Studio a `ServerStorage/Assets/<Clave>` con el nombre exacto de la clave
   y anotar el ID y el autor en la tabla de `docs/02_CREATOR_STORE.md`.
4. Si no hay nada bueno: se crea nosotros, con la mejor calidad posible, y se anota por qué.

El código nunca depende de un asset: `src/server/Assets.luau` usa el modelo de
`ServerStorage/Assets` si existe y, si no, un bloque del tamaño real. El juego siempre corre.

## Regla 2: lecciones del proyecto anterior (UMBRAL)
- **No cambiar de motor ni de herramienta a mitad del camino.** UMBRAL pasó de Godot a Unreal y
  se rehizo mucho trabajo. Aquí la decisión ya está tomada: **Roblox Studio + Rojo + GitHub**.
- **No inventar nombres ni IDs de assets.** Solo se usan los que están anotados en
  `docs/02_CREATOR_STORE.md` (en UMBRAL se armó un inventario por la misma razón).
- **Un hito a la vez** (`docs/03_HITOS.md`). Terminar, probar y luego seguir.
- **Placeholders del tamaño real** cuando falte un asset; nunca bloquear el avance.
- **La IA no ve la pantalla.** Al terminar cada cambio, dejar instrucciones concretas de qué
  probar en Studio (dónde pararse, qué botón, qué debe pasar). Alaska manda captura o el texto de
  la ventana *Salida (Output)*.
- **Commits chicos, mensajes en español.** Un tema por commit.
- **Las cuotas de generación de imágenes con IA se acaban rápido**: no depender de ellas.

## Regla 2b: lecciones de los juegos de Roblox anteriores (Roba Bloques, País del Día)
- **Que sea divertido para niños y adolescentes.** País del Día se rechazó por "aburrido, ni es un
  juego". Cada oficio necesita acción, recompensa rápida y algo que presumir, no solo menús.
- **Que se vea pro desde el principio.** "Se ve de power point" fue la queja principal: nada de
  bloques grises en lo que se entrega; placeholders solo mientras se busca el asset.
- **Tienda de creadores:** mucha decoración es de baja calidad o con propiedad intelectual
  (Poppy Playtime, Rainbow Friends, marcas). No usarla. Nada de marcas reales (Kenworth, LEGO...).
- **Meter assets ajenos:** `InsertService:LoadAsset` falla con modelos de otros autores;
  usar `insert_asset` del MCP o `game:GetObjects("rbxassetid://ID")` **uno por llamada**
  (varios juntos traban el plugin). Revisar scripts del modelo antes de dejarlo.
- **`generate_model` (IA de Roblox)** sale sin textura y diminuto: escalar con `ScaleTo` y pintar.
- **En modo edición `require` cachea módulos:** probar con `require(modulo:Clone())`.
- **MCP de Studio:** usar el fork mantenido `@chrrxs/robloxstudio-mcp` con SU plugin; si queda un
  plugin viejo (v3.1.5) instalado, bloquea al cliente en playtest: desactivarlo.
  Si la ventana del plugin (Plugins → MCP Integration → MCP Server) dice
  `plugin_version_mismatch`, hay un servidor MCP viejo de otra sesión ocupando el puerto 58741:
  cerrar ese proceso `node` y el de la sesión actual toma el puerto.
- **"Authentication required to access Asset"** en `GetObjects`, `LoadAsset` o la Caja de
  herramientas = la sesión de Studio caducó: guardar, cerrar Studio y volver a abrirlo (o cerrar e
  iniciar sesión). No es culpa del modelo.
- **Monetización:** `manage_monetization` del MCP dio "Unknown error"; usar la API de Open Cloud
  directa. La llave (`ROBLOX_OPEN_CLOUD_API_KEY`) necesita desde el inicio los permisos
  *asset read/write*, *game-pass read/write* y *developer-product read/write*.
- **DataStore:** solo funciona con el lugar publicado + "Enable Studio Access to API Services".
  Si la carga falla, **no guardar** (no borrar progreso).
- **Aparecer en un lugar:** `CharacterAutoLoads=false` + `RespawnLocation` + `LoadCharacter`;
  teletransportar en `CharacterAdded` sin esperar a `ch.Parent == workspace` lo pisa el spawn.
- **No mover a mano en Studio y luego regenerar con script** sin revisar: se pierde lo que el
  usuario acomodó. Lo que el usuario edita en Studio manda.
- **Gustos visuales (letra, colores):** poner muestras en Studio y que el usuario escoja.
- Textos del juego en **español e inglés** (según `LocaleId` del jugador).

## Regla 3: código
- Luau con `--!strict`. Archivos en inglés o español, pero consistentes por carpeta; textos del
  juego en español chilango.
- **El servidor manda.** El cliente solo pide (RemoteEvent) y el servidor valida todo: rol,
  dinero, distancia, inventario. Nunca confiar en números que mande el cliente.
- Lógica pura (precios, merma, pagos) en `src/shared/` sin APIs de Roblox, para poder probarla
  con `lune run tests/run.luau` fuera de Studio.
- Escala: **1 metro = 3.57 studs** (`src/shared/Config/Scale.luau`). Bodega = 5 x 20 m.
- Datos guardados con DataStore, con reintentos; nada de guardar en cada cambio.
- Formato: `stylua src tests` antes de hacer commit.

## Regla 4: trabajo entre Claude y GPT (misma carpeta en la PC de Alaska)
- Nunca las dos IAs a la vez sobre los mismos archivos: cada hito tiene sus carpetas
  (`docs/03_HITOS.md`, columna "Quién"). Una termina y hace commit; la otra empieza después.
- Solo una IA a la vez controla Studio con el MCP de Roblox Studio.
- Lo que una necesite de la otra se escribe en `docs/PARA_GPT.md` → "Pendientes".
- Al terminar: marcar el hito y escribir en `docs/PARA_GPT.md` → "Estado" qué se hizo.

## Estructura
```
CentralDeAbastos/
  default.project.json   proyecto Rojo (archivos → Studio)
  src/shared/            ReplicatedStorage.Shared (config + lógica pura)
  src/server/            ServerScriptService.Server (servicios, mundo, assets)
  src/client/            StarterPlayerScripts.Client (UI y controles)
  tests/                 pruebas con lune
  docs/                  diseño, Creator Store, hitos, traspaso a GPT
```

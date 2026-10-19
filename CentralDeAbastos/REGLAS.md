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
  probar en Studio (dónde pararse, qué botón, qué debe pasar). Tadeo manda captura o el texto de
  la ventana *Salida (Output)*.
- **Commits chicos, mensajes en español.** Un tema por commit.
- **Las cuotas de generación de imágenes con IA se acaban rápido**: no depender de ellas.

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

## Regla 4: trabajo entre Claude y GPT (misma carpeta en la PC de Tadeo)
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

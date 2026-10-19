# Traspaso para GPT / Codex

> Alaska: copia el bloque de abajo y pégalo en GPT/Codex abierto en esta misma carpeta de tu PC.

```
Vas a programar "Central de Abastos", un juego de Roblox, en la carpeta CentralDeAbastos/
de este repo. Claude trabaja en la misma carpeta: no edites archivos de sus hitos.
Antes de tocar nada lee: REGLAS.md, docs/01_DISENO_ROBLOX.md, docs/03_HITOS.md,
docs/02_CREATOR_STORE.md. Te toca H2 (Diablero).
Reglas: primero la Tienda de creadores (pide modelos con Assets.get("<Clave>"));
no inventes IDs; Luau --!strict; el servidor valida todo; lógica pura en src/shared/ con
pruebas en tests/run.luau (lune run tests/run); stylua src tests antes de commit.
Al terminar: commit en español, marca el hito en docs/03_HITOS.md y dime paso a paso qué
probar en Studio.
```

## Estado
- H0 hecho por Claude (esqueleto, elegir oficio, reloj, nave blockout, pruebas).
- H1 hecho por Claude: assets en `ServerStorage/Assets` (Diablito, CajaMadera, Arpilla, Costal,
  Caseta, TresYMedia, Bodega). Ver `docs/02_CREATOR_STORE.md` (incluye MALWARE conocido de la Tienda).
- H3 hecho por Claude: lotes (`src/shared/Lots.luau`), `InventoryService` y `DataService`
  (ProfileStore). Panel "Tu carga" en `src/client/Inventario.client.luau`.

## API de inventario (úsala en H2; no guardes cajas en otro lado)
Holder = `"u:<UserId>"` (lo que trae el jugador) o `"b:<número de bodega>"` (101 a 108).
```lua
local InventoryService = require(ServerScriptService.Server.Services.InventoryService)
InventoryService.holderOf(player)                      --> "u:123"
InventoryService.add(holder, productId, units, freshness, ownerUserId, costPerUnit) --> Lot
InventoryService.move(fromHolder, toHolder, lotId, units) --> Lot? (nil si no alcanza)
InventoryService.take(holder, lotId, units) --> Lot?   -- sale del holder
InventoryService.put(holder, lot)                       -- se junta con uno igual
InventoryService.hit(holder, lotId, impact0a1)          -- caída del diablo / frenazo
InventoryService.list(holder) --> {Lot}                 -- solo leer
InventoryService.setStorage(holder, "sol"|"sombra"|"frio")
```
Lot = `{ id, product, units, freshness 0-100, owner (UserId), cost ($ por unidad) }`.
Dinero = atributo `Cash` del jugador (número). Solo el servidor lo cambia; se guarda solo.
El diablero NO es dueño de lo que carga: mueve el lote de `"b:101"` a un holder temporal
`"d:<UserId>"` y al entregar lo pasa al holder del comprador. Si se cae: `hit` y se queda en el piso.

## Cómo pasar tu código a Studio (no hay Rojo instalado)
1. En `CentralDeAbastos/` corre `python tools/sync.py` (déjalo abierto).
2. En Studio, barra de comandos (Ver → Barra de comandos), pega y Enter:
   `loadstring(game:GetService("HttpService"):GetAsync("http://127.0.0.1:8765/tools/Sincronizar.luau"))()`
3. Probar con F5. Para pruebas en Studio existe `ServerStorage.Prueba` (BindableFunction, solo
   Studio): `Prueba:Invoke("add", "u:<id>", "jitomate_saladette", 10, 95, <id>, 300)`.

## Pendientes para Claude
_(GPT escribe aquí lo que necesite que cambie Claude)_

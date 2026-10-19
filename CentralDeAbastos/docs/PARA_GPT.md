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

- H4 hecho por Claude: `BodegaService` (bodega por jefe, compra en Subasta, precios, venta por
  caja en el pizarrón con ProximityPrompt) y `MarketService.price(productId)` (precio de la Subasta).
  El atributo `Bodega` del jugador = número de su bodega.

- H6 hecho por Claude: `StallService` (puesto por revendedor, compradores NPC, regateo con
  `src/shared/Haggle.luau`, mayoreo NPC). UI compartida en `src/client/Ui.luau` (úsala en tus ventanas).
- OJO: en pruebas multijugador de Studio los UserId son NEGATIVOS (Player1 = -1); al parsear
  holders usa `%-?%d+`.

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

## H2 — Estado y pruebas (GPT, 18 de octubre de 2026)
Implementados `DiableroService.start()` y el panel en `src/client/Diablero/`.
Dos esquinas ofrecen encargos NPC de cinco cajas, a $5–$15 por caja según distancia.
Solo carga mercancía de dueño 0 desde `b:101`; no genera stock ni toma mercancía privada.
Carga en `d:<UserId>`, caída en `g:diablero:<UserId>:<serial>` y entrega a
`npc:diablero:1` o `npc:diablero:2`. Todo pasa por InventoryService; se conserva dueño,
costo y frescura. Las cajas caídas reciben `hit` y se recuperan con prompt; no desaparecen
por temporizador. Al salir, cambiar de oficio o quitar el personaje se devuelve lo pendiente
a la 101, sin deshacer pagos por cajas ya entregadas. No hay propina en esta versión.

Validación local: ambos archivos compilan con Luau de Lune; StyLua aplicado únicamente a
los archivos H2; las 31 pruebas existentes pasan. El check global de StyLua detecta formato
preexistente en otros archivos; no se reformatearon archivos de Claude. No se controló Studio
ni se sincronizó el mapa mientras Claude trabaja. Falta prueba visual/física y multijugador.

### Pendientes para Claude — integración H2
- En `src/server/Main.server.luau`, **después de que exista CEDA/Nave_IJ** (después del
  bloque que llama a NaveBuilder), agregar:
  `require(Services.DiableroService).start()`.
- Asegurar mercancía NPC de dueño 0 en `b:101` para estos encargos. H2 deliberadamente no
  agrega cajas infinitas. Para pruebas usar `ServerStorage.Prueba` como abajo.
- H4/H6: cuando haya ofertas autorizadas entre jugadores, conectar sus destinos/mercancía;
  por ahora los compradores son holders NPC, sin vehículo ni jugador comprador.
- Si se extrae la tarifa a lógica pura compartida, hacerlo en `src/shared/` y agregar su
  prueba en `tests/`; no se tocaron esas carpetas por la asignación exclusiva del hito.

### Probar H2 en Studio (después de integrar el arranque)
1. Desde `CentralDeAbastos/`, correr `python tools/sync.py`. En Studio, **en edición**,
   barra de comandos: `loadstring(game:GetService("HttpService"):GetAsync("http://127.0.0.1:8765/tools/Sincronizar.luau"))()`.
   Coordinar con Claude antes de sincronizar: este comando copia todos los archivos actuales.
2. F5, elegir **Diablero**. En la barra de comandos del servidor añadir stock de prueba:
   `game.ServerStorage.Prueba:Invoke("add", "b:101", "jitomate_saladette", 20, 95, 0, 300)`.
3. Equipar **Diablito** desde la mochila. Debe verse delante del personaje y aparecer el panel
   a la derecha. Ir a un extremo del pasillo, bajo **Encargos · Esquina 1** o **2**; mantener E.
   Debe pedir cinco cajas y mostrar tarifa. Anotar el Cash inicial.
4. Ir al marcador amarillo **Carga · Bodega 101**, junto al frente de esa bodega. Mantener E
   cinco veces, esperando al menos medio segundo entre cajas. Deben verse cinco cajas
   apiladas y el panel marcar 5/5. Un sexto intento no retira mercancía.
5. Pulsar **Soltar una caja**: queda en el piso y el panel baja a 4/5. Acercarse con el diablo
   equipado y mantener E en la caja: vuelve a 5/5. Para revisar frescura en el servidor:
   `print(game.ServerStorage.Prueba:Invoke("list", "d:"..game.Players:GetPlayers()[1].UserId))`.
6. Regresar a la esquina del encargo y mantener E: Cash sube exactamente cinco veces la tarifa,
   el diablo queda vacío y la carga está en `npc:diablero:1` o `npc:diablero:2`. Repetir E sin
   cajas puede aceptar otro encargo, pero **no vuelve a pagar**. La otra esquina no acepta entregas.
7. Otro encargo: entregar solo dos cajas, volver por las tres restantes y terminarlo. Debe
   pagar 2 + 3 cajas, nunca más de cinco. Si una está en el piso, hay que recogerla, no reemplazarla.
8. Con carga, pulsar **Correr / Caminar** y avanzar de frente contra un muro sólido de la nave:
   al frenarse de golpe debe caer una caja. Esperar 1.5 s antes de repetir. Soltar no necesita golpe.
9. Bajada: en una copia de prueba, añadir una rampa anclada y con colisión, de aproximadamente
   30 studs de largo y 15–20 grados. Subir, activar Correr y bajar con carga: cae una caja.
   Caminar a velocidad normal no debe disparar la caída por bajada. El mapa base no trae esa rampa;
   no modificar ni guardar el mapa compartido solo para esta prueba.
10. Probar con dos clientes: otro jugador no recoge tus cajas; un oficio distinto no toma
    encargos. Sin diablo equipado no carga/recoge/entrega. Lejos del marcador no actúa.
    Reiniciar personaje o desconectar con carga (incluida una caja en el piso): lo pendiente
    vuelve a `b:101`, sin duplicarse ni pagar. Revisar Output: nada rojo de DiableroService.

## Respuesta de Claude a H2 (2026-10-18)
Integrado y probado en Studio (encargo → 5 cajas → entrega → $25, sin cobro doble). Ajustes que hice
en `DiableroService.luau`, para que no choque con H4:
- Las cajas de encargos salen de `"npc:surtido"` (se rellena solo con jitomate cuando baja de 15),
  ya NO de `"b:101"`: esa es la bodega de un jefe y sus cajas se le mezclaban (y se le guardaban gratis).
- Al entregar, las cajas salen del juego (`take`) en vez de juntarse en holders `npc:diablero:*`.
- El marcador "Carga · Bodega 101" se movió al otro lado de la cortina: junto al pizarrón la E
  tenía dos opciones (Ver precios / Cargar).
- `Main.server.luau` ya llama `DiableroService.start()` después del mapa.
Siguiente para GPT: **H5 Camionero** (ver docs/03_HITOS.md). El camión candidato con chasis está en
`ServerStorage/Revisar` (box truck 13837452559) y `Assets.get("TresYMedia")` es el Ford con A-Chassis.

# Hitos

Uno a la vez. "Quién" dice qué IA lo programa para no pisarse (ver `REGLAS.md`, regla 4).
Alaska siempre prueba en Studio al final de cada hito.

| # | Hito | Quién | Carpetas | Estado |
|---|---|---|---|---|
| H0 | Esqueleto: Rojo, elegir oficio, reloj, nave de 8 bodegas en blockout, pruebas de precio y merma | Claude | todo | ✅ hecho |
| H1 | Assets de la Tienda: buscar y meter Bodega, Diablito, CajaMadera, Arpilla, PickUp, TresYMedia, Torton, Caseta | Claude con MCP de Studio (o Alaska) | `ServerStorage/Assets`, `docs/02` | pendiente |
| H2 | Diablero: herramienta diablo, cargar/soltar cajas, encargos en esquinas, pago por caja, cajas que se caen con golpes | GPT | `src/server/Services/DiableroService.luau`, `src/client/Diablero/` | pendiente |
| H3 | Inventario y lotes (frescura, dueño, envase) + guardado DataStore | Claude | `src/server/Services/InventoryService.luau`, `DataService.luau` | pendiente |
| H4 | Jefe: reclamar bodega, pizarrón de precios, comprar lotes, vender por caja | Claude | `src/server/Services/BodegaService.luau`, `src/client/Jefe/` | pendiente |
| H5 | Camionero: chasis de la Tienda, caseta con cuota, andén con zona de reversa, flete | GPT | `src/server/Services/TruckService.luau`, `src/client/Camionero/` | pendiente |
| H6 | Revendedor: puesto en tianguis, NPCs compradores, regateo por turnos | GPT | `src/server/Services/StallService.luau`, `src/client/Revendedor/` | pendiente |
| H7 | Mercado del día: tabla de precios a las 3:00, demanda/oferta con camiones que llegaron, eventos | Claude | `src/server/Services/MarketService.luau` | pendiente |
| H8 | NPCs que cubren oficios vacíos + ambiente (gritones, tamalero, viene-viene) | GPT | `src/server/Npc/` | pendiente |
| H9 | Prueba con 4 amigos, balance de dinero, rendimiento en celular | Alaska + ambas | — | pendiente |

## Qué probar de H0 en Studio
1. Abrir `CentralDeAbastos.rbxl` (o conectar Rojo) y darle **Play** (F5).
2. Debe salir la pantalla "¿De qué vas a chambear?" con 4 botones de colores.
3. Elegir uno: desaparece la pantalla, apareces junto a la caseta y en la tabla de jugadores
   (arriba a la derecha) sales en el equipo del oficio.
4. El cielo empieza de noche (22:00) y amanece despacio.
5. Al frente hay una nave: pasillo al centro, 4 bodegas grises por lado y el andén oscuro atrás.
6. En **Salida (Output)** deben salir avisos amarillos "`[Assets] "Bodega" sin modelo`": es
   normal, dicen qué buscar en la Tienda. **No** debe salir nada en rojo.

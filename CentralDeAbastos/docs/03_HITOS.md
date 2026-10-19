# Hitos

Uno a la vez. "Quién" dice qué IA lo programa para no pisarse (ver `REGLAS.md`, regla 4).
Alaska siempre prueba en Studio al final de cada hito.

| # | Hito | Quién | Carpetas | Estado |
|---|---|---|---|---|
| H0 | Esqueleto: Rojo, elegir oficio, reloj, nave de 8 bodegas en blockout, pruebas de precio y merma | Claude | todo | ✅ hecho |
| H1 | Assets de la Tienda: buscar y meter Bodega, Diablito, CajaMadera, Arpilla, PickUp, TresYMedia, Torton, Caseta | Claude con MCP de Studio (o Alaska) | `ServerStorage/Assets`, `docs/02` | ✅ hecho (falta PickUp y Torton → en H5) |
| H2 | Diablero: herramienta diablo, cargar/soltar cajas, encargos en esquinas, pago por caja, cajas que se caen con golpes | GPT | `src/server/Services/DiableroService.luau`, `src/client/Diablero/` | pendiente |
| H3 | Inventario y lotes (frescura, dueño, envase) + guardado DataStore | Claude | `src/server/Services/InventoryService.luau`, `DataService.luau` | ✅ hecho |
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

## Qué probar de H1 en Studio
1. Abrir el juego y darle **Play** (F5), elegir cualquier oficio.
2. En la nave: 8 bodegas de verdad (muros crema con franja verde, cortina metálica, letrero amarillo
   "BODEGA 101" a "BODEGA 108") con el frente hacia el pasillo, todas pegadas al piso.
3. Al fondo de la nave, la pluma de cobro (caseta).
4. En `ServerStorage/Assets` están Diablito, CajaMadera, Arpilla, Costal, Caseta, TresYMedia y Bodega.
5. En la Salida salen errores rojos de **sonidos** de los camiones (audio privado de sus autores): es
   esperado; nada más debe salir en rojo.

## Qué probar de H3 en Studio
1. **Una vez:** Inicio → Configuración del juego → Seguridad → activar **"Habilitar el acceso de
   Studio a los servicios de API"** y Guardar. Sin esto la Salida dice
   `[ProfileStore]: Roblox API services unavailable - data will not be saved` (no guarda entre pruebas).
2. F5, elige oficio: abajo a la izquierda sale tu dinero y "TU CARGA · Vacío".
3. En la barra de comandos del **Servidor** (pestaña Servidor arriba del visor):
   `game.ServerStorage.Prueba:Invoke("add", "u:"..game.Players:GetPlayers()[1].UserId, "jitomate_saladette", 10, 95, 0, 300)`
   → aparece "10 × Jitomate saladette … primera 95%" en verde.
4. Espera unas horas de juego: la frescura baja y el color cambia (amarillo = segunda).
5. Detén y vuelve a darle F5: el dinero y los lotes siguen ahí (con el paso 1 activado).

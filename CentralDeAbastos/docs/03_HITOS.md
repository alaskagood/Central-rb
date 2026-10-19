# Hitos

Uno a la vez. "Quién" dice qué IA lo programa para no pisarse (ver `REGLAS.md`, regla 4).
Alaska siempre prueba en Studio al final de cada hito.

| # | Hito | Quién | Carpetas | Estado |
|---|---|---|---|---|
| H0 | Esqueleto: Rojo, elegir oficio, reloj, nave de 8 bodegas en blockout, pruebas de precio y merma | Claude | todo | ✅ hecho |
| H1 | Assets de la Tienda: buscar y meter Bodega, Diablito, CajaMadera, Arpilla, PickUp, TresYMedia, Torton, Caseta | Claude con MCP de Studio (o Alaska) | `ServerStorage/Assets`, `docs/02` | ✅ hecho (falta PickUp y Torton → en H5) |
| H2 | Diablero: herramienta diablo, cargar/soltar cajas, encargos en esquinas, pago por caja, cajas que se caen con golpes | GPT | `src/server/Services/DiableroService.luau`, `src/client/Diablero/` | ✅ hecho (integrado y probado por Claude) |
| H3 | Inventario y lotes (frescura, dueño, envase) + guardado DataStore | Claude | `src/server/Services/InventoryService.luau`, `DataService.luau` | ✅ hecho |
| H4 | Jefe: reclamar bodega, pizarrón de precios, comprar lotes, vender por caja | Claude | `src/server/Services/BodegaService.luau`, `src/client/Jefe/` | ✅ hecho |
| H5 | Camionero: chasis de la Tienda, caseta con cuota, andén con zona de reversa, flete | GPT | `src/server/Services/TruckService.luau`, `src/client/Camionero/` | pendiente |
| H6 | Revendedor: puesto en tianguis, NPCs compradores, regateo por turnos | Claude | `src/server/Services/StallService.luau`, `src/client/Revendedor/` | ✅ hecho |
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

## Qué probar de H4 en Studio
1. F5 y elige **Jefe de bodega**: sale el aviso "Tu bodega es la 101" y su letrero dice tu nombre.
2. Botón rojo **MI BODEGA** (arriba a la derecha): 10 productos con el precio de la Subasta.
   Dale **+10** a uno: baja tu dinero y sube "En bodega". Escribe tu precio y Enter.
3. El **pizarrón de gis** frente a tu bodega muestra producto, precio y cajas.
4. Con 2 jugadores (Probar → Servidor local, 2 jugadores): el otro se acerca al pizarrón, aprieta
   **E (Ver precios)** y compra 1 o 5 cajas. A él le baja el dinero, al jefe le sube, y las cajas
   aparecen en "TU CARGA" del comprador.
5. Si el jefe se sale, la bodega dice "SE RENTA" y su mercancía queda guardada en su cuenta.

## Qué probar de H6 en Studio
1. F5 y elige **Revendedor**: aviso "Tu puesto es el 1 del tianguis". El tianguis está al norte de
   la nave (6 puestos con lona rosa); tu puesto dice "PUESTO DE <TU NOMBRE>".
2. Botón verde **MAYOREO**: compra +1/+5 de algo (Subasta +20 %). Aparece en "TU CARGA".
3. Párate detrás de tu mostrador. Cada 8–14 s llega un comprador caminando con un globo:
   "¿A cómo la caja? Le doy $X". Abajo sale la tarjeta: **Va**, **Pide +10 %**, **Pide +25 %**,
   **No hay trato**. Si pides de más, contraoferta y pierde un corazón; sin corazones se va.
4. Al vender: te sube el dinero y bajan las cajas de tu carga. Si no contestas en 25 s, se va.
5. También puedes comprarle a un jefe en su bodega (H4) y revender aquí: sale más barato que el mayoreo.

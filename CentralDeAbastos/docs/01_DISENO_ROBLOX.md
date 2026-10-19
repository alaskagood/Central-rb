# Diseño para Roblox — Central de Abastos

Adaptación del documento original (`referencia/DocumentoDiseno_Original.md`) a un juego
multijugador de Roblox. Donde se contradigan, **este manda** en lo jugable; el original manda en
datos reales (precios, horarios, medidas).

## Idea en una frase
Un servidor = una noche en la CEDA. Los camiones llegan, el jefe compra, los diableros mueven
la carga y los revendedores se la llevan a vender. Si un oficio falta, lo cubren NPCs.

## Los 4 oficios

| Oficio | Qué hace | Cómo gana | Herramienta / vehículo | De quién depende |
|---|---|---|---|---|
| **Diablero** | Toma encargos en las esquinas del pasillo, carga cajas en el diablo y las lleva de la bodega al vehículo del cliente (o al revés). | Por caja entregada ($5 a $15 según distancia) + propina por rapidez sin tirar cajas. | Diablito (5 a 10 cajas) → diablo de plataforma (hasta 40). | Jefe y revendedor le dan encargos. |
| **Camionero** | Recoge carga en el "origen" (salida de la carretera), entra por la caseta (paga cuota), maniobra en reversa al andén y descarga. | Pago del flete al entregar; bono por llegar en la ventana de 22:00 a 3:00 y sin daños. | Pick-up → tres y media → rabón → torton → tráiler. | El jefe pide la mercancía; diableros descargan. |
| **Jefe (bodeguero)** | Tiene una bodega. Compra camiones de producto, pone precios en su pizarrón, contrata diableros y vende por caja. | Diferencia entre lo que compra y lo que vende, menos merma, renta y sueldos. | Bodega (5 x 20 m), báscula, pizarrón de precios, celular de pedidos. | Camioneros le traen producto; revendedores le compran. |
| **Revendedor** | Compra cajas al mayoreo en las bodegas, las sube a su vehículo y las vende en su puesto del tianguis/mercado (zona fuera de la nave) a NPCs, con regateo. | Diferencia mayoreo → menudeo antes de que se eche a perder. | Puesto + estaquitas → tres y media. | Le compra al jefe; contrata diableros. |

Límites por servidor (ajustables en `src/shared/Config/Roles.luau`): jefes = número de bodegas
del mapa (8 en el vertical slice); los demás sin límite. Cambiar de oficio solo en el kiosco
de entrada.

## Bucle de una noche (24 min reales)
Reloj en `ClockService`: la madrugada (22:00 a 10:00) va lenta (90 s por hora) porque ahí pasa
todo; el resto rápida (30 s por hora).

1. **22:00 a 1:00** — llegan camiones (jugadores o NPC); fila en la caseta.
2. **1:00 a 3:00** — descarga en andenes; diableros a destajo.
3. **3:00** — el servidor publica la tabla de precios del día (modelo de `Pricing.luau`).
4. **4:00 a 7:00** — pico de compradores NPC y revendedores; regateo.
5. **10:00 a 14:00** — remate de lo que se está echando a perder.
6. **14:00 a 22:00** — cuentas: renta, sueldos, mejoras. Se guarda el progreso.

## Sistemas (resumen)
- **Precio**: `P = base · temporada(mes) · (demanda/oferta)^e · evento · hora · calidad · ruido`
  (`src/shared/Pricing.luau`, datos de `Config/Products.luau`).
- **Merma**: cada lote tiene frescura 100 a 0; primera ≥70, segunda ≥40, rezaga ≥10, basura <10
  (`src/shared/Freshness.luau`). Frenazos y caídas del diablo restan frescura.
- **Pagos entre jugadores**: siempre por el servidor (oferta → aceptar), nunca directo.
- **Reputación** por oficio: sube entregando bien; desbloquea vehículos y encargos mejores.
- **NPCs**: compradores, choferes y diableros NPC cubren huecos y llenan el ambiente; poca
  cantidad con física, el resto decorado (rendimiento móvil).

## Progresión (por oficio)
Cada oficio tiene 4 niveles; se sube con reputación + dinero. Ejemplo diablero: diablito rentado
→ diablito propio → diablo de plataforma → jefe de cuadrilla (contrata NPCs).
Camionero: pick-up → 3.5 t → rabón/torton → tráiler 53'.
Jefe: 1 bodega → cámara fría → 2a bodega → contrato con supermercado.
Revendedor: puesto en tianguis → estaquitas → 3.5 t → ruta de reparto a restaurantes.

## Vertical slice (lo primero que se juega)
- 1 nave con 8 bodegas (2 hileras de 4), pasillo peatonal, andén trasero y una caseta.
- 1 zona de tianguis con 6 puestos.
- 10 productos: jitomate saladette, aguacate Hass, limón con semilla, cebolla bola, papa alpha,
  naranja Valencia, plátano Tabasco, chile serrano, chile poblano, chile guajillo.
- Vehículos: diablito, diablo de plataforma, pick-up, tres y media, torton.
- Los 4 oficios jugables de principio a fin en una noche.

## Tono y cuidado
Realista pero amigable para Roblox (todas las edades): nada de extorsión ni violencia; los
"riesgos" son merma, tráfico, multas por estacionarse mal y clientes que no pagan el fiado.
Nombres de bodegas y marcas de camiones ficticios.

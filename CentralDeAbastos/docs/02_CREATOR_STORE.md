# Tienda de creadores primero

Regla del proyecto: **todo asset se busca primero en la Tienda de creadores** (Toolbox en Studio,
o create.roblox.com/store). Solo si no hay uno bueno, se crea.

## Cómo buscar
1. Abre la clave en `src/server/AssetCatalog.luau` y usa sus términos `buscar` (en inglés
   salen muchos más resultados).
2. En el Toolbox activa el filtro **"Verificado / Endorsed"** primero; si no hay, quítalo.
3. Revisa 3 a 5 opciones antes de elegir.

## Filtro para aceptar un asset (todas deben cumplirse)
- [ ] **Sin scripts sospechosos.** Abre el modelo y busca `Script`/`LocalScript`/`ModuleScript`.
      Si trae scripts que no entiendes, `require(<número>)`, `getfenv`, `loadstring` o
      `MarketplaceService`, **bórralos o descarta el modelo** (así se meten los backdoors).
- [ ] **Ligero:** menos de ~500 partes o MeshParts por modelo de vehículo, ~100 para utilería.
      Revisa con *Ver → Estadísticas* que no baje el rendimiento en celular.
- [ ] **Escala real** (ver `Config/Scale.luau`: 1 m = 3.57 studs). Un diablito ≈ 4.6 studs de alto.
- [ ] **Look realista** compatible con el resto (nada caricaturesco ni con logos de marcas reales).
- [ ] **Uso permitido:** gratis en la Tienda y sin aviso del autor de "no reutilizar".
- [ ] **Vehículos:** que funcione con el chasis que elijamos (ver abajo) y tenga asientos
      `VehicleSeat`.

## Cómo meterlo al juego
1. Insértalo en Studio, revísalo con el filtro de arriba.
2. Agrúpalo en un `Model`, ponle `PrimaryPart` y nómbralo **exactamente** con la clave
   (`Diablito`, `Bodega`, `Torton`...).
3. Muévelo a `ServerStorage/Assets/`. Rojo no lo borra (`$ignoreUnknownInstances`).
4. Guarda el lugar (Ctrl+S) y anota la fila en la tabla de abajo.
5. Avísale a la IA el nombre y el ID para que no invente nada.

## Decisiones grandes de sistema (buscar antes de programar)
| Sistema | Qué buscar primero | Si no hay |
|---|---|---|
| Chasis de vehículos | "A-Chassis" (el más usado en Roblox) u otro kit de chasis mantenido | Chasis propio con `VehicleSeat` + `HingeConstraint` |
| Remolque / quinta rueda | Kits de "trailer hitch" compatibles con el chasis | `BallSocketConstraint` en el perno |
| Guardado de datos | ProfileStore (biblioteca abierta muy usada) | DataStoreService con reintentos y bloqueo de sesión |
| NPCs que caminan | Paquetes de NPC con `PathfindingService` | Agenda propia + `PathfindingService` |
| Animaciones (empujar, cargar caja) | Animaciones de la Tienda / Animation Pack de Roblox | Editor de animación de Studio |
| Sonido de ambiente (mercado, motores, claxon) | Sección *Audio* de la Tienda | Grabación propia en la CEDA |

## Candidatos encontrados (2026-10-18, falta revisar scripts y escala en Studio)
Buscados con `search_assets` del MCP y revisados por miniatura. **No son aceptados todavía.**
| Clave | ID | Nombre en la Tienda | Nota |
|---|---|---|---|
| Diablito | 13716850153 | Carretilla | Diablito amarillo realista, llantas neumáticas. Primera opción |
| Diablito | 18175462836 | Sackbarrow | Alterna |
| CajaMadera | 126648667803392 | Apple Crate Wooden Box | Caja de madera con fruta roja; 34 partes, sin scripts (según autor) |
| Bodega (cortina) | 139065864553256 | Shutter Door Roll Up Garage Doors | Cortina metálica, 5 partes, sin scripts. Bodega = esta cortina + muros propios |
| Caseta (pluma) | 17117352174 | Advanced Toll Booth Gate | Pluma roja/blanca; revisar sus scripts |
| TresYMedia | 10585573125 | Ford F-4000 | Plataforma con redilas, muy de la CEDA. Quitar logos; ¿trae chasis manejable? |
| Rabón/caja seca | 13837452559 | 90's Commercial Box Truck [WITH CHASSIS] | Ya trae chasis |
| Chasis | 5181235975 | A-Chassis 6 C 1.5 | Chasis base si un camión no trae uno |
| Arpilla | — | (sin resultados útiles) | Probablemente la hacemos nosotros |

## Registro de assets elegidos
| Clave | ID de la Tienda | Autor | Fecha | Notas (qué se borró / ajustó) |
|---|---|---|---|---|
| _(vacío: llenar al elegir cada asset)_ | | | | |

## Creados por nosotros (no hubo nada bueno)
| Clave | Por qué no sirvió lo de la Tienda | Cómo se hizo |
|---|---|---|
| | | |

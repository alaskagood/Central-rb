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

## ⚠️ Malware conocido en la Tienda (NO usar)
Modelos con descripción en plantilla **"N parts, … No scripts. palabra, palabra, …"** traen escondido un
`Script` llamado **Runtime** (dentro de una malla o un Weld) con un `LocalScript` **ScreenBuilder**: solo
corren en Studio, guardan una carga "scrambled" y abren una ventana con "pasos y código" para que el
creador pegue un backdoor. Son copias de modelos legítimos con el malware pegado.
| ID | Nombre | Original limpio |
|---|---|---|
| 126648667803392 | Apple Crate Wooden Box Basket Crates Apples Mesh | 5893008295 |
| 139065864553256 | Shutter Door Roll Up Garage Doors | — |
Antes de aceptar cualquier modelo: listar TODOS sus `LuaSourceContainer` (también dentro de MeshPart/Weld)
y buscar `getfenv`, `loadstring`, `require(<número>)`, `scrambl`, nombres Runtime/ScreenBuilder.

## Registro de assets elegidos (en `ServerStorage/Assets`, 2026-10-18)
| Clave | ID de la Tienda | Nombre | Notas (qué se borró / ajustó) |
|---|---|---|---|
| Diablito | 13716850153 | Carretilla | 1 MeshPart, sin scripts. Escalado a 1.3 m de alto |
| CajaMadera | 5893008295 | apple crate (caja con jitomates) | 34 partes, sin scripts. Escalada a 0.5 m de largo |
| Costal | 9371970094 | Sack of Rice | 1 MeshPart, sin scripts. 0.8 m de alto |
| Arpilla | 9371970094 | Sack of Rice | Mismo costal, sin textura, tela naranja, 0.7 m |
| Caseta | 17117352174 | Advanced Toll Booth Gate | 12 partes; se borraron sus 2 scripts viejos (luces/botón). La pluma la maneja nuestro servidor |
| PuestoTianguis | 15147571772 | market stall | 16 partes, sin scripts. Lona pintada rosa mexicano (estilo tianguis), anclado |
| TresYMedia | 10585573125 | Ford F-4000 | A-Chassis 6, 85 partes, 36 scripts revisados (limpios). Se borró el reproductor de audio y el radar. Sin escalar (rompe el chasis). Falta quitar logos Ford |

**Audios de los camiones:** son privados de sus autores ("no tiene permiso de acceso"); el motor suena
mudo. Reemplazar por audios de la Tienda con permiso cuando toque H5.

## Pendientes de revisar
| Clave | ID | Nombre | Nota |
|---|---|---|---|
| Torton/Rabón | 13837452559 | 90's Commercial Box Truck [WITH CHASSIS] | En `ServerStorage/Revisar`. A-Chassis, 64 scripts sin banderas; se ve desarmado en edición (se arma al jugar). Probar manejándolo en H5 |
| PickUp, Torton | — | — | Buscar en H5 |

**Compradores NPC del tianguis:** se hacen con `Players:CreateHumanoidModelFromDescription` (nativo de
Roblox, sin scripts de terceros) con colores de piel/ropa al azar. Los paquetes de NPC de la Tienda no hacían falta.
**Guardado:** ProfileStore oficial de loleris (109379033046155), copia en `src/server/Lib/ProfileStore.luau`.

## Creados por nosotros (no hubo nada bueno)
| Clave | Por qué no sirvió lo de la Tienda | Cómo se hizo |
|---|---|---|
| Bodega | Las cortinas/bodegas de la Tienda eran malware o de baja calidad | Módulo 5×6×20 m armado con partes (24): muros crema con zoclo verde, cortina metálica a 1/4, rodillo, letrero amarillo con número (NaveBuilder pone "BODEGA 101…"), tapanco de madera al fondo con barandal, puerta trasera al andén y foco cálido. Frente = −Z del modelo |

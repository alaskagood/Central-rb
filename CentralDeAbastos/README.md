# Central de Abastos (Roblox) — Empieza aquí

Juego de Roblox donde eliges oficio en la CEDA: **Diablero, Camionero, Jefe o Revendedor**.
Reglas: `REGLAS.md`. Diseño: `docs/01_DISENO_ROBLOX.md`. Hitos: `docs/03_HITOS.md`.

## 1. Abrir el juego en Roblox Studio (sin plantillas)
Si Studio dice *"No pudimos abrir el lugar [95206881]"* al crear un lugar nuevo, es la
plantilla Baseplate que no carga desde los servidores de Roblox. No la necesitas:

1. Descarga `CentralDeAbastos/CentralDeAbastos.rbxl` de este repo (GitHub → archivo → *Download raw*).
2. En Studio: **Archivo → Abrir desde archivo** (Ctrl+O) y elige ese `.rbxl`.
3. Dale **Play** (F5). Ver `docs/03_HITOS.md` → "Qué probar de H0".
4. Para publicarlo: **Archivo → Publicar en Roblox como...** → *Crear nuevo juego*.

Si tampoco abre archivos o no puedes publicar, prueba en este orden:
1. Cierra sesión en Studio (arriba a la derecha) y vuelve a entrar.
2. Cierra Studio por completo y actualízalo (se actualiza solo al abrirlo con internet).
3. Desactiva VPN/antivirus que filtre la red y revisa status.roblox.com.
4. Borra la caché: cierra Studio, `Win + R` → `%localappdata%\Roblox` → borra la carpeta
   `ClientSettings` y la de `logs`, y vuelve a abrir.

## 2. Trabajar con código (Rojo) — recomendado
El código vive en GitHub (`src/`) y Rojo lo pasa a Studio en vivo:
1. Instala el plugin **Rojo** desde la Tienda de creadores (Plugins) y la herramienta Rojo
   (rojo.space → instalación; o `aftman`/`rokit`).
2. En la carpeta `CentralDeAbastos/` corre `rojo serve`.
3. En Studio: pestaña **Plugins → Rojo → Connect**. Lo que cambie en `src/` aparece en Studio.
4. Los modelos de la Tienda que metas en `ServerStorage/Assets` **no** los borra Rojo; guarda el
   lugar con Ctrl+S para no perderlos.

## 3. Conectores que se necesitan
| Para qué | Conector | Dónde |
|---|---|---|
| Código y documentos compartidos entre Claude y GPT | **GitHub** (este repo) | Ya conectado |
| Que la IA maneje Roblox Studio directo (insertar de la Tienda, correr código, leer la Salida) | **Roblox Studio MCP** (servidor MCP oficial de Roblox) | Solo funciona con Claude **en tu PC** (app de escritorio de Claude o Claude Code local), no en la versión web/nube |
| Pasar código de archivos a Studio | **Rojo** (plugin + programa) | Tu PC |

Se trabaja **todo en la PC**: Claude (app de escritorio o Claude Code) y GPT/Codex abiertos en
esta misma carpeta, Studio abierto con Rojo conectado, y GitHub como respaldo (commit al
terminar cada hito). Reglas para no pisarse: `REGLAS.md`, regla 4.

## 4. Pruebas sin Studio
Desde `CentralDeAbastos/`: `lune run tests/run` (precios y merma). Formato: `stylua src tests`.
Generar el `.rbxl`: `rojo build -o CentralDeAbastos.rbxl`.

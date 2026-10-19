# Traspaso para GPT / Codex

> Tadeo: copia el bloque de abajo y pégalo en ChatGPT/Codex conectado a este repo.

```
Vas a ayudar a programar "Central de Abastos", un juego de Roblox, en el repo GitHub
alaskagood/Central-rb, carpeta CentralDeAbastos/. Trabaja SIEMPRE en tu propia rama
`gpt/<hito>` creada desde la rama `claude/funny-darwin-llrftf` (no la toques directo).
Claude Code trabaja en paralelo en otras carpetas.

ANTES DE TOCAR NADA lee, en este orden:
1. CentralDeAbastos/REGLAS.md            (reglas; manda sobre todo)
2. CentralDeAbastos/docs/01_DISENO_ROBLOX.md
3. CentralDeAbastos/docs/03_HITOS.md      (te tocan los hitos con Quién = GPT)
4. CentralDeAbastos/docs/02_CREATOR_STORE.md

Reglas clave:
- Primero la Tienda de creadores: no modeles nada en código si puede venir de la Tienda.
  Pide los modelos por su clave con Assets.get("<Clave>") (src/server/Assets.luau); si la
  clave no existe agrégala a src/server/AssetCatalog.luau con sus términos de búsqueda.
- No inventes IDs de assets ni nombres que no estén en docs/02_CREATOR_STORE.md.
- Luau --!strict. El servidor valida todo lo que manda el cliente (RemoteEvents en
  src/shared/Remotes.luau: agrega ahí los nombres nuevos).
- Lógica pura (pagos, distancias, reglas) en src/shared/ y con pruebas en tests/run.luau
  (se corren con `lune run tests/run` desde CentralDeAbastos/).
- Solo edita las carpetas de tu hito. Si necesitas cambiar algo de Claude, déjalo escrito
  en la sección "Pendientes para Claude" de este archivo.
- Commits chicos en español. Al terminar: actualiza "Estado" aquí y en docs/03_HITOS.md, y
  escribe para Tadeo, en español simple, qué probar en Studio paso a paso.

Empieza por el hito H2 (Diablero).
```

## Estado
- H0 hecho por Claude (esqueleto, elegir oficio, reloj, nave blockout, pruebas).

## Pendientes para Claude
_(GPT escribe aquí lo que necesite que cambie Claude)_

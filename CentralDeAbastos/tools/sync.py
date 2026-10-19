"""Sirve src/ en http://127.0.0.1:8765 para que Studio lo copie (sin Rojo).

Uso (desde CentralDeAbastos/):  python tools/sync.py
Luego en Studio (barra de comandos o execute_luau del MCP) correr tools/Sincronizar.luau.
Mismo mapeo que default.project.json.
"""

import http.server
import json
import pathlib
import socketserver

ROOT = pathlib.Path(__file__).resolve().parent.parent
TREE = {
    "src/shared": "ReplicatedStorage.Shared",
    "src/server": "ServerScriptService.Server",
    "src/client": "StarterPlayer.StarterPlayerScripts.Client",
}


def manifest():
    files = []
    for folder, target in TREE.items():
        for f in sorted((ROOT / folder).rglob("*.luau")):
            rel = f.relative_to(ROOT / folder).as_posix()
            name = rel[: -len(".luau")]
            kind = "ModuleScript"
            if name.endswith(".server"):
                kind, name = "Script", name[: -len(".server")]
            elif name.endswith(".client"):
                kind, name = "LocalScript", name[: -len(".client")]
            files.append({"url": f"{folder}/{rel}", "target": target, "path": name.split("/"), "class": kind})
    return files


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=str(ROOT), **k)

    def do_GET(self):
        if self.path == "/manifest.json":
            body = json.dumps(manifest()).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
            return
        super().do_GET()


if __name__ == "__main__":
    with socketserver.TCPServer(("127.0.0.1", 8765), Handler) as s:
        print("Sirviendo src/ en http://127.0.0.1:8765 (Ctrl+C para parar)")
        s.serve_forever()

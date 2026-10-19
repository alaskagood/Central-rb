-- Copia src/ a Studio desde tools/sync.py (http://127.0.0.1:8765). Correr en modo edición
-- (barra de comandos o execute_luau del MCP). Crea o actualiza; no borra scripts sobrantes.
local Http = game:GetService("HttpService")
local SES = game:GetService("ScriptEditorService")
local BASE = "http://127.0.0.1:8765/"

local function node(dotted: string): Instance
	local cur: Instance = game
	for part in dotted:gmatch("[^%.]+") do
		cur = if cur == game then game:GetService(part) else cur:FindFirstChild(part) :: Instance
		assert(cur, "No existe " .. dotted)
	end
	return cur
end

local files = Http:JSONDecode(Http:GetAsync(BASE .. "manifest.json"))
local done = {}
for _, f in files do
	local parent = node(f.target)
	for i = 1, #f.path - 1 do
		local child = parent:FindFirstChild(f.path[i])
		if not child then
			child = Instance.new("Folder")
			child.Name = f.path[i]
			child.Parent = parent
		end
		parent = child
	end
	local name = f.path[#f.path]
	local source = Http:GetAsync(BASE .. f.url:gsub(" ", "%%20"))
	local s = parent:FindFirstChild(name)
	if s and s.ClassName ~= f.class then
		s:Destroy()
		s = nil
	end
	if s then
		SES:UpdateSourceAsync(s, function()
			return source
		end)
	else
		s = Instance.new(f.class)
		s.Name = name;
		(s :: any).Source = source
		s.Parent = parent
	end
	table.insert(done, f.url)
end
return `Sincronizados {#done} archivos`

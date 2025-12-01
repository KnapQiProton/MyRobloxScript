-- ================================================
-- Violence District ESP 2025 – FULLY CUSTOMIZABLE
-- Player ESP + Jarak Killer + DANGER Zone
-- Toggle: Insert | Zero Print | Dec 2025
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = true
local Drawings = {}

-- GANTI ANGKA INI SESUKA KALIAN --
local DANGER_DISTANCE = 100   -- < berapa studs = masuk mode DANGER (merah kedip + tulisan DANGER)
-- Contoh: mau 60 studs aja? ganti jadi 60
-- Mau 150 studs? ganti jadi 150
-- Mau 30 studs? ganti jadi 30
-----------------------------------

local ALERT_COLOR   = Color3.fromRGB(255, 20, 20)   -- Warna merah nyala pas DANGER (bisa diganti)
local KILLER_COLOR  = Color3.fromRGB(255, 70, 70)   -- Warna killer biasa (bisa diganti)
local SURVIVOR_COLOR = Color3.fromRGB(70, 255, 70)  -- Warna survivor (bisa diganti)

-- Staff auto-detect (tambahin kalo ada staff baru)
local StaffList = {"dev","admin","moderator","owner","helper","staff","mod"}

-- Cek apakah ada staff di server (kalau ada, ESP langsung mati otomatis)
local function IsStaffInGame()
	for _, plr in Players:GetPlayers() do
		if plr ~= LocalPlayer then
			local n = plr.Name:lower()
			local d = plr.DisplayName:lower()
			for _, kw in StaffList do
				if n:find(kw) or d:find(kw) then return true end
			end
		end
	end
	return false
end

-- Deteksi killer lewat team atau tool
local function IsKiller(plr)
	if plr.Team and plr.Team.Name:lower():find("killer") then return true end
	if plr.Character then
		for _, tool in plr.Character:GetChildren() do
			if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade") or tool.Name:lower():find("sword")) then
				return true
			end
		end
	end
	return false
end

-- Hitung jarak dari kamu ke player lain
local function GetDistance(plr)
	local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local them = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if me and them then
		return (me.Position - them.Position).Magnitude
	else
		return 9999
	end
end

-- Bikin objek Drawing
local function CreateBox() local b = Drawing.new("Square") b.Thickness = 2 b.Filled = false b.Transparency = 1 return b end
local function CreateText() local t = Drawing.new("Text") t.Size = 14 t.Font = 2 t.Center = true t.Outline = true return t end

-- Tambah player ke ESP
local function AddPlayer(plr)
	if plr == LocalPlayer then return end
	Drawings[plr] = {
		box  = CreateBox(),
		name = CreateText(),
		role = CreateText(),
		dist = CreateText()  -- text jarak killer
	}
end

-- Efek kedip buat DANGER
local blink = true
task.spawn(function() while task.wait(0.2) do blink = not blink end end)

-- Main loop ESP
RunService.RenderStepped:Connect(function()
	if not ESPEnabled or IsStaffInGame() then
		for _, v in Drawings do
			v.box.Visible = false v.name.Visible = false v.role.Visible = false v.dist.Visible = false
		end
		return
	end

	for plr, draw in pairs(Drawings) do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if char and hrp and hum and hum.Health > 0 then
			local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local headPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0,0.5,0))
				local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
				local height = math.abs(headPos.Y - legPos.Y)
				local width = height * 0.5

				local killer = IsKiller(plr)
				local distance = GetDistance(plr)
				local danger = killer and distance <= DANGER_DISTANCE   -- DI SINI PAKE VARIABLE YANG BISA DIUBAH

				-- Warna box
				local boxCol = killer and (danger and blink and ALERT_COLOR or KILLER_COLOR) or SURVIVOR_COLOR

				draw.box.Size = Vector2.new(width, height)
				draw.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
				draw.box.Color = boxCol
				draw.box.Visible = true

				-- Nama + tulisan DANGER
				draw.name.Text = plr.DisplayName .. (danger and " DANGER" or "")
				draw.name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 20)
				draw.name.Color = danger and ALERT_COLOR or Color3.fromRGB(255,255,255)
				draw.name.Visible = true

				-- Role (KILLER / SURVIVOR)
				draw.role.Text = killer and "KILLER" or "SURVIVOR"
				draw.role.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 5)
				draw.role.Color = killer and (danger and ALERT_COLOR or Color3.fromRGB(255,100,100)) or Color3.fromRGB(100,255,100)
				draw.role.Visible = true

				-- Jarak killer (SELALU MUNCUL kalau dia killer)
				if killer then
					draw.dist.Text = string.format("%.0f studs", distance)
					draw.dist.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 5)
					draw.dist.Color = danger and ALERT_COLOR or Color3.fromRGB(255, 255, 120)
					draw.dist.Visible = true
				else
					draw.dist.Visible = false
				end
			else
				draw.box.Visible = false draw.name.Visible = false draw.role.Visible = false draw.dist.Visible = false
			end
		else
			draw.box.Visible = false draw.name.Visible = false draw.role.Visible = false draw.dist.Visible = false
		end
	end
end)

-- Toggle pakai tombol Insert
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.Insert then
		ESPEnabled = not ESPEnabled
	end
end)

-- Handler player masuk/keluar
for _, plr in Players:GetPlayers() do AddPlayer(plr) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(function(plr)
	if Drawings[plr] then
		for _, obj in pairs(Drawings[plr]) do obj:Remove() end
		Drawings[plr] = nil
	end
end)

-- SELESAI.
-- Tinggal ubah angka di atas (DANGER_DISTANCE) kalau mau ganti zona bahaya.
-- Mau 50 studs? 80? 200? Bebas bro!

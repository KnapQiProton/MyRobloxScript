-- ================================================
-- VIOLENCE DISTRICT ESP 2025 – FINAL VERSION (FIXED)
-- Player ESP + Jarak Killer + DANGER Zone Kedip
-- Toggle: Insert | Zero Print | 100% NO MISS
-- ================================================
-- FIXES APPLIED:
-- - Wrapped RenderStepped in pcall to prevent crashes from runtime errors.
-- - Added checks to ensure Drawing objects exist before accessing properties.
-- - Improved cleanup: Drawings are now removed and recreated on character respawn to avoid stale references.
-- - Added CharacterAdded/CharacterRemoving events for better handling of respawns.
-- - Ensured no nil references in drawing operations.
-- - Reduced potential memory leaks by properly managing Drawing objects.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = true
local Drawings = {}

-- == GANTI SESUKA HATI DI SINI ==
local DANGER_DISTANCE = 135        -- Jarak berapa studs masuk mode DANGER (merah kedip)
local ALERT_COLOR     = Color3.fromRGB(255, 20, 20)    -- Warna DANGER kedip
local KILLER_COLOR    = Color3.fromRGB(255, 70, 70)    -- Warna killer biasa
local SURVIVOR_COLOR  = Color3.fromRGB(70, 255, 70)    -- Warna survivor
-- ================================

-- Staff auto-detect (tambahin kalau ada staff baru)
local StaffList = {"dev","admin","moderator","owner","helper","staff","mod","tester"}

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

local function IsKiller(plr)
	if plr.Team and plr.Team.Name:lower():find("killer") then return true end
	if plr.Character then
		for _, tool in plr.Character:GetChildren() do
			if tool:IsA("Tool") then
				local tn = tool.Name:lower()
				if tn:find("knife") or tn:find("blade") or tn:find("sword") or tn:find("katana") then
					return true
				end
			end
		end
	end
	return false
end

local function GetDistance(plr)
	local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local them = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if me and them then
		return (me.Position - them.Position).Magnitude
	else
		return 9999
	end
end

-- Drawing creator
local function CreateBox() local b = Drawing.new("Square") b.Thickness = 2 b.Filled = false b.Transparency = 1 return b end
local function CreateText() local t = Drawing.new("Text") t.Size = 14 t.Font = 2 t.Center = true t.Outline = true return t end

-- Efek kedip DANGER
local blink = true
task.spawn(function() while task.wait(0.2) do blink = not blink end end)

-- Setup ESP untuk 1 player (akan dipanggil ulang saat respawn)
local function SetupPlayer(plr)
	if plr == LocalPlayer or Drawings[plr] then return end
	
	Drawings[plr] = {
		box  = CreateBox(),
		name = CreateText(),
		role = CreateText(),
		dist = CreateText()
	}
end

-- Cleanup drawings untuk player
local function CleanupPlayer(plr)
	if Drawings[plr] then
		for _, v in pairs(Drawings[plr]) do
			if v and v.Remove then
				pcall(function() v:Remove() end)  -- Safe remove with pcall
			end
		end
		Drawings[plr] = nil
	end
end

-- Handle character added (for respawns)
local function OnCharacterAdded(plr, char)
	if plr == LocalPlayer then return end
	CleanupPlayer(plr)  -- Remove old drawings
	SetupPlayer(plr)    -- Create new ones
end

-- Handle character removing
local function OnCharacterRemoving(plr, char)
	CleanupPlayer(plr)
end

-- Inisialisasi semua player (yang sudah ada + yang baru masuk)
for _, plr in Players:GetPlayers() do
	SetupPlayer(plr)
	if plr.Character then
		OnCharacterAdded(plr, plr.Character)
	end
	plr.CharacterAdded:Connect(function(char) OnCharacterAdded(plr, char) end)
	plr.CharacterRemoving:Connect(function(char) OnCharacterRemoving(plr, char) end)
end

Players.PlayerAdded:Connect(function(plr)
	SetupPlayer(plr)
	plr.CharacterAdded:Connect(function(char) OnCharacterAdded(plr, char) end)
	plr.CharacterRemoving:Connect(function(char) OnCharacterRemoving(plr, char) end)
end)

-- Cleanup saat keluar
Players.PlayerRemoving:Connect(CleanupPlayer)

-- RESCAN SETIAP 2.5 DETIK – 100% NO MISS PLAYER
task.spawn(function()
	while task.wait(2.5) do
		if ESPEnabled and not IsStaffInGame() then
			for _, plr in Players:GetPlayers() do
				if plr ~= LocalPlayer and not Drawings[plr] then
					SetupPlayer(plr)
					if plr.Character then
						OnCharacterAdded(plr, plr.Character)
					end
				end
			end
		end
	end
end)

-- MAIN RENDER LOOP (with pcall for safety)
RunService.RenderStepped:Connect(function()
	local success, err = pcall(function()
		if not ESPEnabled or IsStaffInGame() then
			for _, draw in pairs(Drawings) do
				for _, obj in pairs(draw) do
					if obj and obj.Visible ~= nil then
						obj.Visible = false
					end
				end
			end
			return
		end

		for plr, draw in pairs(Drawings) do
			if not draw or not draw.box then continue end  -- Skip if drawings are invalid
			
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")

			if char and hrp and hum and hum.Health > 0 then
				local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local headPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
					local legPos  = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
					local height = math.abs(headPos.Y - legPos.Y)
					local width  = height * 0.5

					local killer   = IsKiller(plr)
					local distance = GetDistance(plr)
					local danger   = killer and distance <= DANGER_DISTANCE

					-- Warna box
					local boxCol = killer and (danger and blink and ALERT_COLOR or KILLER_COLOR) or SURVIVOR_COLOR

					if draw.box then
						draw.box.Size = Vector2.new(width, height)
						draw.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
						draw.box.Color = boxCol
						draw.box.Visible = true
					end

					-- Nama + DANGER
					if draw.name then
						draw.name.Text = plr.DisplayName .. (danger and " DANGER" or "")
						draw.name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 20)
						draw.name.Color = danger and ALERT_COLOR or Color3.fromRGB(255,255,255)
						draw.name.Visible = true
					end

					-- Role KILLER / SURVIVOR
					if draw.role then
						draw.role.Text = killer and "KILLER" or "SURVIVOR"
						draw.role.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 5)
						draw.role.Color = killer and (danger and ALERT_COLOR or Color3.fromRGB(255,100,100)) or Color3.fromRGB(100,255,100)
						draw.role.Visible = true
					end

					-- Jarak (hanya killer)
					if draw.dist then
						if killer then
							draw.dist.Text = string.format("%.0f studs", distance)
							draw.dist.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 5)
							draw.dist.Color = danger and ALERT_COLOR or Color3.fromRGB(255, 255, 120)
							draw.dist.Visible = true
						else
							draw.dist.Visible = false
						end
					end
				else
					for _, obj in pairs(draw) do
						if obj and obj.Visible ~= nil then
							obj.Visible = false
						end
					end
				end
			else
				for _, obj in pairs(draw) do
					if obj and obj.Visible ~= nil then
						obj.Visible = false
					end
				end
			end
		end
	end)
	if not success then
		warn("ESP Render Error: " .. err)  -- Log error instead of crashing
	end
end)

-- Toggle ESP pake Insert
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.Insert then
		ESPEnabled = not ESPEnabled
		print("ESP " .. (ESPEnabled and "ON" or "OFF"))
	end
end)

print("Violence District ESP 2025 – LOADED & READY (FIXED VERSION)")

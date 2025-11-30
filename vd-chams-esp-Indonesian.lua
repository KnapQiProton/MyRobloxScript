-- Violence District Chams ESP + Generator Orange Glow!
-- Players: Killer 🔴 Merah | Survivor 🟢 Hijau
-- Generators: 🟠 ORANGE (lewat tembok, auto detect semua "Generator")
-- Toggle: Right Ctrl | No Outline | Super Clean 2025

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ChamsEnabled = true
local PlayerHighlights = {}
local GeneratorHighlights = {}

-- Warna Players
local function GetPlayerColor(player)
    if player.Team and player.Team.Name:lower():find("killer") then
        return Color3.fromRGB(255, 0, 0)  -- Killer: Merah
    else
        return Color3.fromRGB(0, 255, 0)  -- Survivor: Hijau
    end
end

-- Warna Generator: Orange
local GEN_COLOR = Color3.fromRGB(255, 165, 0)  -- Orange glow

-- Toggle Right Ctrl (Players + Generators)
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        ChamsEnabled = not ChamsEnabled
        -- Toggle Players
        for _, hl in pairs(PlayerHighlights) do
            if hl then hl.Enabled = ChamsEnabled end
        end
        -- Toggle Generators
        for _, hl in pairs(GeneratorHighlights) do
            if hl then hl.Enabled = ChamsEnabled end
        end
        print("VD Chams + Gen ESP:", ChamsEnabled and "ON" or "OFF")
    end
end)

-- Add Player Chams
local function AddPlayerChams(plr)
    if plr == LocalPlayer then return end
    
    local function OnChar(char)
        task.wait(1)
        
        local hl = Instance.new("Highlight")
        hl.Name = "VDPlayerGlow"
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 1  -- No Outline
        hl.Parent = char
        hl.Enabled = ChamsEnabled
        
        hl.FillColor = GetPlayerColor(plr)
        PlayerHighlights[plr] = hl
        
        -- Update color if team changes
        plr:GetPropertyChangedSignal("Team"):Connect(function()
            hl.FillColor = GetPlayerColor(plr)
        end)
    end
    
    if plr.Character then OnChar(plr.Character) end
    plr.CharacterAdded:Connect(OnChar)
end

-- Add Generator Chams (Auto detect semua "Generator")
local function AddGeneratorChams(model)
    if GeneratorHighlights[model] then return end  -- Avoid dupes
    
    local hl = Instance.new("Highlight")
    hl.Name = "VDGenGlow"
    hl.Adornee = model
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = GEN_COLOR
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 1  -- No Outline
    hl.Parent = model
    hl.Enabled = ChamsEnabled
    
    GeneratorHighlights[model] = hl
end

-- Scan & Add Generators (recursive search)
local function ScanGenerators()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) and 
           (obj:IsA("Model") or obj:IsA("BasePart")) then
            AddGeneratorChams(obj)
        end
    end
end

-- Rescan on new objects (map changes/rounds)
Workspace.DescendantAdded:Connect(function(obj)
    if (obj.Name:lower():find("generator") or obj.Name:lower():find("gen")) and 
       (obj:IsA("Model") or obj:IsA("BasePart")) then
        task.wait(0.5)
        AddGeneratorChams(obj)
    end
end)

-- Init Players
for _, plr in Players:GetPlayers() do
    AddPlayerChams(plr)
end
Players.PlayerAdded:Connect(AddPlayerChams)

Players.PlayerRemoving:Connect(function(plr)
    if PlayerHighlights[plr] then
        PlayerHighlights[plr]:Destroy()
        PlayerHighlights[plr] = nil
    end
end)

-- Init Generators (scan awal)
ScanGenerators()

print("Violence District Chams + Generator ESP Loaded!")
print("🔴 Killer Merah | 🟢 Survivor Hijau | 🟠 Generators Orange")
print("Right Ctrl = Toggle | Lewat tembok 100% | Byfron Safe!")

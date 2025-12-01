-- Violence District Chams ESP + Generator Orange Glow! (FIXED 2025)
-- Players: Killer 🔴 Merah | Survivor 🟢 Hijau
-- Generators: 🟠 ORANGE (lewat tembok, auto detect semua "Generator")
-- Toggle: Right Ctrl | No Outline | Super Clean 2025

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ChamsEnabled = true
local PlayerHighlights = {}
local GeneratorHighlights = {}
local ScannedGens = {}  -- Track untuk avoid duplicate

-- FIXED: Deteksi Killer lebih akurat
local function IsKiller(player)
    -- Method 1: Check Team name
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("murder") or teamName:find("slasher") then
            return true
        end
    end
    
    -- Method 2: Check TeamColor (Red = Killer)
    if player.TeamColor == BrickColor.new("Bright red") or 
       player.TeamColor == BrickColor.new("Really red") then
        return true
    end
    
    -- Method 3: Check tools (knife/weapon = killer)
    if player.Character then
        for _, item in pairs(player.Character:GetChildren()) do
            if item:IsA("Tool") then
                local toolName = item.Name:lower()
                if toolName:find("knife") or toolName:find("weapon") or 
                   toolName:find("blade") or toolName:find("machete") then
                    return true
                end
            end
        end
        
        -- Check backpack juga
        if player.Backpack then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local toolName = item.Name:lower()
                    if toolName:find("knife") or toolName:find("weapon") or 
                       toolName:find("blade") or toolName:find("machete") then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Warna Players (FIXED)
local function GetPlayerColor(player)
    if IsKiller(player) then
        return Color3.fromRGB(255, 0, 0)  -- Killer: MERAH
    else
        return Color3.fromRGB(0, 255, 0)  -- Survivor: HIJAU
    end
end

-- Warna Generator: Orange
local GEN_COLOR = Color3.fromRGB(255, 165, 0)

-- Toggle Right Ctrl (Players + Generators)
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        ChamsEnabled = not ChamsEnabled
        -- Toggle Players
        for _, hl in pairs(PlayerHighlights) do
            if hl then pcall(function() hl.Enabled = ChamsEnabled end) end
        end
        -- Toggle Generators
        for _, hl in pairs(GeneratorHighlights) do
            if hl then pcall(function() hl.Enabled = ChamsEnabled end) end
        end
        print("VD Chams + Gen ESP:", ChamsEnabled and "ON" or "OFF")
    end
end)

-- Add Player Chams (IMPROVED)
local function AddPlayerChams(plr)
    if plr == LocalPlayer then return end
    
    local function OnChar(char)
        task.wait(1.5)  -- Wait lebih lama buat load
        
        local hl = Instance.new("Highlight")
        hl.Name = "VDPlayerGlow"
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.3  -- Lebih visible
        hl.OutlineTransparency = 1
        hl.Parent = char
        hl.Enabled = ChamsEnabled
        
        hl.FillColor = GetPlayerColor(plr)
        PlayerHighlights[plr] = hl
        
        -- Debug print
        print("👤", plr.Name, "->", IsKiller(plr) and "🔴 KILLER" or "🟢 SURVIVOR")
        
        -- Update color saat team berubah
        plr:GetPropertyChangedSignal("Team"):Connect(function()
            if hl then
                hl.FillColor = GetPlayerColor(plr)
                print("🔄", plr.Name, "team changed ->", IsKiller(plr) and "🔴 KILLER" or "🟢 SURVIVOR")
            end
        end)
        
        -- Update color saat TeamColor berubah
        plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
            if hl then
                hl.FillColor = GetPlayerColor(plr)
            end
        end)
        
        -- Auto-update color tiap 3 detik (detect killer item changes)
        task.spawn(function()
            while char and char.Parent and hl do
                task.wait(3)
                if hl then
                    local newColor = GetPlayerColor(plr)
                    if hl.FillColor ~= newColor then
                        hl.FillColor = newColor
                        print("🔄", plr.Name, "role updated ->", IsKiller(plr) and "🔴 KILLER" or "🟢 SURVIVOR")
                    end
                end
            end
        end)
        
        -- Cleanup saat character removed
        char.AncestryChanged:Connect(function()
            if not char.Parent and hl then
                pcall(function() hl:Destroy() end)
                PlayerHighlights[plr] = nil
            end
        end)
    end
    
    if plr.Character then OnChar(plr.Character) end
    plr.CharacterAdded:Connect(OnChar)
end

-- IMPROVED: Deteksi Generator lebih bagus
local function IsGenerator(obj)
    local name = obj.Name:lower()
    return name:find("generator") or name:find("gen") or name:find("motor")
end

-- Add Generator Chams (IMPROVED)
local function AddGeneratorChams(model)
    if ScannedGens[model] or GeneratorHighlights[model] then return end
    
    ScannedGens[model] = true
    
    -- Pilih target yang tepat (prefer Model)
    local target = model
    if model:IsA("BasePart") and model.Parent:IsA("Model") then
        target = model.Parent
        if GeneratorHighlights[target] then return end
    end
    
    local hl = Instance.new("Highlight")
    hl.Name = "VDGenGlow"
    hl.Adornee = target
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = GEN_COLOR
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 1
    hl.Parent = target
    hl.Enabled = ChamsEnabled
    
    GeneratorHighlights[target] = hl
    print("⚡ Generator found:", target.Name)
    
    -- Cleanup
    target.AncestryChanged:Connect(function()
        if not target.Parent and hl then
            pcall(function() hl:Destroy() end)
            GeneratorHighlights[target] = nil
            ScannedGens[model] = nil
        end
    end)
end

-- IMPROVED: Scan Generators lebih dalam
local function DeepScan(parent, depth)
    if depth > 6 then return end  -- Max depth 6 levels
    
    for _, obj in pairs(parent:GetChildren()) do
        if IsGenerator(obj) and (obj:IsA("Model") or obj:IsA("BasePart")) then
            AddGeneratorChams(obj)
        end
        
        -- Recursive scan untuk Model dan Folder
        if obj:IsA("Model") or obj:IsA("Folder") then
            DeepScan(obj, depth + 1)
        end
    end
end

-- Scan awal Generators
local function ScanGenerators()
    print("🔍 Scanning for generators...")
    
    -- Scan Workspace utama
    DeepScan(Workspace, 0)
    
    -- Scan folder khusus kalau ada
    local folders = {"Map", "Game", "Generators", "Objects", "Props"}
    for _, folderName in pairs(folders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            DeepScan(folder, 0)
        end
    end
    
    print("✅ Generator scan complete!")
end

-- Rescan otomatis tiap 5 detik (detect generator baru)
task.spawn(function()
    while task.wait(5) do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if IsGenerator(obj) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                if not ScannedGens[obj] then
                    AddGeneratorChams(obj)
                end
            end
        end
    end
end)

-- Rescan on new objects (map changes/rounds)
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.5)
    if obj and obj.Parent and IsGenerator(obj) and (obj:IsA("Model") or obj:IsA("BasePart")) then
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
        pcall(function() PlayerHighlights[plr]:Destroy() end)
        PlayerHighlights[plr] = nil
    end
end)

-- Init Generators (Multiple scans)
task.spawn(function()
    for i = 1, 3 do
        task.wait(i * 2)  -- 2s, 4s, 6s
        ScanGenerators()
    end
end)

-- ASCII Watermark
print(" ")
print("═══════════════════════════════════════════════════════")
print("  ██╗  ██╗███╗   ██╗ █████╗ ██████╗  ██████╗ ██╗")
print("  ██║ ██╔╝████╗  ██║██╔══██╗██╔══██╗██╔═══██╗██║")
print("  █████╔╝ ██╔██╗ ██║███████║██████╔╝██║   ██║██║")
print("  ██╔═██╗ ██║╚██╗██║██╔══██║██╔═══╝ ██║▄▄ ██║██║")
print("  ██║  ██╗██║ ╚████║██║  ██║██║     ╚██████╔╝██║")
print("  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝      ╚══▀▀═╝ ╚═╝")
print(" ")
print("         Violence District ESP v2.0 | 2025")
print("═══════════════════════════════════════════════════════")
print(" ")
print("🔴 KILLER = MERAH | 🟢 SURVIVOR = HIJAU | 🟠 GEN = ORANGE")
print("⚙️  Right Ctrl = Toggle ON/OFF")
print("📊 Check console untuk role detection!")
print(" ")
print("═══════════════════════════════════════════════════════")

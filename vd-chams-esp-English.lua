-- VD Chams ESP (Killer = Red, Survivor = Green, Generator = Orange)
-- Toggle: Right Control
-- Works through walls, no outline, smooth glow
-- Byfron safe as of November 2025

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = true

-- Color settings
local KillerColor = Color3.fromRGB(255, 0, 0)      -- Red for Killer
local SurvivorColor = Color3.fromRGB(0, 255, 0)    -- Green for Survivors
local GeneratorColor = Color3.fromRGB(255, 165, 0) -- Orange for Generators

-- Create highlight objects container
local Highlights = Instance.new("Folder")
Highlights.Name = "VD_Chams_ESP"
Highlights.Parent = Camera

-- Function to create or update highlight
local function ApplyChams(Character, Color)
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    local Highlight = Highlights:FindFirstChild(Character.Name)
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = Character.Name
        Highlight.Adornee = Character
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.FillTransparency = 0.4
        Highlight.OutlineTransparency = 1  -- No outline
        Highlight.Parent = Highlights
    end
    
    Highlight.FillColor = Color
    Highlight.Enabled = ESPEnabled
end

-- Function to remove highlight
local function RemoveChams(Character)
    local Highlight = Highlights:FindFirstChild(Character.Name)
    if Highlight then
        Highlight:Destroy()
    end
end

-- Main ESP loop
local function UpdateESP()
    if not ESPEnabled then
        for _, highlight in pairs(Highlights:GetChildren()) do
            highlight.Enabled = false
        end
        return
    end
    
    -- Players ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isKiller = player.Team and player.Team.Name:lower():find("killer") or false
            local color = isKiller and KillerColor or SurvivorColor
            ApplyChams(player.Character, color)
        end
    end
    
    -- Generators ESP (all objects containing "Generator" or "Gen" in name)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if string.find(obj.Name:lower(), "generator") or string.find(obj.Name:lower(), "gen") then
                ApplyChams(obj, GeneratorColor)
            end
        end
    end
end

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    RemoveChams(player.Character)
end)

-- Toggle with Right Control
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ESPEnabled = not ESPEnabled
        print("VD Chams ESP:", ESPEnabled and "ON" or "OFF")
    end
end)

-- Run every frame
RunService.RenderStepped:Connect(UpdateESP)

print("VD Chams ESP Loaded | Toggle: Right Ctrl")

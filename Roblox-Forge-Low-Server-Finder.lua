-- Pure Low Player Server Hopper + Progress GUI for The Forge BETA
-- Place ID: 76558904092080 (The Forge [BETA])
local PlaceID = 76558904092080
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local MAX_PLAYERS = 3  -- **CATATAN: UBAH ANGKA INI SESUAI KEINGINAN (0=tanpa batas, 4=sangat kecil)**
local IGNORE_FRIENDS = true  -- **FITUR BARU: Set ke true untuk mengabaikan server dengan teman online**

-- Buat GUI Progress
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerHopProgress"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 60)  -- **MODIFIKASI: Dikurangi ukurannya untuk lebih kompak dan tidak mengganggu**
Frame.Position = UDim2.new(0.5, -125, 0, 10)  -- **MODIFIKASI: Dipindah ke atas layar (top-center)**
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.Parent = ScreenGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 1, -10)
StatusLabel.Position = UDim2.new(0, 5, 0, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Script dimulai! Batas: ≤" .. MAX_PLAYERS .. " pemain"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = Frame

local function UpdateStatus(text)
    StatusLabel.Text = text
    print("[HOPPER] " .. text)
end

-- **FITUR BARU: Fungsi untuk memeriksa apakah ada teman di server saat ini**
local function HasFriendInServer()
    if not IGNORE_FRIENDS then
        return false  -- Jika fitur dinonaktifkan, anggap tidak ada teman
    end
    
    local friends = {}
    local success, result = pcall(function()
        return Player:GetFriendsOnline(50)  -- Ambil daftar teman online (maksimal 50)
    end)
    
    if not success then
        UpdateStatus("Gagal memuat daftar teman. Lanjut tanpa pemeriksaan teman.")
        return false
    end
    
    for _, friend in ipairs(result) do
        table.insert(friends, friend.Id)
    end
    
    local currentPlayers = game.Players:GetPlayers()
    for _, plr in ipairs(currentPlayers) do
        if plr ~= Player and table.find(friends, plr.UserId) then
            return true  -- Ada teman di server
        end
    end
    
    return false  -- Tidak ada teman
end

-- **FITUR BARU: Periksa server saat ini sebelum memulai hop**
local function CheckCurrentServer()
    UpdateStatus("Memeriksa server saat ini...")
    wait(3)  -- Tunggu game load sepenuhnya
    
    local currentPlayerCount = #game.Players:GetPlayers()
    local hasFriend = HasFriendInServer()
    
    if currentPlayerCount <= MAX_PLAYERS and not hasFriend then
        UpdateStatus("Server saat ini memenuhi syarat (≤" .. MAX_PLAYERS .. " pemain, tanpa teman). Script dihentikan.")
        wait(2)
        ScreenGui:Destroy()
        return true  -- Server baik, hentikan script
    else
        local reason = ""
        if currentPlayerCount > MAX_PLAYERS then
            reason = reason .. "Pemain terlalu banyak (" .. currentPlayerCount .. " > " .. MAX_PLAYERS .. ")"
        end
        if hasFriend then
            reason = reason .. (reason ~= "" and ", " or "") .. "Ada teman di server"
        end
        UpdateStatus("Server saat ini tidak memenuhi syarat (" .. reason .. "). Memulai pencarian...")
        return false  -- Lanjutkan ke hopping
    end
end

local pageCount = 0
local attemptCount = 0

local function TPReturner()
    attemptCount = attemptCount + 1
    pageCount = pageCount + 1
    UpdateStatus("Memproses halaman " .. pageCount .. "...")
    
    local Site
    local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'
    if foundAnything ~= "" then
        url = url .. '&cursor=' .. foundAnything
    end
    
    UpdateStatus("Mengambil data server...")
    Site = game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
    
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    
    UpdateStatus("Scanning " .. #Site.data .. " server...")
    
    local num = 0
    for i, v in pairs(Site.data) do
        if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) <= MAX_PLAYERS then
            local ID = tostring(v.id)
            local Possible = true
            for _, Existing in pairs(AllIDs) do
                if ID == tostring(Existing) then
                    Possible = false
                    break
                end
            end
            if Possible then
                table.insert(AllIDs, ID)
                UpdateStatus("Ditemukan server " .. v.playing .. "/" .. v.maxPlayers .. "! Sedang hop...")
                print("[HOPPER] Hopping to: " .. ID .. " (" .. v.playing .. "/" .. v.maxPlayers .. ")")
                wait(1)
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, Player)
                -- **CATATAN: Setelah hop, script akan restart dan memeriksa server baru secara otomatis**
                return true
            end
        end
        num = num + 1
    end
    
    if #Site.data == 0 then
        UpdateStatus("Tidak ada server tersedia. Coba lagi...")
    else
        UpdateStatus("Tidak ditemukan server ≤" .. MAX_PLAYERS .. " pemain. Attempt " .. attemptCount)
    end
    return false
end

-- Loop utama
spawn(function()
    if CheckCurrentServer() then
        return  -- Jika server saat ini baik, hentikan
    end
    
    UpdateStatus("Mulai pencarian server low player (tanpa teman)...")
    while wait(4) do
        local success = pcall(TPReturner)
        if success and foundAnything ~= "" then
            pcall(TPReturner)  -- Coba halaman berikutnya
        end
    end
end)

print("=== SERVER HOPPER AKTIF DENGAN IGNORE FRIENDS ===")
print("Batas pemain: ≤" .. MAX_PLAYERS)
print("Ignore friends: " .. tostring(IGNORE_FRIENDS))
print("Lihat overlay di layar untuk progress!")

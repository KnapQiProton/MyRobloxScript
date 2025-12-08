-- Pure Low Player Server Hopper for The Forge BETA (Magma Hub Method)
-- Place ID: 76558904092080 (The Forge [BETA])<grok-card data-id="5525a5" data-type="citation_card"></grok-card>
local PlaceID = 76558904092080  -- Fixed untuk The Forge [BETA]
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour

-- **CATATAN PENTING: UBAH NILAI INI SESUAI KEINGINAN ANDA**
-- Contoh: 4 = server maksimal 4 pemain; 6 = maksimal 6 pemain; 0 = tanpa batas (hanya slot kosong)
local MAX_PLAYERS = 6  -- Ubah angka ini! (1-11 direkomendasikan, max server 12)

local function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game:GetService("HttpService"):JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game:GetService("HttpService"):JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    
    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        -- **BARIS INI SUDAH OTOMATIS MENGGUNAKAN MAX_PLAYERS YANG ANDA UBAH**
        if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) <= MAX_PLAYERS then  -- Slot kosong + batas player
            local ID = tostring(v.id)
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        AllIDs = {}
                        table.insert(AllIDs, actualHour)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                print("Hopping to server: " .. ID .. " (" .. v.playing .. "/" .. v.maxPlayers .. ")")
                wait(1)
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                return
            end
        end
    end
end

-- Loop otomatis hingga berhasil
spawn(function()
    while wait(3) do
        pcall(TPReturner)
        if foundAnything ~= "" then
            pcall(TPReturner)
        end
    end
end)

print("Low Player Server Hopper started! Batas: <= " .. MAX_PLAYERS .. " pemain")

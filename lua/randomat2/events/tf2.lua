local EVENT = {}
EVENT.Title = ""
-- EVENT.Title = "It's time to..."
EVENT.AltTitle = "Meet The Randomat!"
EVENT.id = "tf2"
EVENT.Type = EVENT_TYPE_RESPAWN

EVENT.Categories = {"gamemode", "rolechange", "largeimpact"}

local capturesToWin = CreateConVar("randomat_tf2_captures_to_win", 2, FCVAR_NONE, "Number of intel captures to win", 1, 10)
local respawnSecs = CreateConVar("randomat_tf2_respawn_seconds", 15, FCVAR_NONE, "Seconds to wait until respawning", 1, 60)

function EVENT:Begin()
    local REDSpawn, BLUSpawn
    local playerSpawns = ents.FindByClass("info_player_start")

    if #playerSpawns >= 1 then
        REDSpawn = playerSpawns[math.random(#playerSpawns)]:GetPos()
    end

    local weaponSpawns = {}

    for _, ent in ents.Iterator() do
        if ent.AutoSpawnable then
            table.insert(weaponSpawns, ent:GetPos())
        end
    end

    if not REDSpawn then
        REDSpawn = weaponSpawns[math.random(#weaponSpawns)]
    end

    local maxDist = 0

    for _, pos in ipairs(weaponSpawns) do
        local dist = pos:DistToSqr(REDSpawn)

        if dist > maxDist then
            maxDist = dist
            BLUSpawn = pos
        end
    end

    local REDIntel = ents.Create("ttt_tf2_intelligence")
    REDIntel:SetPos(REDSpawn)
    REDIntel:Spawn()
    local BLUIntel = ents.Create("ttt_tf2_intelligence")
    BLUIntel:SetPos(BLUSpawn)
    BLUIntel:Spawn()
    BLUIntel:SetBLU(true)
    local REDIntelCaptures = 0
    local BLUIntelCaptures = 0

    self:AddHook("TF2IntelligenceCaptured", function(ply, isBLU)
        local str = ply:Nick() .. " has captured the enemy intelligence for the"

        if isBLU then
            str = str .. " BLU team!"
        else
            str = str .. " RED team!"
        end

        PrintMessage(HUD_PRINTCENTER, str)
        PrintMessage(HUD_PRINTTALK, str)

        if isBLU then
            BLUIntelCaptures = BLUIntelCaptures + 1
        else
            REDIntelCaptures = REDIntelCaptures + 1
        end
    end)

    -- Only allow for a win through getting enough captures, or the round time running out
    self:AddHook("TTTCheckForWin", function()
        if REDIntelCaptures >= capturesToWin:GetInt() then return WIN_TRAITOR end
        if BLUIntelCaptures >= capturesToWin:GetInt() then return WIN_INNOCENT end
        if GetGlobalFloat("ttt_round_end") > CurTime() then return WIN_NONE end
    end)

    util.AddNetworkString("TF2RandomatRespawnTimer")

    self:AddHook("PostPlayerDeath", function(ply)
        local timername = "TF2RandomatRespawnTimer" .. ply:SteamID64()
        local respawnTime = respawnSecs:GetInt()
        net.Start("TF2RandomatRespawnTimer")
        net.WriteUInt(respawnTime, 6)
        net.Send(ply)

        timer.Create(timername, 1, respawnTime, function()
            if not IsValid(ply) or ply:Alive() or not ply:IsSpec() then
                timer.Remove(timername)

                return
            end

            if timer.RepsLeft(timername) > 0 then return end
            ply:SpawnForRound(true)
            -- Make the player face the enemy intel on respawning
            local intel = Randomat:IsTraitorTeam(ply) and BLUIntel or REDIntel
            local direction = intel:GetPos() - ply:GetPos()
            ply:SetEyeAngles(direction:Angle())
        end)
    end)

    local halfPlayerCount = player.GetCount() / 2
    local REDRole = ROLE_REDMANN or ROLE_TRAITOR
    local BLURole = ROLE_BLUMANN or ROLE_DETECTIVE

    for i, ply in player.Iterator() do
        if i < halfPlayerCount then
            Randomat:SetRole(ply, REDRole)
        else
            Randomat:SetRole(ply, BLURole)
        end
    end
end

function EVENT:End()
    for _, ply in player.Iterator() do
        timer.Remove("TF2RandomatRespawnTimer" .. ply:SteamID64())
    end
end

-- Don't run at the same time as other gamemode randomats, since this randomat completely changes the game
function EVENT:Condition()
    return not Randomat:IsEventCategoryActive("gamemode")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"captures_to_win", "respawn_seconds"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)
local EVENT = {}
EVENT.Title = ""
EVENT.Title = "It's time to..."
EVENT.AltTitle = "Meet The Randomat!"
EVENT.id = "tf2"
EVENT.Type = EVENT_TYPE_RESPAWN

EVENT.Categories = {"gamemode", "rolechange", "largeimpact"}

local capturesToWin = CreateConVar("randomat_tf2_captures_to_win", 2, FCVAR_NONE, "Number of intel captures to win", 1, 10)
local respawnSecs = CreateConVar("randomat_tf2_respawn_seconds", 15, FCVAR_NONE, "Seconds to wait until respawning", 1, 60)
local playMusic = CreateConVar("randomat_tf2_play_music", 1, FCVAR_NONE, "Play music during the event", 0, 1)
local hasteModeCvar

function EVENT:Begin()
    local hasteMode = GetConVar("ttt_haste")
    hasteModeCvar = hasteMode:GetBool()
    hasteMode:SetBool(false)
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
    util.AddNetworkString("TF2RandomatIntelCaptured")

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

        -- Don't let the last intel capture announcement overlap with the victory/defeat round end sounds
        if REDIntelCaptures < capturesToWin:GetInt() and BLUIntelCaptures < capturesToWin:GetInt() then
            for _, p in player.Iterator() do
                if (isBLU and Randomat:IsInnocentTeam(p)) or (not isBLU and Randomat:IsTraitorTeam(p)) then
                    p:SendLua("surface.PlaySound(\"misc/intel_teamcaptured.wav\")")
                elseif (isBLU and not Randomat:IsInnocentTeam(p)) or (not isBLU and not Randomat:IsTraitorTeam(p)) then
                    p:SendLua("surface.PlaySound(\"misc/intel_enemycaptured.wav\")")
                end
            end
        end

        net.Start("TF2RandomatIntelCaptured")
        net.WriteBool(isBLU)
        net.Broadcast()
    end)

    -- Only allow for a win through getting enough captures, or the round time running out
    self:AddHook("TTTCheckForWin", function()
        if REDIntelCaptures >= capturesToWin:GetInt() then return WIN_TRAITOR end
        if BLUIntelCaptures >= capturesToWin:GetInt() then return WIN_INNOCENT end
        if GetGlobalFloat("ttt_round_end") > CurTime() then return WIN_NONE end
    end)

    util.AddNetworkString("TF2RandomatRespawnTimer")
    local respawnTime = respawnSecs:GetInt()

    self:AddHook("PostPlayerDeath", function(ply)
        local timername = "TF2RandomatRespawnTimer" .. ply:SteamID64()
        net.Start("TF2RandomatRespawnTimer")
        net.WriteUInt(respawnTime, 6)
        net.WriteBool(false)
        net.WriteBool(false)
        net.WriteInt(capturesToWin:GetInt(), 6)
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

            -- Give the player their last selected class's loadout weapons
            if ply.TF2Class then
                timer.Simple(1, function()
                    TF2WC:StripAndGiveLoadout(ply, ply.TF2Class)
                    ply:EmitSound("player/" .. ply.TF2Class.name .. "/spawn" .. math.random(5) .. ".wav", 0, 100, 100, CHAN_VOICE)
                end)
            end
        end)
    end)

    self:AddHook("PlayerButtonDown", function(ply, button)
        if button ~= KEY_COMMA then return end

        if not ply:Alive() or ply:IsSpec() then
            net.Start("TF2ClassChangerScreen")
            net.Send(ply)
        end
    end)

    self:DisableRoundEndSounds()

    -- TTTEndRound doesn't pass the win type to clients, so we have to check on the server
    self:AddHook("TTTEndRound", function(wintype)
        for _, ply in player.Iterator() do
            ply:ConCommand("stopsound")

            timer.Simple(0.1, function()
                if wintype == WIN_TIMELIMIT then
                    ply:SendLua("surface.PlaySound(\"misc/your_team_stalemate.wav\")")
                elseif (Randomat:IsTraitorTeam(ply) and wintype == WIN_TRAITOR) or (Randomat:IsInnocentTeam(ply) and wintype == WIN_INNOCENT) then
                    ply:SendLua("surface.PlaySound(\"misc/your_team_won.wav\")")
                else
                    ply:SendLua("surface.PlaySound(\"misc/your_team_lost.wav\")")
                end
            end)
        end
    end)

    if playMusic:GetBool() then
        SetGlobal2Bool("TF2ClassChangerDisableMusic", true)

        -- The TF2 music that plays in the TF2RandomatIntro net message is about 75 seconds long
        timer.Create("TF2RandomatEnableClassChangeMusic", 75, 1, function()
            SetGlobal2Bool("TF2ClassChangerDisableMusic", nil)
        end)
    end

    util.AddNetworkString("TF2RandomatIntro")

    timer.Simple(0.1, function()
        net.Start("TF2RandomatIntro")
        net.Broadcast()
    end)

    timer.Create("TF2RandomatEventStartCountdown", 7, 1, function()
        local halfPlayerCount = player.GetCount() / 2
        local REDRole = ROLE_REDMANN or ROLE_TRAITOR
        local BLURole = ROLE_BLUMANN or ROLE_DETECTIVE

        for i, ply in player.Iterator() do
            if not ply:Alive() or ply:IsSpec() then
                ply:SpawnForRound(true)
            end

            local enemyIntel

            if i <= halfPlayerCount then
                Randomat:SetRole(ply, REDRole)
                enemyIntel = BLUIntel
            else
                Randomat:SetRole(ply, BLURole)
                enemyIntel = REDIntel
            end

            local direction = enemyIntel:GetPos() - ply:GetPos()
            ply:SetEyeAngles(direction:Angle())
            ply:Freeze(true)
        end

        timer.Simple(1, function()
            SendFullStateUpdate()
        end)

        timer.Create("TF2RandomatRoundBeginUnfreeze", 15, 1, function()
            for _, ply in player.Iterator() do
                ply:Freeze(false)
            end
        end)

        local roundTime = GetGlobalFloat("ttt_round_end") - CurTime()

        timer.Create("TF2RandomatRoundTimeAnnouncements", 1, roundTime, function()
            if timer.RepsLeft("TF2RandomatRoundTimeAnnouncements") == 60 then
                BroadcastLua("surface.PlaySound(\"misc/announcer_ends_60sec.wav\")")
            elseif timer.RepsLeft("TF2RandomatRoundTimeAnnouncements") == 30 then
                BroadcastLua("surface.PlaySound(\"misc/announcer_ends_30sec.wav\")")
            elseif timer.RepsLeft("TF2RandomatRoundTimeAnnouncements") == 10 then
                BroadcastLua("surface.PlaySound(\"misc/announcer_ends_10sec.wav\")")
            elseif timer.RepsLeft("TF2RandomatRoundTimeAnnouncements") == 5 then
                BroadcastLua("surface.PlaySound(\"misc/announcer_ends_5sec.wav\")")
            end
        end)

        net.Start("TF2ClassChangerScreen")
        net.Broadcast()

        -- The initial class selection is a fixed amount of seconds to allow for the randomat's intro sequence to play properly
        -- (The "Meet the randomat" splash screen, etc.)
        timer.Simple(0.1, function()
            net.Start("TF2RandomatRespawnTimer")
            net.WriteUInt(15, 6)
            net.WriteBool(true)
            net.WriteBool(playMusic:GetBool())
            net.WriteInt(capturesToWin:GetInt(), 6)
            net.Broadcast()
        end)
    end)
end

function EVENT:End()
    if hasteModeCvar then
        GetConVar("ttt_haste"):SetBool(hasteModeCvar)
    end

    for _, ply in player.Iterator() do
        timer.Remove("TF2RandomatRespawnTimer" .. ply:SteamID64())
    end

    timer.Remove("TF2RandomatRoundBeginUnfreeze")
    timer.Remove("TF2RandomatEnableClassChangeMusic")
    SetGlobal2Bool("TF2ClassChangerDisableMusic", nil)
    timer.Remove("TF2RandomatEventStartCountdown")
    timer.Remove("TF2RandomatRoundTimeAnnouncements")
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

    local checks = {}

    for _, v in pairs({"play_music"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)
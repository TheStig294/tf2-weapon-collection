net.Receive("TF2RandomatRespawnTimer", function()
    local respawnTime = net.ReadUInt(6)
    local isEventBegin = net.ReadBool()
    local client = LocalPlayer()

    timer.Create("TF2RandomatRespawnTimer", 1, respawnTime, function()
        if not isEventBegin and (not IsValid(client) or client:Alive() or not client:IsSpec()) then
            respawnTime = 0
            timer.Remove("TF2RandomatRespawnTimer")

            return
        end

        respawnTime = timer.RepsLeft("TF2RandomatRespawnTimer")

        if isEventBegin then
            if respawnTime == 10 then
                surface.PlaySound("misc/announcer_begins_10sec.wav")
            elseif respawnTime == 5 then
                surface.PlaySound("misc/announcer_begins_5sec.wav")
            end
        end
    end)

    hook.Add("PostDrawHUD", "TF2RandomatRespawnTimerHUD", function()
        if respawnTime <= 0 then
            hook.Remove("PostDrawHUD", "TF2RandomatRespawnTimerHUD")

            return
        end

        local message = "Respawning in " .. respawnTime .. " seconds, press [,] to change class"

        if isEventBegin then
            message = "Round beginning in " .. respawnTime .. " seconds..."
        end

        draw.WordBox(8, 265, ScrH() - 50, message, "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end)

    if CR_VERSION then
        LANG.AddToLanguage("english", "win_tf2_randomat_tie", "IT'S A TIE")
        LANG.AddToLanguage("english", "win_tf2_randomat_red", "RED TEAM WINS")
        LANG.AddToLanguage("english", "win_tf2_randomat_blu", "BLU TEAM WINS")

        hook.Add("TTTScoringWinTitleOverride", "TF2RandomatWinTitle", function(wintype)
            local newTitle = {}

            if wintype == WIN_TIMELIMIT then
                newTitle.c = ROLE_COLORS[ROLE_NONE]
                newTitle.txt = "win_tf2_randomat_tie"
            elseif wintype == WIN_TRAITOR then
                newTitle.c = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
                newTitle.txt = "win_tf2_randomat_red"
            elseif wintype == WIN_INNOCENT then
                newTitle.c = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
                newTitle.txt = "win_tf2_randomat_blu"
            end

            return newTitle
        end)
    end

    hook.Add("TTTPrepareRound", "TF2RandomatReset", function()
        timer.Remove("TF2RandomatRespawnTimer")
        hook.Remove("PostDrawHUD", "TF2RandomatRespawnTimerHUD")
        hook.Remove("TTTScoringWinTitleOverride", "TF2RandomatWinTitle")
        hook.Remove("TTTPrepareRound", "TF2RandomatReset")
    end)
end)
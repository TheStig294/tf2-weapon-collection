net.Receive("TF2RandomatIntro", function()
    surface.PlaySound("music/meet_the_randomat.mp3")

    timer.Create("TF2RandomatIntroSplashScreen", 2, 1, function()
        local splashScreenMaterial = Material("vgui/ttt/meet_the_randomat.png")

        hook.Add("DrawOverlay", "TF2RandomatIntroSplashScreen", function()
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(splashScreenMaterial)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end)
    end)

    hook.Add("TTTPrepareRound", "TF2RandomatIntoReset", function()
        timer.Remove("TF2RandomatIntroSplashScreen")
        hook.Remove("DrawOverlay", "TF2RandomatIntroSplashScreen")
        hook.Remove("TTTPrepareRound", "TF2RandomatIntoReset")
    end)
end)

net.Receive("TF2RandomatRespawnTimer", function()
    local respawnTime = net.ReadUInt(6)
    local isEventBegin = net.ReadBool()
    local playMusic = net.ReadBool()
    local capturesToWin = net.ReadUInt(6)
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
            elseif respawnTime == 0 then
                local REDIntelCaptures = 0
                local BLUIntelCaptures = 0
                local REDIntelStatus = "AT BASE"
                local BLUIntelStatus = "AT BASE"

                net.Receive("TF2RandomatIntelStatusChanged", function()
                    local isBLUIntel = net.ReadBool()
                    local status = net.ReadString()

                    if status == "CAPTURED" then
                        status = "AT BASE"

                        if isBLUIntel then
                            BLUIntelCaptures = BLUIntelCaptures + 1
                        else
                            REDIntelCaptures = REDIntelCaptures + 1
                        end
                    end

                    if isBLUIntel then
                        BLUIntelStatus = status
                    else
                        REDIntelStatus = status
                    end
                end)

                hook.Add("HUDPaint", "TF2RandomatScoreHUD", function()
                    draw.WordBox(8, ScrW() / 2, TTT2 and (ScrH() / 11) or 65, "Capture the flag " .. capturesToWin .. " times to win", "TF2Font", color_black, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, (ScrW() / 2) - 50, TTT2 and (ScrH() / 8) or 105, "RED: " .. REDIntelCaptures, "TF2Font", COLOR_RED, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, (ScrW() / 2) - 350, TTT2 and (ScrH() / 8) or 105, "RED intel is: " .. REDIntelStatus, "TF2Font", COLOR_RED, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, (ScrW() / 2) + 50, TTT2 and (ScrH() / 8) or 105, "BLU: " .. BLUIntelCaptures, "TF2Font", COLOR_BLUE, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, (ScrW() / 2) + 350, TTT2 and (ScrH() / 8) or 105, "BLU intel is: " .. BLUIntelStatus, "TF2Font", COLOR_BLUE, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end)

                local clientTeam = client:GetNWString("TF2RandomatTeam", "")
                local BLUColour = Color(0, 255, 255)
                local REDColour = Color(255, 0, 0)

                hook.Add("PreDrawHalos", "TF2RandomatTeamOutlines", function()
                    local teamPlayers = {}

                    for _, ply in player.Iterator() do
                        if not ply:Alive() or ply:IsSpec() then continue end

                        if ply:GetNWString("TF2RandomatTeam", "") == clientTeam or ply:GetNWBool("disguised") then
                            table.insert(teamPlayers, ply)
                        end
                    end

                    halo.Add(teamPlayers, clientTeam == "RED" and REDColour or BLUColour, 1, 1, 3, true, true)
                end)
            end
        end
    end)

    hook.Add("PostDrawHUD", "TF2RandomatRespawnTimerHUD", function()
        if respawnTime <= 0 then
            hook.Remove("PostDrawHUD", "TF2RandomatRespawnTimerHUD")

            return
        end

        local message = "Respawning in " .. respawnTime .. " seconds, press [,] to change class"
        local xPos = TF2WC:GetXHUDOffset()
        local yPos = ScrH() - 50
        local alignment = TEXT_ALIGN_LEFT

        if isEventBegin then
            message = "Capture The Flag begins in " .. respawnTime .. " seconds..."
            xPos = ScrW() / 2
            yPos = 50
            alignment = TEXT_ALIGN_CENTER
        end

        draw.WordBox(8, xPos, yPos, message, "TF2Font", color_black, color_white, alignment)
    end)

    if isEventBegin then
        hook.Remove("DrawOverlay", "TF2RandomatIntroSplashScreen")

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

            -- Block the overhead icons so that disguised spies on the enemy team don't have the wrong icon above their head!
            hook.Add("TTTTargetIDPlayerBlockIcon", "TF2RandomatBlockOverheadIcons", function(_, _) return true end)
        end

        -- Adds a near-black-and-white filter to the screen
        local color_tbl = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        hook.Add("RenderScreenspaceEffects", "TF2RandomatIntroGreyscale", function()
            DrawColorModify(color_tbl)
            cam.Start3D(EyePos(), EyeAngles())
            render.SuppressEngineLighting(true)
            render.SetColorModulation(1, 1, 1)
            render.SuppressEngineLighting(false)
            cam.End3D()
        end)

        -- Draws 2 black bars on the screen, to make a cinematic letterbox effect
        local xPos = 0
        local yPos = 0
        local width = ScrW()
        local height = ScrH() / 7
        local xPos2 = 0
        local yPos2 = ScrH() - (ScrH() / 7)
        local width2 = ScrW()
        local height2 = ScrH() / 6

        hook.Add("HUDPaintBackground", "TF2RandomatIntroBlackBars", function()
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(xPos, yPos, width, height)
            surface.DrawRect(xPos2, yPos2, width2, height2)
        end)

        -- Fades in colour and moves black bars off the screen over 3 seconds
        timer.Create("TF2RandomatIntroFadeInBegin", 12, 1, function()
            timer.Create("TF2RandomatIntroFadeIn", 0.01, 200, function()
                if color_tbl["$pp_colour_colour"] + 0.005 <= 1 then
                    color_tbl["$pp_colour_colour"] = color_tbl["$pp_colour_colour"] + 0.005
                end

                height = height - 1
                yPos2 = yPos2 + 1
            end)
        end)

        if playMusic then
            surface.PlaySound("music/tf2_theme.mp3")

            timer.Simple(5, function()
                chat.AddText("Press 'M' to mute music")
            end)

            hook.Add("PlayerButtonDown", "TF2RandomatMusicMuteButton", function(_, button)
                if button == KEY_M then
                    RunConsoleCommand("stopsound")
                    chat.AddText("Music muted")
                    music = false
                    hook.Remove("PlayerButtonDown", "TF2RandomatMusicMuteButton")
                end
            end)
        end

        hook.Add("TTTPrepareRound", "TF2RandomatReset", function()
            timer.Remove("TF2RandomatRespawnTimer")
            hook.Remove("HUDPaint", "TF2RandomatScoreHUD")
            hook.Remove("PostDrawHUD", "TF2RandomatRespawnTimerHUD")
            hook.Remove("TTTScoringWinTitleOverride", "TF2RandomatWinTitle")
            hook.Remove("RenderScreenspaceEffects", "TF2RandomatIntroGreyscale")
            hook.Remove("HUDPaintBackground", "TF2RandomatIntroBlackBars")
            timer.Remove("TF2RandomatIntroFadeInBegin")
            timer.Remove("TF2RandomatIntroFadeIn")
            hook.Remove("PlayerButtonDown", "TF2RandomatMusicMuteButton")
            hook.Remove("TTTPrepareRound", "TF2RandomatReset")
        end)
    end
end)
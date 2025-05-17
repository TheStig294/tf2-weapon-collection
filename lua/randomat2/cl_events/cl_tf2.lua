net.Receive("TF2RandomatRespawnTimer", function()
    local respawnTime = net.ReadUInt(6)
    local client = LocalPlayer()

    timer.Create("TF2RandomatRespawnTimer", 1, respawnTime, function()
        if not IsValid(client) or client:Alive() or not client:IsSpec() then
            respawnTime = 0
            timer.Remove("TF2RandomatRespawnTimer")

            return
        end

        respawnTime = timer.RepsLeft("TF2RandomatRespawnTimer")
    end)

    hook.Add("HUDPaint", "TF2RandomatRespawnTimerHUD", function()
        if respawnTime <= 0 then
            hook.Remove("HUDPaint", "TF2RandomatRespawnTimerHUD")

            return
        end

        draw.WordBox(8, 265, ScrH() - 50, "Respawning in " .. respawnTime .. " seconds, press [,] to change class", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end)
end)
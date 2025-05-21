if SERVER then
    AddCSLuaFile()

    hook.Add("TF2ClassChanged", "TF2Spy_GiveDisguiser", function(ply, class)
        if class.name == "spy" then
            ply:GiveEquipmentItem(EQUIP_DISGUISE)
        end
    end)
end

if CLIENT then
    hook.Add("TF2ClassChanged", "TF2Spy_DisguiserPrompt", function(ply, class)
        if class.name == "spy" then
            local hookname = "TF2Spy_DisguisePrompt"

            hook.Add("HUDPaint", hookname, function()
                if ply:GetNWBool("disguised") or GetRoundState() ~= ROUND_ACTIVE or not TF2WC:IsClass(ply, "spy") then
                    hook.Remove("HUDPaint", hookname)

                    return
                end

                draw.WordBox(8, 265, ScrH() - 50, "Press numpad enter to enable disguise", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
            end)
        end
    end)
end
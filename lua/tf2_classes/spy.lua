if SERVER then
    hook.Add("TF2ClassChanged", "TF2Spy_GiveDisguiser", function(ply, class)
        if class and class.name == "spy" then
            local disguiser = TTT2 and "item_ttt_disguiser" or EQUIP_DISGUISE
            ply:GiveEquipmentItem(disguiser)
        end
    end)
end

if CLIENT then
    hook.Add("TF2ClassChanged", "TF2Spy_DisguiserPrompt", function(ply, class)
        if class and class.name == "spy" then
            local hookname = "TF2Spy_DisguisePrompt"

            hook.Add("HUDPaint", hookname, function()
                if ply:GetNWBool("disguised") or (GetRoundState and GetRoundState() ~= ROUND_ACTIVE) or not TF2WC:IsClass(ply, "spy") then
                    hook.Remove("HUDPaint", hookname)

                    return
                end

                draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Press numpad enter to enable disguise", "TF2Font", color_black, color_white, TEXT_ALIGN_LEFT)
            end)
        end
    end)
end
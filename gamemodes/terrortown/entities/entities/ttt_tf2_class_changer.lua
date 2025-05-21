if TTT2 or engine.ActiveGamemode() ~= "terrortown" then return end
AddCSLuaFile()
EQUIP_TF2_CLASS_CHANGER = GenerateNewEquipmentID and GenerateNewEquipmentID() or 2849

local TF2ClassChanger = {
    id = EQUIP_TF2_CLASS_CHANGER,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ttt_tf2_class_changer.png",
    name = "Change TF2 Class",
    desc = "Buy this to change your class!\n\nIf you are a RED or BLU Mann, press comma [,] instead."
}

hook.Add("TTTOrderedEquipment", "TF2ClassChangerItemPurchase", function(ply, equipment, _)
    if equipment == EQUIP_TF2_CLASS_CHANGER then
        -- This is defined below, where all the magic happens...
        net.Start("TF2ClassChangerScreen")
        net.Send(ply)

        -- Removes the equipment from the player, to make the item re-buyable
        timer.Simple(0.1, function()
            -- Use the remove method if it exists
            if ply.RemoveEquipmentItem then
                ply:RemoveEquipmentItem(EQUIP_TF2_CLASS_CHANGER)
            else
                -- Do an exclusive OR bitwise operation, so the only bit that will be affected is our item's equipment bit
                ply.equipment_items = bit.bxor(ply.equipment_items, EQUIP_TF2_CLASS_CHANGER)
                ply:SendEquipment()
            end
        end)
    end
end)

hook.Add("TTTPrepareRound", "TF2ClassChangerItemRegister", function()
    if ROLE_REDMANN then
        table.insert(EquipmentItems[ROLE_REDMANN], TF2ClassChanger)
        table.insert(EquipmentItems[ROLE_BLUMANN], TF2ClassChanger)
    end

    hook.Remove("TTTPrepareRound", "TF2ClassChangerItemRegister")

    if SERVER then
        util.AddNetworkString("TF2ClassChangerScreen")

        net.Receive("TF2ClassChangerScreen", function(_, ply)
            local class = net.ReadUInt(4)

            if not ROLE_REDMANN then
                if ply:Alive() and not ply:IsSpec() then
                    TF2WC:StripAndGiveLoadout(ply, TF2WC.Classes[class].loadout)
                    TF2WC:DoSpawnSound(ply, TF2WC.Classes[class])
                end
            elseif ply:IsTraitorTeam() then
                if ply:GetRole() ~= ROLE_REDMANN then
                    ply:SetRole(ROLE_REDMANN)

                    timer.Simple(1, function()
                        SendFullStateUpdate()
                    end)
                end

                TF2WC:SetClass(ply, class)
            else
                if ply:GetRole() ~= ROLE_BLUMANN then
                    ply:SetRole(ROLE_BLUMANN)

                    timer.Simple(1, function()
                        SendFullStateUpdate()
                    end)
                end

                TF2WC:SetClass(ply, class)
            end
        end)
    end

    if CLIENT then
        net.Receive("TF2ClassChangerScreen", function()
            local client = LocalPlayer()

            -- Playing the looping background music
            if not GetGlobal2Bool("TF2ClassChangerDisableMusic") then
                client:EmitSound("music/class_menu_bg.wav")
            end

            gui.EnableScreenClicker(true)
            -- Selecting a class
            local screenMats = {}
            local screenSounds = {}

            for i = 1, 9 do
                local mat = Material("vgui/ttt/tf2_class_screens/" .. i .. ".jpg")
                local snd = Sound("music/class_menu_0" .. i .. ".wav")
                table.insert(screenMats, mat)
                table.insert(screenSounds, snd)
            end

            local cursorX, cursorY = 0, 0
            local selectedClass = 1

            -- % across the screen in width the cursor has to be to have a class selected
            -- E.g. If the cursor is in the first 20% of the screen from the left, then the Scout would be selected (The first class from the left on the screen)
            local classSections = {0.20, 0.26, 0.34, 0.43, 0.49, 0.56, 0.65, 0.70, 1}

            local function SelectClass(class)
                net.Start("TF2ClassChangerScreen")
                net.WriteUInt(class, 4)
                net.SendToServer()
                hook.Remove("DrawOverlay", "TF2ClassChangerScreen")
                hook.Remove("TTTPrepareRound", "TF2ClassChangerReset")
                timer.Remove("TF2ClassChangerScreenTimeout")
                client:StopSound("music/class_menu_bg.wav")
                gui.EnableScreenClicker(false)
            end

            -- So, DrawOverlay is a little dangerous as it covers the pause screen, meaning if an error occurred, the player would be stuck.
            -- So the first thing we're doing here is setting up a separate timer to kill the class changer screen after a few seconds, just in case
            -- Also... why not just use PostDrawHUD? Because it has the irritating property where if a centre-screen message appears,
            -- all PostDrawHUDs get displaced downwards for the duration of the message, where setting something to be at y = 0, is actually halfway down the screen...
            timer.Create("TF2ClassChangerScreenTimeout", 15, 1, function()
                SelectClass(selectedClass)
            end)

            hook.Add("DrawOverlay", "TF2ClassChangerScreen", function()
                cursorX, cursorY = gui.MouseX(), gui.MouseY()

                -- If the mouse is in the top part of the screen, start switching the class selected
                if cursorY < ScrH() / 4 then
                    for class, sectionPercent in ipairs(classSections) do
                        if cursorX / ScrW() < sectionPercent then
                            if selectedClass ~= class then
                                client:StopSound(screenSounds[selectedClass])
                                selectedClass = class
                                client:EmitSound(screenSounds[class])
                            end

                            break
                        end
                    end

                    if input.IsMouseDown(MOUSE_LEFT) then
                        SelectClass(selectedClass)

                        return
                    end
                end

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(screenMats[selectedClass])
                surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            end)

            hook.Add("TTTPrepareRound", "TF2ClassChangerReset", function()
                client:StopSound("music/class_menu_bg.wav")
                gui.EnableScreenClicker(false)
                hook.Remove("DrawOverlay", "TF2ClassChangerScreen")
                hook.Remove("TTTPrepareRound", "TF2ClassChangerReset")
                timer.Remove("TF2ClassChangerScreenTimeout")
            end)
        end)
    end
end)
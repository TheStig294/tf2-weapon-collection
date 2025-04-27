if TTT2 or engine.ActiveGamemode() ~= "terrortown" then return end
AddCSLuaFile()
EQUIP_TF2_CLASS_CHANGER = GenerateNewEquipmentID and GenerateNewEquipmentID() or 2849

local TF2ClassChanger = {
    id = EQUIP_TF2_CLASS_CHANGER,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ttt_tf2_class_changer.png",
    name = "Change TF2 Class",
    desc = "Buy this to change your class!\n\nIf you are a RED/BLU Mann, you haven't chosen a class yet.\n\nSo, you get 1 class change for free by pressing the comma key [,]!"
}

hook.Add("TTTOrderedEquipment", "TF2ClassChangerItemPurchase", function(ply, equipment, _)
    if equipment == EQUIP_TF2_CLASS_CHANGER then
        -- This is defined below, where all the magic happens...
        ply:ConCommand("ttt_tf2_class_changer")

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
    table.insert(EquipmentItems[ROLE_REDMANN], TF2ClassChanger)
    table.insert(EquipmentItems[ROLE_BLUMANN], TF2ClassChanger)

    -- 
    -- TODO: Uncomment once all roles are added
    -- 
    -- for _, role in ipairs(TF2WC.REDRolesList) do
    --     table.insert(EquipmentItems[role], TF2ClassChanger)
    -- end
    -- for _, role in ipairs(TF2WC.BLURolesList) do
    --     table.insert(EquipmentItems[role], TF2ClassChanger)
    -- end
    for _, role in pairs(TF2WC.REDRolesList) do
        table.insert(EquipmentItems[role], TF2ClassChanger)
    end

    for _, role in pairs(TF2WC.BLURolesList) do
        table.insert(EquipmentItems[role], TF2ClassChanger)
    end

    hook.Remove("TTTPrepareRound", "TF2ClassChangerItemRegister")

    if SERVER then
        util.AddNetworkString("TF2ClassChangerScreen")

        local function ClassChangerScreen(ply)
            if not TF2WC:IsValidTF2Role(ply) then return end
            net.Start("TF2ClassChangerScreen")
            net.Send(ply)
        end

        concommand.Add("ttt_tf2_class_changer", ClassChangerScreen, nil, "Brings up the class selection screen for the TTT TF2 Roles")

        net.Receive("TF2ClassChangerScreen", function(_, ply)
            local class = net.ReadUInt(4)
            if not TF2WC:IsValidTF2Role(ply) then return end

            if TF2WC.REDRoles[ply:GetRole()] then
                ply:SetRole(TF2WC.REDRolesList[class])
            else
                ply:SetRole(TF2WC.BLURolesList[class])
            end

            timer.Simple(1, function()
                SendFullStateUpdate()
            end)
        end)
    end

    if CLIENT then
        local client = LocalPlayer()

        net.Receive("TF2ClassChangerScreen", function()
            if not TF2WC:IsValidTF2Role(client) then return end
            -- Playing the looping background music
            client:EmitSound("music/class_menu_bg.wav")
            gui.EnableScreenClicker(true)
            -- Selecting a class
            local originalRole = client:GetRole()
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

            hook.Add("PostDrawHUD", "TF2ClassChangerScreen", function()
                if client:GetRole() ~= originalRole then
                    hook.Remove("PostDrawHUD", "TF2ClassChangerScreen")
                    client:StopSound("music/class_menu_bg.wav")
                    gui.EnableScreenClicker(false)

                    return
                end

                cursorX, cursorY = gui.MouseX(), gui.MouseY()

                -- If the mouse is in the top part of the screen, start switching the class selected
                if cursorY < ScrH() / 4 then
                    for class, sectionPercent in ipairs(classSections) do
                        if cursorX / ScrW() < sectionPercent then
                            if selectedClass ~= class then
                                selectedClass = class
                                surface.PlaySound(screenSounds[class])
                            end

                            break
                        end
                    end

                    if input.IsMouseDown(MOUSE_LEFT) then
                        net.Start("TF2ClassChangerScreen")
                        net.WriteUInt(selectedClass, 4)
                        net.SendToServer()
                        hook.Remove("PostDrawHUD", "TF2ClassChangerScreen")
                        client:StopSound("music/class_menu_bg.wav")
                        gui.EnableScreenClicker(false)

                        return
                    end
                end

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(screenMats[selectedClass])
                surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            end)
        end)
    end
end)
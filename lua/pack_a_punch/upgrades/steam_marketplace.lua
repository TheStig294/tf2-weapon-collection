local UPGRADE = {}
UPGRADE.id = "steam_marketplace"
UPGRADE.class = "weapon_ttt_tf2_goldenfryingpan"
UPGRADE.name = "Steam Marketplace"
UPGRADE.desc = "Sells anything you hit!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    if SERVER then
        util.AddNetworkString("TTTPAPSteamMarketplaceHit")
        util.AddNetworkString("TTTPAPSteamMarketplacePickupGoldWeapon")

        self:AddHook("EntityTakeDamage", function(ent, dmg)
            if not IsValid(ent) then return end
            if ent:GetMaterial() == "models/player/shared/gold_player" then return end
            local attacker = dmg:GetAttacker()
            if not IsValid(attacker) then return end
            local inflictor = dmg:GetInflictor()
            if not self:IsValidUpgrade(inflictor) then return end
            net.Start("TTTPAPSteamMarketplaceHit")
            net.WriteEntity(ent)
            net.Send(attacker)
            dmg:SetDamage(10000)
            inflictor:RagToGold(ent)
        end)

        self:AddHook("WeaponEquip", function(wep, owner)
            if IsValid(wep) and wep:GetMaterial() == "models/player/shared/gold_player" then
                net.Start("TTTPAPSteamMarketplacePickupGoldWeapon")
                net.WriteEntity(wep)
                net.Send(owner)
            end
        end)
    end

    if CLIENT then
        local priceNumbers = {"420", "69", "8,008", "1,337", "2,845", "8,675,309", "1,300,655,506", "42", "XJ0,461", "-0", "0.03", "0,118", "999", "88,199", "9,119", "725,3"}

        local nextPlayNotifSound = CurTime()
        local notifSoundCooldown = 10
        local backgroundColor = Color(42, 39, 37)
        local backR, backG, backB = backgroundColor:Unpack()
        local textBackgroundColor = Color(51, 47, 45)
        local backTextR, backTextG, backTextB = textBackgroundColor:Unpack()
        local textColor = Color(236, 227, 203)
        local orangeColor = Color(201, 79, 57)
        local yellowColor = Color(255, 216, 0)
        local greyColor = Color(118, 107, 94)

        net.Receive("TTTPAPSteamMarketplaceHit", function()
            local ent = net.ReadEntity()
            if not IsValid(ent) then return end
            local model = ent:GetModel()
            if not model or not util.IsValidModel(model) then return end

            if nextPlayNotifSound < CurTime() then
                surface.PlaySound("ttt_pack_a_punch/steam_marketplace/notification.wav")
                nextPlayNotifSound = CurTime() + notifSoundCooldown
            end

            -- Background
            local frame = vgui.Create("DFrame")
            frame:SetPos(200, 200)
            frame:SetSize(300, 400)
            frame:SetTitle("")
            frame:ShowCloseButton(false)

            frame.Paint = function()
                surface.SetDrawColor(backR, backG, backB)
                surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
            end

            timer.Simple(10, function()
                if IsValid(frame) then
                    frame:Close()
                end
            end)

            -- Top Text
            local topListPnl = vgui.Create("DIconLayout", frame)
            topListPnl:Dock(TOP)
            topListPnl:SetSpaceY(8)
            topListPnl:SetBorder(5)

            topListPnl.Paint = function()
                surface.SetDrawColor(backTextR, backTextG, backTextB)
                surface.DrawRect(0, 0, topListPnl:GetWide(), topListPnl:GetTall())
            end

            local topText1 = topListPnl:Add("DLabel")
            topText1:SetText("New item acquired!")
            topText1:SetFont("TF2Font")
            topText1:SetColor(textColor)
            topText1:SizeToContents()
            topText1.OwnLine = true
            local topText2 = topListPnl:Add("DLabel")
            topText2:SetText("You ")
            topText2:SetFont("TF2Font")
            topText2:SetColor(textColor)
            topText2:SizeToContents()
            local topText3 = topListPnl:Add("DLabel")
            topText3:SetText("found")
            topText3:SetFont("TF2Font")
            topText3:SetColor(orangeColor)
            topText3:SizeToContents()
            local topText4 = topListPnl:Add("DLabel")
            topText4:SetText(":")
            topText4:SetFont("TF2Font")
            topText1:SetColor(textColor)
            topText4:SizeToContents()
            -- Model Preview
            local modelPnl = vgui.Create("DModelPanel", frame)

            if ent:IsPlayer() then
                modelPnl:SetPos(0, 50)
            end

            modelPnl.DoClick = function()
                if IsValid(frame) then
                    frame:Close()
                end
            end

            modelPnl:SetSize(frame:GetWide(), frame:GetWide())
            modelPnl:SetModel(model)
            -- Position camera
            local camPos = Vector(0, 60, 36)

            if not self:IsPlayer(ent) then
                camPos = Vector(0, 50, -40)
                modelPnl:SetFOV(50)
            end

            modelPnl:SetCamPos(camPos)
            local rotation = 0

            function modelPnl:LayoutEntity(modelEnt)
                -- Point camera toward the look pos
                local lookAng = (self.vLookatPos - self.vCamPos):Angle()
                -- Set camera look angles
                self:SetLookAng(lookAng)
                -- Make entity rotate
                modelEnt:SetAngles(Angle(0, rotation, 0))
                rotation = rotation + 0.5
            end

            -- Bottom Text
            local name = ent.PrintName or ""

            if self:IsPlayer(ent) then
                name = ent:Nick()
            else
                name = LANG.TryTranslation(name)
            end

            local entType = "Prop"

            if ent:IsPlayer() then
                entType = "Player"
            elseif ent:IsWeapon() then
                entType = "Weapon"
            elseif ent:IsNPC() then
                entType = "NPC"
            elseif ent.Base and ent.Base == "base_ammo_ttt" then
                entType = "Ammo Box"
            elseif ent.player_ragdoll then
                entType = "Body"
            end

            local bottomListPnl = vgui.Create("DIconLayout", frame)
            bottomListPnl:Dock(BOTTOM)
            bottomListPnl:SetSpaceY(8)
            bottomListPnl:SetBorder(5)
            bottomListPnl:SetBackgroundColor(textBackgroundColor)

            bottomListPnl.Paint = function()
                surface.SetDrawColor(backTextR, backTextG, backTextB)
                surface.DrawRect(0, 0, bottomListPnl:GetWide(), bottomListPnl:GetTall())
            end

            if name and name ~= "" then
                local bottomText1 = bottomListPnl:Add("DLabel")
                bottomText1:SetText(name)
                bottomText1:SetFont("TF2Font")
                bottomText1:SetColor(yellowColor)
                bottomText1:SizeToContents()
                bottomText1.OwnLine = true
            end

            local bottomText2 = bottomListPnl:Add("DLabel")
            bottomText2:SetText("Level " .. math.random(1, 100) .. " " .. entType)
            bottomText2:SetFont("TF2Font")
            bottomText2:SetColor(greyColor)
            bottomText2:SizeToContents()
            bottomText2.OwnLine = true
            local bottomText3 = bottomListPnl:Add("DLabel")
            bottomText3:SetText("Sold for $" .. priceNumbers[math.random(#priceNumbers)] .. ".")
            bottomText3:SetFont("TF2Font")
            bottomText3:SetColor(textColor)
            bottomText3:SizeToContents()
            bottomText3.OwnLine = true
        end)

        net.Receive("TTTPAPSteamMarketplacePickupGoldWeapon", function()
            local wep = net.ReadEntity()
            wep:SetMaterial("models/player/shared/gold_player")

            self:AddHook("PreDrawViewModel", function(vm, _, vmWeapon)
                if IsValid(vmWeapon) and IsValid(wep) and vmWeapon == wep then
                    vm:SetMaterial("models/player/shared/gold_player")
                else
                    vm:SetMaterial("")
                end
            end)
        end)
    end
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "invisivolver"
UPGRADE.class = "weapon_ttt_tf2_revolver"
UPGRADE.name = "Invisivolver"
UPGRADE.desc = "Kills turn you invisible for 10 stacking seconds"
UPGRADE.noSound = true
UPGRADE.noCamo = true

function UPGRADE:Apply(SWEP)
    if SERVER then
        util.AddNetworkString("TF2InvisivolverInvisible")
    end

    self:AddHook("DoPlayerDeath", function(_, attacker, dmg)
        if not IsValid(attacker) then return end
        local inflictor = attacker:GetActiveWeapon()
        if not self:IsValidUpgrade(inflictor) then return end
        local invisTime = attacker.TF2InvisivolverTime or 0
        attacker.TF2InvisivolverTime = invisTime + 10
        attacker:SetMaterial("models/player/spy/cloak_3")
        inflictor:SetMaterial("models/player/spy/cloak_3")
        attacker:EmitSound("player/spy_cloak.wav")
        net.Start("TF2InvisivolverInvisible")
        net.WriteUInt(attacker.TF2InvisivolverTime, 8)
        net.Send(attacker)
        local timername = "TF2Invisivolver" .. attacker:SteamID64()

        timer.Create(timername, 1, attacker.TF2InvisivolverTime, function()
            if not IsValid(attacker) then
                timer.Remove(timername)

                return
            end

            if timer.RepsLeft(timername) == 0 then
                attacker:SetMaterial("")
                attacker:EmitSound("player/spy_uncloak.wav")
                local wep = attacker:GetActiveWeapon()

                if IsValid(wep) and wep:GetMaterial() == "models/player/spy/cloak_3" then
                    wep:SetMaterial("")
                end
            else
                attacker.TF2InvisivolverTime = attacker.TF2InvisivolverTime - 1
            end
        end)
    end)

    self:AddHook("PlayerSwitchWeapon", function(ply, oldWep, newWep)
        if ply.TF2InvisivolverTime and ply.TF2InvisivolverTime > 0 then
            if IsValid(oldWep) then
                oldWep:SetMaterial("")
            end

            if IsValid(newWep) then
                newWep:SetMaterial("models/player/spy/cloak_3")
            end
        end
    end)

    if CLIENT then
        local client = LocalPlayer()

        net.Receive("TF2InvisivolverInvisible", function()
            local time = net.ReadUInt(8)
            client.TF2InvisivolverTime = time

            hook.Add("PostDrawViewModel", "TF2InvisivolverViewModel", function(vm, _, _)
                if vm:GetMaterial() ~= "models/player/spy/cloak_3" then
                    vm:SetMaterial("models/player/spy/cloak_3")
                end
            end)

            timer.Create("TF2InvisivolverViewModelReset", 1, time, function()
                if timer.RepsLeft("TF2InvisivolverViewModelReset") == 0 then
                    hook.Remove("PostDrawViewModel", "TF2InvisivolverViewModel")
                    client.TF2InvisivolverTime = nil
                    local vm = LocalPlayer():GetViewModel()

                    if IsValid(vm) then
                        vm:SetMaterial("")
                    end
                else
                    client.TF2InvisivolverTime = client.TF2InvisivolverTime - 1
                end
            end)
        end)

        function SWEP:DrawHUD()
            if client.TF2InvisivolverTime then
                draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Invis time: " .. client.TF2InvisivolverTime, "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
            end
        end
    end
end

function UPGRADE:Reset()
    for _, ply in player.Iterator() do
        timer.Remove("TF2Invisivolver" .. ply:SteamID64())
        ply:SetMaterial("")
        ply.TF2InvisivolverTime = nil
    end

    if CLIENT then
        hook.Remove("PostDrawViewModel", "TF2InvisivolverViewModel")
        timer.Remove("TF2InvisivolverViewModelReset")
        local vm = LocalPlayer():GetViewModel()

        if IsValid(vm) then
            vm:SetMaterial("")
        end
    end
end

TTTPAP:Register(UPGRADE)
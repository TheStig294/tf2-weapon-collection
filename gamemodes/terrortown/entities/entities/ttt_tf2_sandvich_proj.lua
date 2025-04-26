AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/c_models/c_sandwich/c_sandwich.mdl")
ENT.Duration = 15

function ENT:Initialize()
    return self.BaseClass.Initialize(self)
end

function ENT:ActivateSandvich(ply)
    ply.TF2SandvichHealth = ply:Health()
    ply.TF2SandvichSeconds = self.Duration

    if ply:Health() < ply:GetMaxHealth() then
        ply:SetHealth(ply:GetMaxHealth())
    end

    self:EmitSound("player/heavy/sandvich" .. math.random(12) .. ".wav")
    local timername = "TF2Sandvich" .. ply:SteamID64()

    timer.Create(timername, 1, self.Duration, function()
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or not ply.TF2SandvichHealth or not ply.TF2SandvichSeconds then
            ply.TF2SandvichHealth = nil
            ply.TF2SandvichSeconds = nil
            timer.Remove(timername)

            return
        end

        if timer.RepsLeft(timername) == 0 then
            if ply.TF2SandvichHealth > ply:Health() then return end
            ply:SetHealth(ply.TF2SandvichHealth)
            ply.TF2SandvichHealth = nil
            ply.TF2SandvichSeconds = nil
        else
            ply.TF2SandvichSeconds = ply.TF2SandvichSeconds - 1
        end
    end)

    if CLIENT then
        local client = LocalPlayer()

        hook.Add("HUDPaintBackground", "TF2SandvichHUDSeconds", function()
            if not client.TF2SandvichSeconds then return end
            draw.WordBox(8, 265, ScrH() - 50, "Sandvich Time: " .. client.TF2SandvichSeconds, "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
        end)
    end

    hook.Add("TTTPrepareRound", "TF2SandvichHealthReset", function()
        for _, p in player.Iterator() do
            p.TF2SandvichHealth = nil
            p.TF2SandvichSeconds = nil
        end

        hook.Remove("TTTPrepareRound", "TF2SandvichHealthReset")
        hook.Remove("HUDPaintBackground", "TF2SandvichHUDSeconds")
    end)
end

function ENT:PhysicsCollide(collisionData)
    self:Explode(collisionData.HitEntity)
end

function ENT:Explode(ent)
    if IsValid(ent) and ent:IsPlayer() then
        self:ActivateSandvich(ent)
    end

    self:EmitSound("weapons/blade_hit" .. math.random(4) .. ".wav")
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("AntlionGib", effect, true, true)

    if SERVER then
        self:Remove()
    end
end
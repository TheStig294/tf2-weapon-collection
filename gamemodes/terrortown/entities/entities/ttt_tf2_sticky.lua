AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Sticky Bomb"
ENT.Damage = 60
ENT.SelfDamage = true
ENT.ExplodeSound = "weapons/rocket_explosion.wav"
ENT.DamageForce = 1

function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_stickybomb.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:DrawShadow(false)
    ParticleEffectAttach("stickybombtrail_red", PATTACH_POINT_FOLLOW, self, 0)
    self.Activation = false
    self.ActivationTimer = CurTime() + 0.7
    self.ExplodeTimer = CurTime() + 2.3
    self.NoDamage = false
end

function ENT:Think()
    if not self.Activation and self.ActivationTimer <= CurTime() then
        ParticleEffectAttach("stickybomb_pulse_red", PATTACH_POINT_FOLLOW, self, 0)
        self.Activation = true
    end

    if SERVER then
        local owner = self.StickyOwner
        if not IsValid(owner) then return end
        local wep = owner:GetActiveWeapon()
        if not IsValid(wep) then return end
        local inflictorWep = self.Weapon
        if not IsValid(inflictorWep) then return end

        if owner:KeyDown(IN_ATTACK2) and self.Activation and WEPS.GetClass(wep) == WEPS.GetClass(inflictorWep) then
            owner:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")
            self:Remove()
        end
    end
end

function ENT:PhysicsCollide()
    if CLIENT then return end
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end

function ENT:OnRemove()
    local owner = self.StickyOwner

    if not IsValid(owner) then
        owner = self
    end

    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    effect:SetMagnitude(5)
    effect:SetNormal(Vector(0, 0, 1))
    effect:SetScale(0.5)
    effect:SetRadius(2)

    if SERVER then
        if self.NoDamage then
            util.Effect("Sparks", effect, true, true)
            self:EmitSound("ambient/energy/spark1.wav", 100, math.random(75, 125))
        else
            util.Effect("HelicopterMegaBomb", effect, true, true)
            self:EmitSound(self.ExplodeSound, 100, math.random(75, 125))
            local inflictor = self.Weapon

            if not IsValid(inflictor) then
                inflictor = self
            end

            local dmg = DamageInfo()
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetAttacker(owner)
            dmg:SetInflictor(inflictor)
            dmg:SetDamage(self.Damage)

            for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Range or 140)) do
                if IsValid(ent) and (self.SelfDamage or owner ~= ent) then
                    ent:TakeDamageInfo(dmg)
                end

                if self.DamageForce then
                    local normal = (ent:GetPos() - self:GetPos()):GetNormalized()
                    ent:SetVelocity(normal * self.DamageForce)
                end
            end
        end
    end
end

function ENT:OnTakeDamage()
    self.NoDamage = true
    self:Remove()
end
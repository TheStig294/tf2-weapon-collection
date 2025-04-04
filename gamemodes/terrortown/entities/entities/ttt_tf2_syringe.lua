AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Syringe-Gun Syringe"

function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/weapons/w_models/w_syringe_proj.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
        self:DrawShadow(false)

        timer.Simple(10, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function ENT:PhysicsCollide(data)
    if self.NoDamage then return end
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    local dmg = DamageInfo()
    local owner = self:GetOwner()

    if not IsValid(self) then
        owner = self
    end

    local inflictor = self.Weapon

    if not IsValid(self.Weapon) then
        inflictor = self
    end

    dmg:SetAttacker(owner)
    dmg:SetInflictor(inflictor)
    dmg:SetDamage(self.Damage or 10)
    dmg:SetDamageType(DMG_BULLET)
    local ent = data.HitEntity

    if IsValid(ent) and not self.NoDamage then
        ent:TakeDamageInfo(dmg)
    end

    if ent:IsNPC() or ent:IsPlayer() then
        self:Remove()
    end

    self.NoDamage = true
end
SWEP.PrintName = "Ullapool Caber"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_caber/c_caber.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Higher DPS than the crowbar!\n\nExplode and launch players into the air on the first hit!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_caber.png"
    SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128
SWEP.Primary.Radius = 200
SWEP.Primary.ExplosionDamage = 40

SWEP.Primary.Anims = {"b_swing_a", "b_swing_b", "b_swing_c"}

SWEP.SwitchedViewModel = false
SWEP.SwitchedWorldModel = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    TF2WC:SandboxSetup(self)
    self:SetExploded(false)

    -- Mute the explosion ringing sound
    hook.Add("OnDamagedByExplosion", "TF2CaberNoExplosionSound", function(_, dmg)
        local inflictor = dmg:GetInflictor()
        if IsValid(inflictor) and inflictor:GetClass() == "weapon_ttt_tf2_caber" then return true end
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:SecondaryAttack()
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", "Exploded")
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("b_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence(self.Primary.Anims[math.random(#self.Primary.Anims)]))
    owner:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound(self.Primary.Sound)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:OnEntHit(ent)
    if ent:IsPlayer() and ent:Alive() and not ent:IsSpec() then
        self:EmitSound("weapons/bottle_hit_flesh" .. math.random(3) .. ".wav")
        self:Explode()
    elseif ent:GetClass() == "prop_ragdoll" then
        self:EmitSound("weapons/bottle_hit_flesh" .. math.random(3) .. ".wav")
    elseif not ent:IsPlayer() then
        self:EmitSound("weapons/bottle_hit" .. math.random(3) .. ".wav")
    end
end

function SWEP:Explode()
    if self:GetExploded() then return end
    self:SetExploded(true)
    self.WorldModel = "models/weapons/c_models/c_caber/c_caber_exploded.mdl"
    self:TakePrimaryAmmo(1)
    local attacker = self:GetOwner()

    if not IsValid(attacker) then
        attacker = self
    end

    self:EmitSound("weapons/rocket_explosion.wav", 75, math.random(75, 125))
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)

    if SERVER then
        attacker:EmitSound("player/demoman/kaboom" .. math.random(2) .. ".wav")
        local dmg = DamageInfo()
        dmg:SetDamage(self.Primary.ExplosionDamage)
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetInflictor(self)
        dmg:SetAttacker(attacker)

        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Primary.Radius)) do
            if IsValid(ent) and ent:IsPlayer() and not ent.TF2CaberDamageCooldown then
                ent:TakeDamageInfo(dmg)
                ent:SetGroundEntity(NULL)
                ent:SetVelocity(Vector(0, 0, 500))
                ent.TF2CaberDamageCooldown = true

                timer.Simple(0.2, function()
                    if IsValid(ent) then
                        ent.TF2CaberDamageCooldown = nil
                    end
                end)
            end
        end
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Attack == 1 and self.AttackTimer <= CurTime() then
        if owner.LagCompensation then
            owner:LagCompensation(true)
        end

        local spos = owner:GetShootPos()
        local sdest = spos + (owner:GetAimVector() * self.Primary.Range)

        local tr_main = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = owner,
            mask = MASK_SHOT_HULL
        })

        local hitEnt = tr_main.Entity

        if IsValid(hitEnt) or tr_main.HitWorld and not (CLIENT and (not IsFirstTimePredicted())) then
            local edata = EffectData()
            edata:SetStart(spos)
            edata:SetOrigin(tr_main.HitPos)
            edata:SetNormal(tr_main.Normal)
            edata:SetSurfaceProp(tr_main.SurfaceProps)
            edata:SetHitBox(tr_main.HitBox)
            edata:SetEntity(hitEnt)

            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                util.Effect("BloodImpact", edata)
                owner:LagCompensation(false)

                owner:FireBullets({
                    Num = 1,
                    Src = spos,
                    Dir = owner:GetAimVector(),
                    Spread = Vector(0, 0, 0),
                    Tracer = 0,
                    Force = 1,
                    Damage = 0
                })
            else
                util.Effect("Impact", edata)
            end

            self:OnEntHit(hitEnt)
        end

        if SERVER then
            owner:SetAnimation(PLAYER_ATTACK1)

            if hitEnt and hitEnt:IsValid() then
                local dmg = DamageInfo()
                dmg:SetDamage(self.Primary.Damage)
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                dmg:SetDamageForce(owner:GetAimVector() * 1500)
                dmg:SetDamagePosition(owner:GetPos())
                dmg:SetDamageType(DMG_CLUB)
                hitEnt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
            end
        end

        if owner.LagCompensation then
            owner:LagCompensation(false)
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("b_idle"))
        end

        self.Idle = 1
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_caber/c_caber.mdl", RENDERGROUP_VIEWMODEL)
        elseif self:GetExploded() and not self.SwitchedViewModel then
            self.v_model = ClientsideModel("models/weapons/c_models/c_caber/c_caber_exploded.mdl", RENDERGROUP_VIEWMODEL)
            self.SwitchedViewModel = true
        end

        self.v_model:SetPos(vm:GetPos())
        self.v_model:SetAngles(vm:GetAngles())
        self.v_model:AddEffects(EF_BONEMERGE)
        self.v_model:SetNoDraw(true)
        self.v_model:SetParent(vm)
        self.v_model:DrawModel()
    end

    local w_model = ClientsideModel(SWEP.WorldModel)
    w_model:SetNoDraw(true)
    local offsetvec = Vector(2.596, 0, 0)
    local offsetang = Angle(180, 90, 0)
    local client

    function SWEP:DrawWorldModel(flags)
        if not IsValid(client) then
            client = LocalPlayer()
        end

        local owner = self:GetOwner()
        local spectatedPlayer = client:GetObserverTarget()

        if not IsValid(owner) or (IsValid(spectatedPlayer) and spectatedPlayer == owner) then
            self:DrawModel(flags)

            return
        end

        if self:GetExploded() and not self.SwitchedWorldModel and owner:Alive() and not owner:IsSpec() then
            w_model:Remove()
            self.WorldModel = "models/weapons/c_models/c_caber/c_caber_exploded.mdl"
            w_model = ClientsideModel("models/weapons/c_models/c_caber/c_caber_exploded.mdl")
            w_model:SetNoDraw(true)
            offsetang.x = -90
            offsetang.y = 180
            self.SwitchedWorldModel = true
        end

        local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneid then return end
        local matrix = owner:GetBoneMatrix(boneid)
        if not matrix then return end
        local newpos, newang = LocalToWorld(offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles())

        if not IsValid(self.w_model) then
            self.w_model = w_model
        end

        self.w_model:SetPos(newpos)
        self.w_model:SetAngles(newang)
        self.w_model:SetupBones()
        self.w_model:DrawModel()
    end
end
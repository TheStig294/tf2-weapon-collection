SWEP.PrintName = "Eureka Effect"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_engineer_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_drg_wrenchmotron/c_drg_wrenchmotron.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Higher DPS than the crowbar!\n\nPress Reload for a 1-time teleport to a spawn point!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_eurekaeffect.png"
    SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.Primary.Sound = Sound("Weapon_Wrench.Miss")
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128

SWEP.Primary.Anims = {"spk_swing_a", "spk_swing_b", "spk_swing_c"}

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    TF2WC:SandboxSetup(self)

    return self.BaseClass.Initialize(self)
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("spk_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()

    return self.BaseClass.Deploy(self)
end

function SWEP:Teleport()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self:Clip1() <= 0 then return end
    self:TakePrimaryAmmo(1)
    owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_TAUNT_CHEER, true)
    self:EmitSound("weapons/drg_wrench_teleport.wav")
    self.IsTeleporting = true
    local thirdPersonHookName = "TF2EurekaEffectThirdPerson" .. self:EntIndex()

    hook.Add("CalcView", thirdPersonHookName, function(_, pos, angles, fov, znear, zfar)
        if not IsValid(self) or not self.IsTeleporting then return end

        local view = {
            origin = util.TraceLine({
                start = pos,
                endPos = pos - angles:Forward() * 100
            }).HitPos,
            angles = angles,
            fov = fov,
            drawviewer = true,
            znear = znear,
            zfar = zfar
        }

        return view
    end)

    timer.Simple(1.9, function()
        if not IsValid(self) or not IsValid(owner) then return end
        owner:ScreenFade(SCREENFADE.OUT, color_white, 0.25, 0.125)
    end)

    timer.Simple(2, function()
        hook.Remove("CalcView", thirdPersonHookName)
        if not IsValid(self) then return end
        self.IsTeleporting = false
        if not IsValid(owner) then return end
        owner:ScreenFade(SCREENFADE.PURGE, color_white, 0, 0)
        owner:ScreenFade(SCREENFADE.IN, color_white, 0.25, 0.125)

        for _, ent in ents.Iterator() do
            if IsValid(ent) and ent:GetClass() == "info_player_start" then
                owner:SetPos(ent:GetPos())

                return
            end
        end
    end)
end

function SWEP:Reload()
    if not self.HasTeleported then
        self.HasTeleported = true
        self:Teleport()
    end
end

function SWEP:PrimaryAttack()
    if self.IsTeleporting then return end
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
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if ent:IsNPC() or ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
        self:EmitSound("Weapon_Wrench.HitFlesh")

        timer.Simple(0, function()
            if SERVER and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec()) then
                owner:EmitSound("player/engineer/kill" .. math.random(3) .. ".wav")
            end
        end)
    elseif not ent:IsPlayer() then
        self:EmitSound("Weapon_Wrench.HitWorld")
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
            vm:SetSequence(vm:LookupSequence("spk_idle_tap"))
        end

        self.Idle = 1
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        if self.HasTeleported then return end
        draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Press Reload to teleport", "TF2Font", color_black, color_white, TEXT_ALIGN_LEFT)
    end

    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_drg_wrenchmotron/c_drg_wrenchmotron.mdl", RENDERGROUP_VIEWMODEL)
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
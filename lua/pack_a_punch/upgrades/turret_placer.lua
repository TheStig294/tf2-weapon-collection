local UPGRADE = {}
UPGRADE.id = "turret_placer"
UPGRADE.class = "weapon_ttt_tf2_eurekaeffect"
UPGRADE.name = "Turret Placer"
UPGRADE.desc = "Press 'R' to place and build a turret!"
UPGRADE.noSound = true

UPGRADE.convars = {
    {
        name = "pap_turret_placer_range",
        type = "int"
    },
    {
        name = "pap_turret_placer_damage",
        type = "int"
    }
}

local placeRangeCvar = CreateConVar("pap_turret_placer_range", 128, FCVAR_REPLICATED, "Max range of placing turret", 10, 1000)
local damageCvar = CreateConVar("pap_turret_placer_damage", 60, FCVAR_REPLICATED, "Damage the turret deals per bullet", 0, 100)

function UPGRADE:Apply(SWEP)
    SWEP.PlaceRange = placeRangeCvar:GetInt()
    SWEP.DamageAmount = damageCvar:GetInt()
    SWEP.PlaceOffset = 10
    SWEP.TurretModel = "models/buildables/sentry1.mdl"

    if CLIENT then
        timer.Simple(0, function()
            SWEP.v_model:SetPAPCamo()
        end)
    end

    function SWEP:Reload()
        if not self.TTTPAPTurretPlacerSpawned then
            self.TTTPAPTurretPlacerSpawned = true
            self:SpawnTurret()
        end
    end

    function SWEP:SpawnTurret()
        if CLIENT then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local tr = owner:GetEyeTrace()
        if not tr.HitWorld then return end

        if tr.HitPos:Distance(owner:GetPos()) > self.PlaceRange then
            owner:PrintMessage(HUD_PRINTCENTER, "Look at the ground to place the turret")

            return
        end

        local Views = owner:EyeAngles().y
        local turret = ents.Create("ttt_pap_tf2_turret")
        turret:SetOwner(owner)
        turret:SetPos(tr.HitPos + tr.HitNormal)
        turret:SetAngles(Angle(0, Views, 0))
        turret.Damage = self.DamageAmount
        turret:Spawn()
        turret:Activate()
    end

    function SWEP:RemoveHologram()
        if IsValid(self.Hologram) then
            self.Hologram:Remove()
        end
    end

    -- Draw hologram when placing down the turret
    function SWEP:DrawHologram()
        if self.TTTPAPTurretPlacerSpawned then
            self:RemoveHologram()

            return
        end

        if not CLIENT then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local TraceResult = owner:GetEyeTrace()
        local startPos = TraceResult.StartPos
        local endPos = TraceResult.HitPos
        local dist = math.Distance(startPos.x, startPos.y, endPos.x, endPos.y)

        if dist < self.PlaceRange then
            local hologram

            if IsValid(self.Hologram) then
                hologram = self.Hologram
            else
                -- Make the hologram see-through to indicate it isn't placed yet
                hologram = ClientsideModel(self.TurretModel)
                hologram:SetColor(Color(200, 200, 200, 200))
                hologram:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self.Hologram = hologram
            end

            endPos.z = endPos.z + self.PlaceOffset
            local pitch, yaw, roll = owner:EyeAngles():Unpack()
            pitch = 0
            hologram:SetPos(endPos)
            hologram:SetAngles(Angle(pitch, yaw, roll))
            hologram:DrawModel()
        else
            self:RemoveHologram()
        end
    end

    self:AddToHook(SWEP, "Think", function()
        SWEP:DrawHologram()
    end)

    function SWEP:Holster()
        SWEP:RemoveHologram()

        return true
    end

    function SWEP:OwnerChanged()
        SWEP:RemoveHologram()
    end

    function SWEP:OnRemove()
        SWEP:RemoveHologram()
    end
end

TTTPAP:Register(UPGRADE)
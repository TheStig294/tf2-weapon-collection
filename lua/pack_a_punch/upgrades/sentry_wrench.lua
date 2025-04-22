local UPGRADE = {}
UPGRADE.id = "sentry_wrench"
UPGRADE.class = "weapon_ttt_tf2_eurekaeffect"
UPGRADE.name = "Sentry Wrench"
UPGRADE.desc = "Press Right-Click to place and build a sentry!"
UPGRADE.noSound = true

UPGRADE.convars = {
    {
        name = "pap_sentry_wrench_range",
        type = "int"
    },
    {
        name = "pap_sentry_wrench_damage",
        type = "int"
    }
}

local placeRangeCvar = CreateConVar("pap_sentry_wrench_range", 128, FCVAR_REPLICATED, "Max range of placing sentry", 10, 1000)
local damageCvar = CreateConVar("pap_sentry_wrench_damage", 10, FCVAR_REPLICATED, "Damage the sentry deals per bullet", 0, 100)

function UPGRADE:Apply(SWEP)
    SWEP.PlaceRange = placeRangeCvar:GetInt()
    SWEP.DamageAmount = damageCvar:GetInt()
    SWEP.PlaceOffset = 10
    SWEP.SentryModel = "models/buildables/sentry1.mdl"

    function SWEP:SecondaryAttack()
        if not self.TTTPAPSentryWrenchSpawned then
            self.TTTPAPSentryWrenchSpawned = true
            self:SpawnSentry()
        end
    end

    function SWEP:SpawnSentry()
        if CLIENT then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local tr = owner:GetEyeTrace()
        if not tr.HitWorld then return end

        if tr.HitPos:Distance(owner:GetPos()) > self.PlaceRange then
            owner:PrintMessage(HUD_PRINTCENTER, "Look at the ground to place the sentry")

            return
        end

        local Views = owner:EyeAngles().y
        local sentry = ents.Create("ttt_pap_tf2_sentry")
        sentry:SetOwner(owner)
        sentry:SetPos(tr.HitPos + tr.HitNormal)
        sentry:SetAngles(Angle(0, Views, 0))
        sentry.Damage = self.DamageAmount
        sentry:Spawn()
        sentry:Activate()
        owner:EmitSound("player/engineer/sentry_build" .. math.random(2) .. ".wav")
    end

    function SWEP:RemoveHologram()
        if IsValid(self.Hologram) then
            self.Hologram:Remove()
        end
    end

    -- Draw hologram when placing down the sentry
    function SWEP:DrawHologram()
        if self.TTTPAPSentryWrenchSpawned then
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
                hologram = ClientsideModel(self.SentryModel)
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
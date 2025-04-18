local UPGRADE = {}
UPGRADE.id = "mr_sandman"
UPGRADE.class = "weapon_ttt_tf2_sandman"
UPGRADE.name = "Mr. Sandman"
UPGRADE.desc = "Bigger balls... They do everything better!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.Secondary.Damage = 75
    SWEP.Secondary.Delay = SWEP.Secondary.Delay / 2
    SWEP.SlowMultiplier = 0.25
    SWEP.SlowDuration = SWEP.SlowDuration * 2
    local own = SWEP:GetOwner()

    if IsValid(own) then
        own.TTTPAPMrSandman = true
    end

    self:AddToHook"someString"

    if CLIENT then
        self:AddToHook(SWEP, "ViewModelDrawn", function()
            if IsValid(SWEP.v_baseball) and SWEP.v_baseball ~= TTTPAP.camo then
                SWEP.v_baseball:SetPAPCamo()
                SWEP.v_baseball:SetModelScale(2, 0.01)
                SWEP.v_baseball:Activate()
            end
        end)
    end

    self:AddToHook(SWEP, "SecondaryAttack", function()
        if IsValid(SWEP.Baseball) then
            SWEP.Baseball:SetPAPCamo()
            SWEP.Baseball:SetModelScale(2, 0.01)
            SWEP.Baseball:Activate()
            SWEP.Baseball.PAPUpgrade = SWEP.PAPUpgrade
        end
    end)

    self:AddHook("EntityEmitSound", function(snd)
        if not snd.SoundName:StartsWith("player/scout/") then return end
        local ent = snd.Entity
        if not IsValid(ent) then return end

        if self:IsPlayer(ent) then
            local wep = ent:GetWeapon(self.class)

            if self:IsValidUpgrade(wep) then
                snd.Pitch = 50

                return true
            end
        elseif ent:GetModel("models/weapons/w_models/w_baseball.mdl") then
            snd.Pitch = 50

            return true
        end
    end)
end

TTTPAP:Register(UPGRADE)
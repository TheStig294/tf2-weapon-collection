local UPGRADE = {}
UPGRADE.id = "force_a_nature"
UPGRADE.class = "weapon_ttt_tf2_scattergun"
UPGRADE.name = "Force-A-Nature"
UPGRADE.desc = "A double barrel that launches players back!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_forceanature"

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, 2)

    self:AddToHook(SWEP, "DrawWorldModel", function()
        if IsValid(SWEP.w_model) and SWEP.w_model:GetMaterial() ~= TTTPAP.camo then
            SWEP.w_model:SetPAPCamo()
        end
    end)
end

TTTPAP:Register(UPGRADE)
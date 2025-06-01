local UPGRADE = {}
UPGRADE.id = "loose_cannon"
UPGRADE.class = "weapon_ttt_tf2_grenadelauncher"
UPGRADE.name = "Loose Cannon"
UPGRADE.desc = "Hold fire to charge, shoots high-damage cannonballs!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_loosecannon"

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, 1)

    self:AddToHook(SWEP, "ViewModelDrawn", function()
        if IsValid(SWEP.v_model) and SWEP.v_model:GetMaterial() ~= TTTPAP.camo then
            SWEP.v_model:SetPAPCamo()
        end
    end)

    self:AddToHook(SWEP, "DrawWorldModel", function()
        if IsValid(SWEP.w_model) and SWEP.w_model:GetMaterial() ~= TTTPAP.camo then
            SWEP.w_model:SetPAPCamo()
        end
    end)
end

TTTPAP:Register(UPGRADE)
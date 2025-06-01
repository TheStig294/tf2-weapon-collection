local UPGRADE = {}
UPGRADE.id = "sticky_jumper"
UPGRADE.class = "weapon_ttt_tf2_stickybomblauncher"
UPGRADE.name = "Sticky Jumper"
UPGRADE.desc = "No self-damage, more damage and push force, infinite ammo!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_stickyjumper"

function UPGRADE:Apply(SWEP)
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
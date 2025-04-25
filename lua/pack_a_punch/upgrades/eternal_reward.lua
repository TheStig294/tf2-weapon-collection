local UPGRADE = {}
UPGRADE.id = "eternal_reward"
UPGRADE.class = "weapon_ttt_tf2_knife"
UPGRADE.name = "Your Eternal Reward"
UPGRADE.desc = "Doesn't leave bodies\nTake on the appearance of your victims!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_eternalreward"

function UPGRADE:Apply(SWEP)
    self:AddToHook(SWEP, "DrawWorldModel", function()
        if IsValid(SWEP.w_model) and SWEP.w_model:GetMaterial() ~= TTTPAP.camo then
            SWEP.w_model:SetPAPCamo()
        end
    end)
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "shortstop"
UPGRADE.class = "weapon_ttt_tf2_pistol"
UPGRADE.name = "Shortstop"
UPGRADE.desc = "A pistol-shotgun that lets you shove players!\n(Right-click)"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_shortstop"

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, 4)

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
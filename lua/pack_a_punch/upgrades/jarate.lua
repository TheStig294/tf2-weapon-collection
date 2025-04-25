local UPGRADE = {}
UPGRADE.id = "jarate"
UPGRADE.class = "weapon_ttt_tf2_smg"
UPGRADE.name = "Jarate"
UPGRADE.desc = "Throw at players to make them temporarily take more damage!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_jarate"
-- function UPGRADE:Apply(SWEP)
--     self:AddToHook(SWEP, "ViewModelDrawn", function()
--         if IsValid(SWEP.v_model) and SWEP.v_model:GetMaterial() ~= TTTPAP.camo then
--             SWEP.v_model:SetPAPCamo()
--         end
--     end)
--     self:AddToHook(SWEP, "DrawWorldModel", function()
--         if IsValid(SWEP.w_model) and SWEP.w_model:GetMaterial() ~= TTTPAP.camo then
--             SWEP.w_model:SetPAPCamo()
--         end
--     end)
-- end
TTTPAP:Register(UPGRADE)
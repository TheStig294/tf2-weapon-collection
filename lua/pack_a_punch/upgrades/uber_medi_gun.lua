local UPGRADE = {}
UPGRADE.id = "uber_medi_gun"
UPGRADE.class = "weapon_ttt_tf2_medigun"
UPGRADE.name = "Uber Medi Gun"
UPGRADE.desc = "Activate Ubercharge an unlimited number of times!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    self:AddToHook(SWEP, "Think", function()
        if SWEP.UsedUber and SWEP:Clip1() <= 0 then
            SWEP.UsedUber = false
            SWEP:SetClip1(SWEP.Primary.ClipSize)
        end
    end)
end

TTTPAP:Register(UPGRADE)
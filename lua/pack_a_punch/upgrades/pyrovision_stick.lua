local UPGRADE = {}
UPGRADE.id = "pyrovision_stick"
UPGRADE.class = "weapon_ttt_tf2_lollichop"
UPGRADE.name = "Pyrovision Stick"
UPGRADE.desc = "Welcome to Pyroland...\nIncreased damage, range, and swing speed!"
UPGRADE.noSound = true
UPGRADE.damageMult = 1.5
UPGRADE.firerateMult = 2

function UPGRADE:Apply(SWEP)
    SWEP.Primary.Range = SWEP.Primary.Range * 2

    if CLIENT then
        local client = LocalPlayer()
        -- Changes the skybox to the Pyroland one
        local defaultSky = GetConVar("sv_skyname"):GetString()

        local function StartPyrovision()
            RunConsoleCommand("sv_skyname", "pyroland")

            for _, ply in player.Iterator() do
                ply:SetMaterial("models/props_forest/sawmill_wood_pyro")
            end

            timer.Create("TTTPAPPyrovisionStickPlayerMaterial", 1, 0, function()
                for _, ply in player.Iterator() do
                    ply:SetMaterial("models/props_forest/sawmill_wood_pyro")
                end
            end)
        end

        StartPyrovision()
        self:AddToHook(SWEP, "Deploy", StartPyrovision)

        self:AddToHook(SWEP, "Holster", function()
            RunConsoleCommand("sv_skyname", defaultSky)
            timer.Remove("TTTPAPPyrovisionStickPlayerMaterial")

            for _, ply in player.Iterator() do
                ply:SetMaterial("")
            end
        end)

        -- Increases colour saturation even further
        local colourParameters = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1.5,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        self:AddHook("RenderScreenspaceEffects", function()
            if not IsValid(client) or not client.TF2LollichopEffects then return end
            local wep = client:GetActiveWeapon()

            if self:IsValidUpgrade(wep) then
                DrawColorModify(colourParameters)
            end
        end)
    end
end

TTTPAP:Register(UPGRADE)
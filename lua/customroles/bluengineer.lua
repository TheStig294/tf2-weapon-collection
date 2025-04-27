local ROLE = {}
ROLE.nameraw = "bluengineer"
ROLE.name = "BLU Engineer"
ROLE.nameplural = "BLU Engineers"
ROLE.nameext = "a BLU Engineer"
ROLE.nameshort = "ren"
ROLE.desc = [[You are {role}! {comrades}  

Place down a deadly sentry turret by right-clicking with your wrench!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Can place a deadly sentry turret"
ROLE.team = ROLE_TEAM_DETECTIVE

ROLE.shop = {"Change TF2 Class"}

ROLE.loadout = {"weapon_ttt_tf2_eurekaeffect", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_shotgun"}

ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()

    hook.Add("TTTPlayerRoleChanged", "TF2Engineer_ClassChangeReset", function(ply, _, newRole)
        if newRole == ROLE_BLUENGINEER or newRole == ROLE_BLUENGINEER then
            TF2WC:StripAndGiveLoadout(ply, ROLE.loadout)
            local wrench = ply:GetWeapon("weapon_ttt_tf2_eurekaeffect")

            if IsValid(wrench) then
                TF2WC:AddSentryPlacerFunctions(wrench)
            end

            ply:EmitSound("player/engineer/spawn" .. math.random(6) .. ".wav")
        end
    end)
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUEngineer_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUENGINEER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUENGINEER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who can place down a deadly sentry turret! This is instead of choosing items in a buy menu.<br>Right-click while holding out your wrench to place the sentry turret.<br>To change roles again, they can buy the 'Class Changer' item in their buy menu; however, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUENGINEER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
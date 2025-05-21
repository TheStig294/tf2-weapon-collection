local ROLE = {}
ROLE.nameraw = "blumedic"
ROLE.name = "BLU Medic"
ROLE.nameplural = "BLU Medics"
ROLE.nameext = "a BLU Medic"
ROLE.nameshort = "bme"
ROLE.desc = [[You are {role}! {comrades}  
You passively heal, use your medi gun to
heal others and become temporarily invincible!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Passively heals, can heal others"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.startinghealth = 80
ROLE.maxhealth = 80
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the RED Medic's lua file
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUMedic_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUMEDIC then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUMEDIC] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who passively regenerates health, and can heal others using their medi gun! After using up all medi gun ammo, they can right-click their medi gun to temporarily make themselves, and the player they're healing, invincible!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDMEDIC] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."
            return html
        end
    end)
end
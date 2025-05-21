local ROLE = {}
ROLE.nameraw = "redheavy"
ROLE.name = "RED Heavy"
ROLE.nameplural = "RED Heavies"
ROLE.nameext = "a RED Heavy"
ROLE.nameshort = "rhe"
ROLE.desc = [[You are {role}! {comrades}  
You have extra health, but move slower!
Right-click your sandvich to throw and heal someone else!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Extra health, can heal, moves slower"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 200
ROLE.maxhealth = 200
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDHeavy_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDHEAVY then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDHEAVY] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who has extra health, but moves slower! Their sandvich can be eaten to temporarily heal to full health, or right-clicked to throw and heal someone else!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUHEAVY] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
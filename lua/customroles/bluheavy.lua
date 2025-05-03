local ROLE = {}
ROLE.nameraw = "bluheavy"
ROLE.name = "BLU Heavy"
ROLE.nameplural = "BLU Heavies"
ROLE.nameext = "a BLU Heavy"
ROLE.nameshort = "bhe"
ROLE.desc = [[You are {role}!

You have extra health, but move slower!
Right-click your sandvich to throw and heal someone else!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Extra health, can heal, moves slower"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shop = {}
ROLE.loadout = {}
ROLE.startinghealth = 200
ROLE.maxhealth = 200
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the RED Heavy's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUHeavy_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUHEAVY then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUHEAVY] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who has extra health, but moves slower! Their sandvich can be eaten to temporarily heal to full health, or right-clicked to throw and heal someone else!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDHEAVY] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
local ROLE = {}
ROLE.nameraw = "bludemoman"
ROLE.name = "BLU Demoman"
ROLE.nameplural = "BLU Demomen"
ROLE.nameext = "a BLU Demoman"
ROLE.nameshort = "bde"
ROLE.desc = [[You are {role}!
You take no explosion damage, right-click to
explode your stickybombs!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to explosions, fires explosives"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the RED Demo's lua file
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUDemo_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUDEMOMAN then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUDEMOMAN] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who is immune explosions damage, and fires explosives! Right-click to blow up your stickybombs!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDDEMOMAN] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."
            return html
        end
    end)
end
local ROLE = {}
ROLE.nameraw = "bluengineer"
ROLE.name = "BLU Engineer"
ROLE.nameplural = "BLU Engineers"
ROLE.nameext = "a BLU Engineer"
ROLE.nameshort = "ber"
ROLE.desc = [[You are {role}!

Place down a deadly sentry turret by right-clicking with your wrench!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Can place a deadly sentry turret"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shop = {}
ROLE.loadout = {}
ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the BLU Engineer's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUEngineer_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUENGINEER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUENGINEER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who can place down a deadly sentry turret!<br>Right-click while holding out your wrench to place it down.<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDENGINEER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
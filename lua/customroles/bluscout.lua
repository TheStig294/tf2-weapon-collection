local ROLE = {}
ROLE.nameraw = "bluscout"
ROLE.name = "BLU Scout"
ROLE.nameplural = "BLU Scouts"
ROLE.nameext = "a BLU Scout"
ROLE.nameshort = "bsc"
ROLE.desc = [[You are {role}! {comrades}  

You can move faster and jump an extra time!

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
    -- This role's logic is handled in the BLU Scout's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUScout_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUSCOUT then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUSCOUT] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who can move faster and jump!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDSCOUT] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
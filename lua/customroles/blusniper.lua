local ROLE = {}
ROLE.nameraw = "blusniper"
ROLE.name = "BLU Sniper"
ROLE.nameplural = "BLU Snipers"
ROLE.nameext = "a BLU Sniper"
ROLE.nameshort = "bsn"
ROLE.desc = [[You are {role}! {comrades}  

Your sniper rifle always deals max damage!
Take down opponents from afar!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Always deals max damage with their sniper"
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
    -- This role's logic is handled in the RED Sniper's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUSniper_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUSNIPER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUSNIPER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who always has a fully-charged sniper rifle! The sniper rifle normally takes time to charge after shooting, or scoping in, but their deft hands allows them to fire at max damage immediately!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDSNIPER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
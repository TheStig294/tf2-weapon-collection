local ROLE = {}
ROLE.nameraw = "redsniper"
ROLE.name = "RED Sniper"
ROLE.nameplural = "RED Snipers"
ROLE.nameext = "a RED Sniper"
ROLE.nameshort = "rsn"
ROLE.desc = [[You are {role}! {comrades}  
Your sniper rifle always deals max damage!
Take down opponents from afar!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Always deals max damage with their sniper"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    -- The always max damage logic is handled in gamemodes/terrortown/entities/weapons/weapon_ttt_tf2_sniper.lua
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDSniper_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDSNIPER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDSNIPER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who always has a fully-charged sniper rifle! The sniper rifle normally takes time to charge after shooting, or scoping in, but their deft hands allows them to fire at max damage immediately!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUSNIPER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
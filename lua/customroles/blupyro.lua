local ROLE = {}
ROLE.nameraw = "blupyro"
ROLE.name = "BLU Pyro"
ROLE.nameplural = "BLU Pyros"
ROLE.nameext = "a BLU Pyro"
ROLE.nameshort = "bpy"
ROLE.desc = [[You are {role}!
You take no fire damage, use your flamethrower
to quickly take down players at close range!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to fire damage, has a flamethrower"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the RED Pyro's lua file
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUPyro_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUPYRO then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUPYRO] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who is immune to fire damage, and has a deadly flamethrower!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDPYRO] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."
            return html
        end
    end)
end
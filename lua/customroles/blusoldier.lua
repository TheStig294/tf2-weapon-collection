local ROLE = {}
ROLE.nameraw = "blusoldier"
ROLE.name = "BLU Soldier"
ROLE.nameplural = "BLU Soldiers"
ROLE.nameext = "a BLU Soldier"
ROLE.nameshort = "bso"
ROLE.desc = [[You are {role}!
You take no fall damage, use your RPG to rocket-jump
Look at the ground, jump, and shoot!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to fall damage, can rocket-jump"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.startinghealth = 120
ROLE.maxhealth = 120
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the RED Soldier's lua file
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUSoldier_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUSOLDIER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUSOLDIER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who is immune to fall damage, and can rocket-jump! Look at the ground, jump, and shoot a rocket!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDSOLDIER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."
            return html
        end
    end)
end
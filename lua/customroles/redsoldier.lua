local ROLE = {}
ROLE.nameraw = "redsoldier"
ROLE.name = "RED Soldier"
ROLE.nameplural = "RED Soldiers"
ROLE.nameext = "a RED Soldier"
ROLE.nameshort = "rso"
ROLE.desc = [[You are {role}! {comrades}  
You take no fall damage, use your RPG to rocket-jump
Look at the ground, jump, and shoot!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to fall damage, can rocket-jump"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 120
ROLE.maxhealth = 120
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    hook.Add("EntityTakeDamage", "TF2Soldier_FallDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not ent:IsREDSoldier() and not ent:IsBLUSoldier() then return end
        if dmg:IsFallDamage() then return true end
    end)
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDSoldier_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDSOLDIER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDSOLDIER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who is immune to fall damage, and can rocket-jump! Look at the ground, jump, and shoot a rocket!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUSOLDIER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
local ROLE = {}
ROLE.nameraw = "redpyro"
ROLE.name = "RED Pyro"
ROLE.nameplural = "RED Pyros"
ROLE.nameext = "a RED Pyro"
ROLE.nameshort = "rpy"
ROLE.desc = [[You are {role}! {comrades}  
You take no fire damage, use your flamethrower
to quickly take down players at close range!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to fire damage, has a flamethrower"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    local immuneDamageTypes = DMG_BURN + DMG_SLOWBURN + DMG_PLASMA
    hook.Add("EntityTakeDamage", "TF2Pyro_FireDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not ent:IsREDPyro() and not ent:IsBLUPyro() then return end
        if dmg:IsDamageType(immuneDamageTypes) then return true end
    end)
end
if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDPyro_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDPYRO then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDPYRO] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who is immune to fire damage, and has a deadly flamethrower!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUPYRO] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
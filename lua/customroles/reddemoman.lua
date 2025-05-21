local ROLE = {}
ROLE.nameraw = "reddemoman"
ROLE.name = "RED Demoman"
ROLE.nameplural = "RED Demomen"
ROLE.nameext = "a RED Demoman"
ROLE.nameshort = "rde"
ROLE.desc = [[You are {role}! {comrades}  
You take no explosion damage, right-click to
explode your stickybombs!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Immune to explosions, fires explosives"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    hook.Add("EntityTakeDamage", "TF2Demoman_ExplosionDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not ent:IsREDDemoman() and not ent:IsBLUDemoman() then return end
        if dmg:IsExplosionDamage() then return true end
    end)
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDDemo_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDDEMOMAN then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDDEMOMAN] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who is immune explosions damage, and fires explosives! Right-click to blow up your stickybombs!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUDEMOMAN] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
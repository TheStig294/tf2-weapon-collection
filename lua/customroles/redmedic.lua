local ROLE = {}
ROLE.nameraw = "redmedic"
ROLE.name = "RED Medic"
ROLE.nameplural = "RED Medics"
ROLE.nameext = "a RED Medic"
ROLE.nameshort = "rme"
ROLE.desc = [[You are {role}! {comrades}  
You passively heal, use your medi gun to
heal others and become temporarily invincible!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Passively heals, can heal others"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.startinghealth = 80
ROLE.maxhealth = 80
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
end
hook.Add("TTTPlayerRoleChanged", "TF2Medic_ClassChangeReset", function(ply, oldRole, newRole)
    if newRole == ROLE_REDMEDIC or newRole == ROLE_BLUMEDIC then
        timer.Create("TF2MedicPassiveHealthRegen" .. ply:SteamID64(), 1, 0, function()
            if ply:Health() < ply:GetMaxHealth() then
                ply:SetHealth(ply:Health() + 1)
            end
        end)
    elseif oldRole == ROLE_REDMEDIC or oldRole == ROLE_BLUMEDIC then
        timer.Remove("TF2MedicPassiveHealthRegen" .. ply:SteamID64())
    end
end)
if CLIENT then
    hook.Add("TTTTutorialRoleText", "REDMedic_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDMEDIC then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDMEDIC] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who passively regenerates health, and can heal others using their medi gun! After using up all medi gun ammo, they can right-click their medi gun to temporarily make themselves, and the player they're healing, invincible!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUMEDIC] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
local ROLE = {}
ROLE.nameraw = "redspy"
ROLE.name = "RED Spy"
ROLE.nameplural = "RED Spys"
ROLE.nameext = "a RED Spy"
ROLE.nameshort = "rsp"
ROLE.desc = [[You are {role}! {comrades}  
Enable your disguiser with numpad enter.
Activate your invis watch to go invisible.
Backstab with your knife for an instant kill!
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Uses their disguise and invisibility to backstab victims"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.loadout = {"item_disg"}
ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.blockspawnconvars = true
--RegisterRole(ROLE)
if SERVER then
    AddCSLuaFile()
    hook.Add("TTTPlayerRoleChanged", "TF2Spy_GiveDisguiser", function(ply, _, newRole)
        if newRole == ROLE_REDSPY or newRole == ROLE_BLUSPY then
            ply:GiveEquipmentItem(EQUIP_DISGUISE)
        end
    end)
end
if CLIENT then
    hook.Add("TTTPlayerRoleChanged", "TF2Spy_DisguiserPrompt", function(ply, _, newRole)
        if newRole == ROLE_REDSPY or newRole == ROLE_BLUSPY then
            local hookname = "TF2Spy_DisguisePrompt"
            hook.Add("HUDPaint", hookname, function()
                if ply:GetNWBool("disguised") or GetRoundState() ~= ROUND_ACTIVE or ply:GetRole() ~= newRole then
                    hook.Remove("HUDPaint", hookname)
                    return
                end
                draw.WordBox(8, 265, ScrH() - 50, "Press numpad enter to enable disguise", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
            end)
        end
    end)
    hook.Add("TTTTutorialRoleText", "REDSpy_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDSPY then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDSPY] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who starts with a disguiser, invis watch and backstab knife! They press numpad enter to enable their disguise, can activate their invis watch to temporarily go invisible, and hit players in the back with their knife to instantly kill them!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUSPY] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."
            return html
        end
    end)
end
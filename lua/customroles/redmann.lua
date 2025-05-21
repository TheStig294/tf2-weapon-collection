local ROLE = {}
ROLE.nameraw = "redmann"
ROLE.name = "RED Mann"
ROLE.nameplural = "RED Menn"
ROLE.nameext = "a RED Mann"
ROLE.nameshort = "rmn"
ROLE.desc = [[You are {role}! {comrades}  
Instead of buying items, you choose a TF2 class to play as! (Press ',')
Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Chooses a TF2 class' abilities instead of buying equipment"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.shop = {}
ROLE.loadout = {}
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()

    hook.Add("PlayerButtonDown", "TF2Mann_ClassChangeButton", function(ply, button)
        if button ~= KEY_COMMA or (not ply:IsREDMann() and not ply:IsBLUMann()) or ply.TF2ClassChanged then return end
        ply:SetProperty("TF2ClassChanged", true)
        net.Start("TF2ClassChangerScreen")
        net.Send(ply)
    end)

    hook.Add("TTTPlayerRoleChanged", "TF2Mann_ClassChangeReset", function(ply, _, newRole)
        if newRole == ROLE_REDMANN or newRole == ROLE_BLUMANN then
            ply:SetProperty("TF2ClassChanged", false)
            ply.TF2Class = nil
        end
    end)
end

if CLIENT then
    local client

    hook.Add("HUDPaint", "TF2Mann_ClassChangeTextPrompt", function()
        if not client then
            client = LocalPlayer()
        end

        if (not client:IsREDMann() and not client:IsBLUMann()) or client.TF2ClassChanged or not client:Alive() or client:IsSpec() then return end
        draw.WordBox(8, 265, ScrH() - 50, "Press comma [,] to switch class", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end)

    hook.Add("TTTTutorialRoleText", "REDMann_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDMANN then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDMANN] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who chooses a class to play as from Team Fortress 2, and gains their abilities! This is instead of choosing items in a buy menu.<br><br>Press the comma [,] key to bring up the class selection screen.<br><br>To change roles again, they can buy the 'Class Changer' item in their buy menu; however, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUMANN] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."

            return html
        end
    end)
end
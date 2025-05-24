if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_rmn.vmt")
    util.AddNetworkString("TTT2MannSyncClasses")
end

function ROLE:PreInitialize()
    self.color = Color(163, 15, 28, 255)
    self.abbr = "rmn" -- abbreviation
    self.surviveBonus = 0.5 -- bonus multiplier for every survive while another player was killed
    self.scoreKillsMultiplier = 5 -- multiplier for kill of player of another team
    self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
    self.preventFindCredits = false
    self.preventKillCredits = false
    self.preventTraitorAloneCredits = false
    self.preventWin = false
    self.unknownTeam = false
    self.isOmniscientRole = true
    self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
    self.defaultTeam = TEAM_TRAITOR

    self.conVarData = {
        pct = 0.17, -- necessary: percentage of getting this role selected (per player)
        maximum = 1, -- maximum amount of roles in a round
        minPlayers = 4, -- minimum amount of players until this role is able to get selected
        credits = 1, -- the starting credits of a specific role
        togglable = true, -- option to toggle a role for a client if possible (F1 menu)
        random = 50,
        traitorButton = 1, -- can use traitor buttons
        shopFallback = SHOP_DISABLED
    }
end

function ROLE:Initialize()
    roles.SetBaseRole(self, ROLE_TRAITOR)
end

if SERVER then
    local function SendClassesToMann(mann)
        if not TTTC then return end

        for _, ply in player.Iterator() do
            if ply ~= mann then
                net.Start("TTT2MannSyncClasses")
                net.WriteEntity(ply)
                net.WriteUInt(ply:GetCustomClass() or 0, CLASS_BITS)
                net.Send(mann)
            end
        end
    end

    hook.Add("TTTCPostReceiveCustomClasses", "TTT2MannCanSeeClasses", function()
        if not TTTC then return end

        for _, ply in player.Iterator() do
            if ply:IsActive() and (ply:GetSubRole() == ROLE_REDMANN or ply:GetSubRole() == ROLE_BLUMANN) then
                SendClassesToMann(ply)
            end
        end
    end)

    hook.Add("TTT2UpdateSubrole", "TTT2MannCanSeeClasses", function(ply, oldRole, role)
        if not TTTC then return end

        if ply:IsActive() then
            SendClassesToMann(ply)
        end

        if role == ROLE_REDMANN or role == ROLE_BLUMANN then
            ply:SetNW2Bool("TF2ClassChanged", false)
            TF2WC:SetClass(ply, nil)
        elseif oldRole == ROLE_REDMANN or oldRole == ROLE_BLUMANN then
            TF2WC:SetClass(ply, nil)
        end
    end)

    hook.Add("TTTPrepareRound", "TTT2MannReset", function()
        for _, ply in player.Iterator() do
            ply:SetNW2Bool("TF2ClassChanged", false)
            TF2WC:SetClass(ply, nil)
        end
    end)

    hook.Add("PlayerSpawn", "TT2MannReset", function(ply)
        timer.Simple(1, function()
            if ply:IsActive() and (ply:GetSubRole() == ROLE_REDMANN or ply:GetSubRole() == ROLE_BLUMANN) then
                ply:SetNW2Bool("TF2ClassChanged", false)
                TF2WC:SetClass(ply, nil)
            end
        end)
    end)

    hook.Add("PlayerButtonDown", "TF2Mann_ClassChangeButton", function(ply, button)
        if button ~= KEY_COMMA or not (ply:IsActive() and (ply:GetSubRole() == ROLE_REDMANN or ply:GetSubRole() == ROLE_BLUMANN)) or ply:GetNW2Bool("TF2ClassChanged") then return end
        ply:SetNW2Bool("TF2ClassChanged", true)
        net.Start("TF2ClassChangerScreen")
        net.Send(ply)
    end)
end

if CLIENT then
    local client

    hook.Add("HUDPaint", "TF2Mann_ClassChangeTextPrompt", function()
        if not client then
            client = LocalPlayer()
        end

        if not (client:IsActive() and (client:GetSubRole() == ROLE_REDMANN or client:GetSubRole() == ROLE_BLUMANN)) or client:GetNW2Bool("TF2ClassChanged") or not client:Alive() or client:IsSpec() then return end
        draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Press comma [,] to switch class", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end)

    net.Receive("TTT2MannSyncClasses", function()
        local target = net.ReadEntity()
        local class = net.ReadUInt(CLASS_BITS)

        if class == 0 then
            class = nil
        end

        target:SetClass(class)
    end)
end
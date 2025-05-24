if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_bmn.vmt")
end

function ROLE:PreInitialize()
    self.color = Color(50, 10, 183, 255)
    self.abbr = "bmn"
    self.score.killsMultiplier = 8
    self.score.teamKillsMultiplier = -8
    self.score.bodyFoundMultiplier = 3
    self.unknownTeam = true
    self.isPublicRole = true
    self.isPolicingRole = true
    self.defaultTeam = TEAM_INNOCENT
    self.defaultEquipment = SPECIAL_EQUIPMENT

    self.conVarData = {
        pct = 0.13,
        maximum = 1,
        minPlayers = 6,
        minKarma = 600,
        credits = 1,
        creditsAwardDeadEnable = 1,
        creditsAwardKillEnable = 0,
        togglable = true,
        shopFallback = SHOP_DISABLED
    }
end

function ROLE:Initialize()
    roles.SetBaseRole(self, ROLE_DETECTIVE)
end
-- All of this role's logic is handled in the RED Mann's lua file
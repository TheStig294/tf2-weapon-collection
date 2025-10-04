AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Base"
ENT.Model = "models/props/de_tides/restaurant_table.mdl"
ENT.WorldText = NULL
ENT.TeamName = "RED"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

    if SERVER then
        -- An in-built Gmod entity that displays text in a map as a server-side point entity, rather than rendering to the HUD
        self.WorldText = ents.Create("point_worldtext")
        self.WorldText:SetPos(self:GetPos() + Vector(0, 0, 50))
        self.WorldText:SetKeyValue("orientation", "1")
        self.WorldText:SetKeyValue("color", "255 0 0 255")
        self.WorldText:Spawn()
    end

    if CLIENT then
        local selfTable = {self}

        local BLUColour = Color(0, 255, 255)
        local REDColour = Color(255, 0, 0)
        local hookname = "TF2IntelligenceBaseOutline" .. self:EntIndex()

        hook.Add("PreDrawHalos", hookname, function()
            if not IsValid(self) then
                hook.Remove("PreDrawHalos", hookname)

                return
            end

            halo.Add(selfTable, self:GetBLU() and BLUColour or REDColour, 1, 1, 5, true, true)
        end)
    end

    timer.Simple(0, function()
        self:OnIntelligenceAtBase()
    end)
end

function ENT:SetBLU(setBLU)
    self:SetNWBool("IsBLU", setBLU)
    self.TeamName = setBLU and "BLU" or "RED"

    if IsValid(self.WorldText) then
        self.WorldText:SetKeyValue("color", "0 255 255 255")
    end
end

function ENT:GetBLU()
    return self:GetNWBool("IsBLU")
end

function ENT:OnIntelligenceAtBase()
    if SERVER then
        self.WorldText:SetKeyValue("message", self.TeamName .. " Team Base")
    end
end
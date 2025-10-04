AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Base"
ENT.Model = "models/props/de_tides/restaurant_table.mdl"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

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
end

function ENT:SetBLU(setBLU)
    self:SetNWBool("IsBLU", setBLU)
end

function ENT:GetBLU()
    return self:GetNWBool("IsBLU")
end
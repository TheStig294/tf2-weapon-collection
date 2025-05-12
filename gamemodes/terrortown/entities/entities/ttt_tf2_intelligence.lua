AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Briefcase"
ENT.Model = "models/flag/briefcase.mdl"
ENT.SpinDelay = 0.01
ENT.SpinAngles = Angle(0, 1, 0)

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "IsBLU")
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetIsBLU(false)
    self.NextSpin = CurTime()

    if SERVER then
        local hookname = "TF2IntelligenceBypassPVS" .. self:EntIndex()

        hook.Add("SetupPlayerVisibility", hookname, function()
            if not IsValid(self) then
                hook.Remove("SetupPlayerVisibility", hookname)

                return
            end

            AddOriginToPVS(self:GetPos())
        end)
    end

    if CLIENT then
        local haloEnts = {self}

        local BLUColour = Color(0, 255, 255)
        local REDColour = Color(255, 0, 0)
        local hookname = "TF2IntelligenceOutline" .. self:EntIndex()
        local colour

        hook.Add("PreDrawHalos", hookname, function()
            if not IsValid(self) then
                hook.Remove(hookname)

                return
            end

            colour = REDColour

            if self:GetMaterial() == "models/flag/briefcase_blue" then
                colour = BLUColour
            end

            halo.Add(haloEnts, colour, 1, 1, 3, true, true)
        end)
    end
end

function ENT:SetBLU(setBLU)
    self:SetIsBLU(setBLU)

    if setBLU then
        self:SetMaterial("models/flag/briefcase_blue")
    else
        self:SetMaterial("models/flag/briefcase")
    end
end

function ENT:Think()
    if CLIENT and CurTime() > self.NextSpin then
        self.NextSpin = CurTime() + self.SpinDelay
        self:SetAngles(self:GetAngles() + self.SpinAngles)
    end
end
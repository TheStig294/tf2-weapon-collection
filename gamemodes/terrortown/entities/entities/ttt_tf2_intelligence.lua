AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Briefcase"
ENT.Model = "models/flag/briefcase.mdl"
ENT.SpinDelay = 0.01
ENT.SpinAngles = Angle(0, 1, 0)

function ENT:Initialize()
    self:SetModel(self.Model)
    self.NextSpin = CurTime()
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
        self:SetTrigger(true)
        local hookname = "TF2IntelligenceBypassPVS" .. self:EntIndex()

        hook.Add("SetupPlayerVisibility", hookname, function()
            if not IsValid(self) then
                hook.Remove("SetupPlayerVisibility", hookname)

                return
            end

            AddOriginToPVS(self:GetPos())
        end)

        local playerDeathHookname = "TF2IntelligenceDeath" .. self:EntIndex()

        hook.Add("PostPlayerDeath", playerDeathHookname, function(ply)
            ply:SetNWEntity("TF2Intelligence", NULL)
            ply:StopParticles()

            if not IsValid(self) then
                hook.Remove("PostPlayerDeath", playerDeathHookname)

                return
            end

            local heldPlayer = self:GetNWEntity("HeldPlayer")

            if IsValid(heldPlayer) and heldPlayer == ply then
                self:SetNWEntity("HeldPlayer", NULL)
            end
        end)

        hook.Add("TTTPrepareRound", "TF2IntelligenceReset", function()
            for _, ply in player.Iterator() do
                ply:SetNWEntity("TF2Intelligence", NULL)
                ply:StopParticles()
            end

            hook.Remove("TTTPrepareRound", "TF2IntelligenceReset")
        end)
    end

    if CLIENT then
        local BLUColour = Color(0, 255, 255)
        local REDColour = Color(255, 0, 0)
        local hookname = "TF2IntelligenceOutline" .. self:EntIndex()
        local colour

        hook.Add("PreDrawHalos", hookname, function()
            if not IsValid(self) then
                hook.Remove(hookname)

                return
            end

            local haloEnts = {}
            colour = REDColour

            if self:GetNWBool("IsBLU") then
                colour = BLUColour
            end

            local heldPlayer

            for _, ply in player.Iterator() do
                local intelEnt = ply:GetNWEntity("TF2Intelligence")

                if IsValid(intelEnt) and intelEnt == self then
                    heldPlayer = ply
                    break
                end
            end

            if IsValid(heldPlayer) then
                table.insert(haloEnts, heldPlayer)
            else
                table.insert(haloEnts, self)
            end

            halo.Add(haloEnts, colour, 1, 1, 3, true, true)
        end)
    end
end

function ENT:SetBLU(setBLU)
    self:SetNWBool("IsBLU", true)

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

function ENT:StartTouch(ply)
    if IsValid(self:GetNWEntity("HeldPlayer")) then return end
    if not ply:IsPlayer() or not ply:Alive() or ply:IsSpec() then return end
    if ply:GetRole() == ROLE_TRAITOR or (ply.IsTraitorTeam and ply:IsTraitorTeam()) and self:GetNWBool("IsBLU") then return end
    if ply:GetRole() == ROLE_DETECTIVE or (ply.IsDetectiveTeam and ply:IsDetectiveTeam()) and not self:GetNWBool("IsBLU") then return end
    ply:SetNWEntity("TF2Intelligence", self)
    ParticleEffectAttach("player_intel_papertrail", PATTACH_POINT_FOLLOW, ply, 1)
end
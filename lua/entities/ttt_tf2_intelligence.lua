AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Briefcase"
ENT.Model = "models/flag/briefcase.mdl"
ENT.SpinDelay = 0.01
ENT.SpinAngles = Angle(0, 1, 0)
ENT.DroppedOldIntel = NULL
ENT.BlockCapture = false

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
            local oldIntel = ply:GetNWEntity("TF2Intelligence")

            if IsValid(oldIntel) then
                local droppedIntel = ents.Create("ttt_tf2_intelligence")
                droppedIntel.DroppedOldIntel = oldIntel
                droppedIntel:SetPos(ply:GetPos())
                droppedIntel:Spawn()

                if oldIntel:GetBLU() then
                    droppedIntel:SetBLU(true)
                    SetGlobalEntity("TF2IntelligenceDroppedBLU", droppedIntel)
                else
                    droppedIntel:SetBLU(false)
                    SetGlobalEntity("TF2IntelligenceDroppedRED", droppedIntel)
                end

                for _, p in player.Iterator() do
                    if (droppedIntel:GetBLU() and droppedIntel:IsPlayerTraitor(p)) or (not droppedIntel:GetBLU() and droppedIntel:IsPlayerInnocent(p)) then
                        p:SendLua("surface.PlaySound(\"misc/intel_teamdropped.wav\")")
                    elseif (droppedIntel:GetBLU() and droppedIntel:IsPlayerInnocent(p)) or (not droppedIntel:GetBLU() and droppedIntel:IsPlayerTraitor(p)) then
                        p:SendLua("surface.PlaySound(\"misc/intel_enemydropped.wav\")")
                    end
                end
            end

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
                hook.Remove("PreDrawHalos", hookname)

                return
            end

            local haloEnts = {self}

            colour = REDColour
            local isBLU = self:GetNWBool("IsBLU")

            if isBLU then
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

            local droppedBLUIntel = GetGlobalEntity("TF2IntelligenceDroppedBLU")
            local droppedREDIntel = GetGlobalEntity("TF2IntelligenceDroppedRED")

            if IsValid(droppedREDIntel) then
                table.insert(haloEnts, droppedREDIntel)
            end

            if IsValid(droppedBLUIntel) then
                table.insert(haloEnts, droppedBLUIntel)
            end

            if IsValid(heldPlayer) then
                table.insert(haloEnts, heldPlayer)
            end

            halo.Add(haloEnts, colour, 1, 1, 3, true, true)
        end)
    end
end

function ENT:SetBLU(setBLU)
    self:SetNWBool("IsBLU", setBLU)

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

function ENT:GetBLU()
    return self:GetNWBool("IsBLU")
end

function ENT:IsPlayerInnocent(ply)
    return TF2WC:IsInnocentTeam(ply)
end

function ENT:IsPlayerTraitor(ply)
    return TF2WC:IsTraitorTeam(ply)
end

function ENT:CanPickupEnemyIntel(ply)
    if self.BlockCapture then return false end
    local droppedIntel = self:GetBLU() and GetGlobalEntity("TF2IntelligenceDroppedBLU") or GetGlobalEntity("TF2IntelligenceDroppedRED")
    local BLUCapturePlayer, REDCapturePlayer

    for _, p in player.Iterator() do
        if not IsValid(p:GetNWEntity("TF2Intelligence")) then continue end

        if self:IsPlayerTraitor(p) then
            REDCapturePlayer = p
        elseif self:IsPlayerInnocent(p) then
            BLUCapturePlayer = p
        end
    end

    if IsValid(droppedIntel) and self ~= droppedIntel then
        return false
    else
        return (self:IsPlayerTraitor(ply) and self:GetBLU() and not IsValid(REDCapturePlayer)) or (self:IsPlayerInnocent(ply) and not self:GetBLU() and not IsValid(BLUCapturePlayer))
    end
end

function ENT:StartTouch(ply)
    local intelEnt = ply:GetNWEntity("TF2Intelligence")
    if IsValid(intelEnt) and intelEnt == self then return end
    if not ply:IsPlayer() or not ply:Alive() or ply:IsSpec() then return end

    if IsValid(self.DroppedOldIntel) and ((self:IsPlayerTraitor(ply) and not self:GetBLU()) or (self:IsPlayerInnocent(ply) and self:GetBLU())) then
        -- Returning friendly intel
        local intelTeamName = self:GetBLU() and "BLU" or "RED"
        local msg = ply:Nick() .. " has returned the " .. intelTeamName .. " intelligence!"
        PrintMessage(HUD_PRINTCENTER, msg)
        PrintMessage(HUD_PRINTTALK, msg)

        for _, p in player.Iterator() do
            if (self:GetBLU() and self:IsPlayerInnocent(p)) or (not self:GetBLU() and self:IsPlayerTraitor(p)) then
                p:SendLua("surface.PlaySound(\"misc/intel_enemyreturned.wav\")")
            elseif (self:GetBLU() and not self:IsPlayerInnocent(p)) or (not self:GetBLU() and not self:IsPlayerTraitor(p)) then
                p:SendLua("surface.PlaySound(\"misc/intel_teamreturned.wav\")")
            end
        end

        self:Remove()
    elseif IsValid(intelEnt) and ((intelEnt:GetBLU() and not self:GetBLU()) or (not intelEnt:GetBLU() and self:GetBLU())) then
        -- Returning enemy intel
        ply:SetNWEntity("TF2Intelligence", NULL)
        ply:StopParticles()
        hook.Run("TF2IntelligenceCaptured", ply, self:GetBLU())
    elseif self:CanPickupEnemyIntel(ply) then
        -- Picking up the enemy intel
        ParticleEffectAttach("player_intel_papertrail", PATTACH_POINT_FOLLOW, ply, 1)
        ply:PrintMessage(HUD_PRINTCENTER, "You picked up the enemy intelligence!")
        ply:PrintMessage(HUD_PRINTTALK, "You picked up the enemy intelligence!")

        for _, p in player.Iterator() do
            if (self:GetBLU() and self:IsPlayerInnocent(p)) or (not self:GetBLU() and self:IsPlayerTraitor(p)) then
                p:SendLua("surface.PlaySound(\"misc/intel_enemystolen.wav\")")
            elseif (self:GetBLU() and not self:IsPlayerInnocent(p)) or (not self:GetBLU() and not self:IsPlayerTraitor(p)) then
                p:SendLua("surface.PlaySound(\"misc/intel_teamstolen.wav\")")
            end
        end

        if IsValid(self.DroppedOldIntel) then
            ply:SetNWEntity("TF2Intelligence", self.DroppedOldIntel)
            self:Remove()
        else
            ply:SetNWEntity("TF2Intelligence", self)
        end
    end
end
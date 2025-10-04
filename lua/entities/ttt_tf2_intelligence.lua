AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Intelligence Briefcase"
ENT.NextSpin = 0
ENT.Model = "models/flag/briefcase.mdl"
ENT.SpinDelay = 0.01
ENT.SpinAngles = Angle(0, 1, 0)
ENT.DroppedOldIntel = NULL
ENT.BlockCapture = false
ENT.BaseEnt = NULL
ENT.BasePosOffset = Vector(0, 0, 40)
ENT.NextNearPlayerCheck = 0
ENT.NearPlayerCheckDelay = 0.1
ENT.NearPlayerCheckDistance = 100
ENT.NearPlayerCheckDistanceSquared = ENT.NearPlayerCheckDistance * ENT.NearPlayerCheckDistance

if SERVER then
    concommand.Add("ttt_tf2_intel_test", function(ply, cmd, args, argStr)
        local intelEnt = ents.Create("ttt_tf2_intelligence")
        intelEnt:SetPos(ply:GetPos() + Vector(600, 600, 0))
        intelEnt:Spawn()
        intelEnt:SetBLU(true)
    end)
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self.NextSpin = CurTime()
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

    if SERVER then
        util.AddNetworkString("TF2RandomatIntelStatusChanged")
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

                net.Start("TF2RandomatIntelStatusChanged")
                net.WriteBool(droppedIntel:GetBLU())
                net.WriteString("DROPPED, go find it!")
                net.Broadcast()
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

        if not IsValid(self.DroppedOldIntel) then
            self.BaseEnt = ents.Create("ttt_tf2_intelligence_base")
            self.BaseEnt:SetPos(self:GetPos())
            self.BaseEnt:Spawn()
            self:SetPos(self:GetPos() + self.BasePosOffset)
        end
    end

    if CLIENT then
        local BLUColour = Color(0, 255, 255)
        local REDColour = Color(255, 0, 0)
        local client = LocalPlayer()
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

            local droppedBLUIntel = GetGlobalEntity("TF2IntelligenceDroppedBLU")
            local droppedREDIntel = GetGlobalEntity("TF2IntelligenceDroppedRED")

            if IsValid(droppedBLUIntel) then
                table.insert(haloEnts, droppedBLUIntel)
            end

            if IsValid(droppedREDIntel) then
                table.insert(haloEnts, droppedREDIntel)
            end

            halo.Add(haloEnts, colour, 1, 1, 3, true, true)
            local intelHaloEnts = {}

            -- Highlight all enemy team members with the intelligence through walls!
            for _, ply in player.Iterator() do
                if client:GetNWString("TF2RandomatTeam", "") ~= ply:GetNWString("TF2RandomatTeam", "") and IsValid(ply:GetNWEntity("TF2Intelligence")) then
                    table.insert(intelHaloEnts, ply)
                end
            end

            halo.Add(intelHaloEnts, COLOR_WHITE, 1, 1, 3, true, true)
        end)
    end
end

function ENT:SetBLU(setBLU)
    self:SetNWBool("IsBLU", setBLU)

    if IsValid(self.BaseEnt) then
        self.BaseEnt:SetBLU(setBLU)
    end

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

    if SERVER and CurTime() > self.NextNearPlayerCheck then
        self.NextNearPlayerCheck = CurTime() + self.NearPlayerCheckDelay

        for _, ply in player.Iterator() do
            if not ply:Alive() or ply:IsSpec() then continue end

            if ply:GetPos():DistToSqr(self:GetPos()) < self.NearPlayerCheckDistanceSquared then
                self:OnNearAlivePlayer(ply)
            end
        end
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

function ENT:OnNearAlivePlayer(ply)
    local intelEnt = ply:GetNWEntity("TF2Intelligence")
    if IsValid(intelEnt) and intelEnt == self then return end

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

        self.DroppedOldIntel:SetNoDraw(false)

        if IsValid(self.DroppedOldIntel.BaseEnt) then
            self.DroppedOldIntel.BaseEnt:OnIntelligenceReturned()
        end

        net.Start("TF2RandomatIntelStatusChanged")
        net.WriteBool(self:GetBLU())
        net.WriteString("AT BASE")
        net.Broadcast()
        self:Remove()
    elseif IsValid(intelEnt) and ((intelEnt:GetBLU() and not self:GetBLU()) or (not intelEnt:GetBLU() and self:GetBLU())) then
        -- Returning enemy intel
        local str = ply:Nick() .. " has captured the enemy intelligence for the"

        if self:GetBLU() then
            str = str .. " BLU team!"
        else
            str = str .. " RED team!"
        end

        PrintMessage(HUD_PRINTCENTER, str)
        PrintMessage(HUD_PRINTTALK, str)
        ply:SetNWEntity("TF2Intelligence", NULL)
        ply:StopParticles()
        intelEnt:SetNoDraw(false)

        if IsValid(intelEnt.BaseEnt) then
            intelEnt.BaseEnt:OnIntelligenceReturned()
        end

        net.Start("TF2RandomatIntelStatusChanged")
        net.WriteBool(intelEnt:GetBLU())
        net.WriteString("CAPTURED")
        net.Broadcast()
        hook.Run("TF2IntelligenceCaptured", self:GetBLU())
    elseif self:CanPickupEnemyIntel(ply) then
        -- Picking up the enemy intel
        ParticleEffectAttach("player_intel_papertrail", PATTACH_POINT_FOLLOW, ply, 5)
        ply:PrintMessage(HUD_PRINTCENTER, "Picked up the intelligence, bring it back to your base!")
        ply:PrintMessage(HUD_PRINTTALK, "Picked up the intelligence, bring it back to your base!")

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

        self:SetNoDraw(true)

        if IsValid(self.BaseEnt) then
            self.BaseEnt:OnIntelligenceStolen()
        end

        net.Start("TF2RandomatIntelStatusChanged")
        net.WriteBool(self:GetBLU())
        net.WriteString("STOLEN BY " .. ply:Nick() .. "!")
        net.Broadcast()
    end
end
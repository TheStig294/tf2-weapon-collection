if SERVER then
    AddCSLuaFile()

    hook.Add("TF2ClassChanged", "TF2Scout_ClassChangeReset", function(ply, class, oldClass)
        if class.name == "scout" then
            ply:SetMaxJumpLevel(ply:GetMaxJumpLevel() + 1)
        end

        if oldClass and oldClass.name == "scout" then
            ply:SetMaxJumpLevel(ply:GetMaxJumpLevel() - 1)
        end
    end)
end

-- 
-- Adding multi-jumping, stolen from Mal: https://steamcommunity.com/sharedfiles/filedetails/?id=2501234496 for the Scout's double-jump
-- 
local plymeta = FindMetaTable("Player")

-- Don't add all the double-jump logic if a double jump mod is already installed!
if not plymeta.GetJumpLevel then
    function plymeta:GetJumpLevel()
        return self:GetDTInt(23)
    end

    function plymeta:SetJumpLevel(level)
        self:SetDTInt(23, level)
    end

    function plymeta:GetMaxJumpLevel()
        return self:GetDTInt(24)
    end

    function plymeta:SetMaxJumpLevel(level)
        self:SetDTInt(24, level)
    end

    function plymeta:GetExtraJumpPower()
        return self:GetDTFloat(25)
    end

    function plymeta:SetExtraJumpPower(power)
        self:SetDTFloat(25, power)
    end

    function plymeta:GetJumped()
        return self:GetDTInt(26)
    end

    function plymeta:SetJumped(jumped)
        self:SetDTInt(26, jumped)
    end

    function plymeta:GetMaxJumpDistance()
        return self:GetDTInt(27)
    end

    function plymeta:SetMaxJumpDistance(max_distance)
        self:SetDTInt(27, max_distance)
    end

    function plymeta:GetJumpLocation()
        return self:GetDTVector(28)
    end

    function plymeta:SetJumpLocation(loc)
        self:SetDTVector(28, loc)
    end

    function plymeta:ResetJumpState()
        if self:GetJumpLevel() ~= 0 then
            self:SetJumpLevel(0)
            self:SetJumpLocation(vector_origin)

            -- Only set the 'jumped' flag if that functionality is enabled
            if self:GetJumped() ~= -1 then
                self:SetJumped(0)
            end
        end
    end

    if SERVER then
        util.AddNetworkString("TTT_MultiJump")

        hook.Add("OnEntityCreated", "MultiJumpOnEntityCreated", function(ply)
            if ply:IsPlayer() then
                ply:SetJumpLevel(0)
                ply:SetJumped(-1)
                ply:SetMaxJumpLevel(0)
                ply:SetExtraJumpPower(1)
                ply:SetMaxJumpDistance(0)
                ply:SetJumpLocation(vector_origin)
            end
        end)

        -- Integrate with [VManip] Vaulting - https://steamcommunity.com/sharedfiles/filedetails/?id=2364206712
        -- Reset the jump level when a player finishes vaulting to allow players to jump after a vault
        if plymeta.SetMantle then
            local oldSetMantle = plymeta.SetMantle

            function plymeta:SetMantle(mantle)
                oldSetMantle(self, mantle)

                if mantle == 0 then
                    -- Delay this slightly so we don't auto-jump immediately after the vault finishes
                    timer.Simple(0.25, function()
                        if IsValid(self) then
                            self:ResetJumpState()
                        end
                    end)
                end
            end
        end

        -- Integrate with Mantle + Wallrun - https://steamcommunity.com/sharedfiles/filedetails/?id=2027577882
        -- Reset the jump level when a player mantles or wallruns
        hook.Add("PlayerPostThink", "MultiJumpPlayerPostThink", function(ply)
            if ply.InMantle then
                -- Delay this slightly so we don't auto-jump immediately after the mantle finishes
                timer.Simple(0.25, function()
                    if IsValid(ply) and ply.InMantle then
                        ply:ResetJumpState()
                    end
                end)
            end

            if ply.InVWallrun or ply.InHWallrun then
                ply:ResetJumpState()
            end
        end)
    end

    local math = math
    local net = net
    local MathAbs = math.abs
    local MathClamp = math.Clamp
    local MathRandom = math.random

    local function GetMoveVector(mv)
        local max_speed = mv:GetMaxSpeed()
        local forward = MathClamp(mv:GetForwardSpeed(), -max_speed, max_speed)
        local side = MathClamp(mv:GetSideSpeed(), -max_speed, max_speed)
        local abs_xy_move = MathAbs(forward) + MathAbs(side)
        if abs_xy_move == 0 then return mv:GetVelocity() end
        local mul = max_speed / abs_xy_move
        local ang = mv:GetAngles()
        local vec = Vector()
        vec:Add(ang:Forward() * forward)
        vec:Add(ang:Right() * side)
        vec:Mul(mul)
        -- Keep whichever is the greater movement velocity
        -- This allows the player to use movement methods without direct forward input
        -- while also maintaining the ability to change direction mid-air using inputs
        local vel = mv:GetVelocity()

        if MathAbs(vec.x) > MathAbs(vel.x) then
            vel.x = vec.x
        end

        if MathAbs(vec.y) > MathAbs(vel.y) then
            vel.y = vec.y
        end

        return vel
    end

    local function IsPlayerValid(ply)
        if not IsValid(ply) or not ply:Alive() then return false end
        if ply.IsSpec and ply:IsSpec() then return false end

        return true
    end

    hook.Add("SetupMove", "MultiJumpSetupMove", function(ply, mv)
        -- Only run this for Valid, Alive, Non-Spectators
        if not IsPlayerValid(ply) then return end
        -- Let the engine handle movement from the ground
        -- Only set the 'jumped' flag if that functionality is enabled
        local on_ground = ply:OnGround()
        local jumping = mv:KeyPressed(IN_JUMP)

        if on_ground and jumping and ply:GetJumped() ~= -1 then
            ply:SetJumped(1)

            return
        elseif on_ground then
            ply:ResetJumpState()

            return
        end

        -- If the prone mod is installed and the player is prone, they can't jump
        if type(ply.IsProne) == "function" and ply:IsProne() then return end
        -- If the vaulting mod is installed and the player is vaulting, they can't jump
        if type(ply.GetMantle) == "function" and ply:GetMantle() ~= 0 then return end
        -- If the mantling mod is installed and the player is mantling, they can't jump
        if ply.InMantle then return end
        -- Ignore if the player is on a ladder
        if ply:GetMoveType() == MOVETYPE_LADDER then return end
        -- If we have a limited jump distance, keep track of the player's location
        local max_distance = ply:GetMaxJumpDistance()

        if max_distance > 0 then
            local jump_loc = ply:GetJumpLocation()

            if jump_loc == vector_origin then
                jump_loc = ply:GetPos()
                ply:SetJumpLocation(jump_loc)
            else
                local new_height = ply:GetPos().z
                local distance = MathAbs(jump_loc.z - new_height)
                if distance > max_distance then return end
            end
        end

        -- Don't do anything if not jumping
        if not jumping then return end
        local jump_level = ply:GetJumpLevel() + 1
        ply:SetJumpLevel(jump_level)
        if not on_ground and ply:GetJumped() == 0 then return end
        if jump_level > ply:GetMaxJumpLevel() then return end
        local vel = GetMoveVector(mv)
        vel.z = ply:GetJumpPower() * ply:GetExtraJumpPower()
        mv:SetVelocity(vel)
        ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP, -1)

        if SERVER then
            net.Start("TTT_MultiJump")
            net.WriteEntity(ply)
            net.Broadcast()
        end
    end)

    if CLIENT then
        net.Receive("TTT_MultiJump", function()
            local ply = net.ReadEntity()
            if not IsPlayerValid(ply) then return end
            local ply_pos = ply:GetPos()
            local pos = ply_pos + Vector(0, 0, 10)
            local client = LocalPlayer()
            if client:GetPos():Distance(pos) > 1000 then return end
            local emitter = ParticleEmitter(pos)

            for _ = 0, MathRandom(40, 50) do
                local partpos = ply_pos + Vector(MathRandom(-10, 10), MathRandom(-10, 10), 10)
                local part = emitter:Add("particle/particle_smokegrenade", partpos)

                if part then
                    part:SetDieTime(MathRandom(0.4, 0.7))
                    part:SetStartAlpha(MathRandom(200, 240))
                    part:SetEndAlpha(0)
                    part:SetColor(MathRandom(200, 220), MathRandom(200, 220), MathRandom(200, 220))
                    part:SetStartSize(MathRandom(6, 8))
                    part:SetEndSize(0)
                    part:SetRoll(0)
                    part:SetRollDelta(0)
                    local velocity = VectorRand() * MathRandom(10, 15)
                    velocity.z = 5
                    part:SetVelocity(velocity)
                end
            end

            emitter:Finish()
        end)
    end
end
-- 
-- End of Mal's multi-jump mod
-- 
local ROLE = {}
ROLE.nameraw = "redengineer"
ROLE.name = "RED Engineer"
ROLE.nameplural = "RED Engineers"
ROLE.nameext = "a RED Engineer"
ROLE.nameshort = "rer"
ROLE.desc = [[You are {role}! {comrades}  

Place down a deadly sentry turret by right-clicking with your wrench!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Can place a deadly sentry turret"
ROLE.team = ROLE_TEAM_TRAITOR
ROLE.shop = {}

local loadoutWeps = {"weapon_ttt_tf2_eurekaeffect", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_shotgun"}

ROLE.loadout = loadoutWeps
ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("TF2EngineerSetClientSentryWrench")

    hook.Add("TTTPlayerRoleChanged", "TF2Engineer_ClassChangeReset", function(ply, _, newRole)
        if newRole == ROLE_REDENGINEER or newRole == ROLE_BLUENGINEER then
            TF2WC:StripAndGiveLoadout(ply, loadoutWeps)
            SetRoleHealth(ply)
            ply:EmitSound("player/engineer/spawn" .. math.random(6) .. ".wav")

            timer.Simple(1, function()
                local wrench = ply:GetWeapon("weapon_ttt_tf2_eurekaeffect")

                if IsValid(wrench) then
                    TF2WC:AddSentryPlacerFunctions(wrench)
                    net.Start("TF2EngineerSetClientSentryWrench")
                    net.WriteEntity(wrench)
                    net.Send(ply)
                end
            end)
        end
    end)
end

TF2WC = TF2WC or {}

function TF2WC:AddSentryPlacerFunctions(SWEP)
    SWEP.PlaceRange = 128
    SWEP.DamageAmount = 10
    SWEP.PlaceOffset = 10
    SWEP.SentryModel = "models/buildables/sentry1.mdl"
    SWEP.TTTPAPSentryWrenchSpawned = false

    function SWEP:SecondaryAttack()
        if not self.TTTPAPSentryWrenchSpawned then
            self:SpawnSentry()
        end
    end

    function SWEP:SpawnSentry()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local tr = owner:GetEyeTrace()
        if not tr.HitWorld then return end

        if tr.HitPos:Distance(owner:GetPos()) > self.PlaceRange then
            owner:PrintMessage(HUD_PRINTCENTER, "Look at the ground to place the sentry")

            return
        end

        self.TTTPAPSentryWrenchSpawned = true
        if CLIENT then return end
        local Views = owner:EyeAngles().y
        local sentry = ents.Create("ttt_tf2_sentry")
        sentry:SetOwner(owner)
        sentry:SetPos(tr.HitPos + tr.HitNormal)
        sentry:SetAngles(Angle(0, Views, 0))
        sentry.Damage = self.DamageAmount
        sentry:Spawn()
        sentry:Activate()
        owner:EmitSound("player/engineer/sentry_build" .. math.random(2) .. ".wav")
    end

    function SWEP:RemoveHologram()
        if IsValid(self.Hologram) then
            self.Hologram:Remove()
        end
    end

    -- Draw hologram when placing down the sentry
    function SWEP:DrawHologram()
        if self.TTTPAPSentryWrenchSpawned then
            self:RemoveHologram()

            return
        end

        if not CLIENT then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local TraceResult = owner:GetEyeTrace()
        local startPos = TraceResult.StartPos
        local endPos = TraceResult.HitPos
        local dist = math.Distance(startPos.x, startPos.y, endPos.x, endPos.y)

        if dist < self.PlaceRange then
            local hologram

            if IsValid(self.Hologram) then
                hologram = self.Hologram
            else
                -- Make the hologram see-through to indicate it isn't placed yet
                hologram = ClientsideModel(self.SentryModel)
                hologram:SetColor(Color(200, 200, 200, 200))
                hologram:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self.Hologram = hologram
            end

            endPos.z = endPos.z + self.PlaceOffset
            local pitch, yaw, roll = owner:EyeAngles():Unpack()
            pitch = 0
            hologram:SetPos(endPos)
            hologram:SetAngles(Angle(pitch, yaw, roll))
            hologram:DrawModel()
        else
            self:RemoveHologram()
        end
    end

    SWEP.PAPOldThink = SWEP.Think

    function SWEP:Think()
        self:DrawHologram()

        return self:PAPOldThink()
    end

    function SWEP:Holster()
        self:RemoveHologram()

        return true
    end

    function SWEP:OwnerChanged()
        self:RemoveHologram()
    end

    function SWEP:OnRemove()
        self:RemoveHologram()
    end

    if CLIENT then
        function SWEP:DrawHUD()
            if self.TTTPAPSentryWrenchSpawned then return end
            draw.WordBox(8, 265, ScrH() - 50, "Right-click to place sentry", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
        end
    end
end

if CLIENT then
    net.Receive("TF2EngineerSetClientSentryWrench", function()
        local wrench = net.ReadEntity()
        TF2WC:AddSentryPlacerFunctions(wrench)
    end)

    hook.Add("TTTTutorialRoleText", "REDEngineer_TTTTutorialRoleText", function(role, _)
        if role == ROLE_REDENGINEER then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local html = "The " .. ROLE_STRINGS[ROLE_REDENGINEER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who can place down a deadly sentry turret! This is instead of choosing items in a buy menu.<br>Right-click while holding out your wrench to place the sentry turret.<br>To change roles again, they can buy the 'Class Changer' item in their buy menu; however, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUENGINEER] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>detective</span> role."

            return html
        end
    end)
end
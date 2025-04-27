local ROLE = {}
ROLE.nameraw = "blumann"
ROLE.name = "BLU Mann"
ROLE.nameplural = "BLU Menn"
ROLE.nameext = "a BLU Mann"
ROLE.nameshort = "bmn"
ROLE.desc = [[You are {role}!

Instead of buying items, you choose a TF2 class to play as! (Press ',')

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Chooses a TF2 class' abilities instead of buying equipment"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shop = {}
ROLE.loadout = {}
ROLE.startingcredits = 1
ROLE.startinghealth = 100
ROLE.maxhealth = 100
ROLE.isactive = nil
ROLE.selectionpredicate = nil
ROLE.shouldactlikejester = nil
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
    -- All of this role's logic is handled in the RED Mann's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUMann_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUMANN then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local traitorColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUMANN] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who chooses a class to play as from Team Fortress 2, and gains their abilities! This is instead of choosing items in a buy menu.<br>Press the comma [,] key to bring up the class selection screen.<br>To change roles again, they can buy the 'Class Changer' item in their buy menu; however, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> equivalent to the " .. ROLE_STRINGS[ROLE_BLUMANN] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. traitorColor.r .. ", " .. traitorColor.g .. ", " .. traitorColor.b .. ")'>detective</span> role."

            return html
        end
    end)
end
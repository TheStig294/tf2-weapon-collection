local ROLE = {}
ROLE.nameraw = "bluspy"
ROLE.name = "BLU Spy"
ROLE.nameplural = "BLU Spys"
ROLE.nameext = "a BLU Spy"
ROLE.nameshort = "bsp"
ROLE.desc = [[You are {role}! {comrades}  

Enable your disguiser with numpad enter.
Activate your invis watch to go invisible.
Backstab with your knife for an instant kill!

Press {menukey} to receive your special equipment]]
ROLE.shortdesc = "Uses their disguise and invisibility to backstab victims"
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shop = {}

ROLE.loadout = {"item_disg"}

ROLE.startinghealth = 66
ROLE.maxhealth = 66
ROLE.translations = {}
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
    -- This role's logic is handled in the BLU Spy's lua file
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "BLUSpy_TTTTutorialRoleText", function(role, _)
        if role == ROLE_BLUSPY then
            local roleColor = GetRoleTeamColor(ROLE_TEAM_DETECTIVE)
            local counterpartColour = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
            local html = "The " .. ROLE_STRINGS[ROLE_BLUSPY] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> role who starts with a disguiser, invis watch and backstab knife! They press numpad enter to enable their disguise, can activate their invis watch to temporarily go invisible, and hit players in the back with their knife to instantly kill them!<br><br>To change to a different TF2 class, they can buy the 'Class Changer' item in their buy menu, which grants a full heal! However, <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>this costs a credit!</span><br><br>This role is the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>detective</span> equivalent to the " .. ROLE_STRINGS[ROLE_REDSPY] .. ", which works exactly the same, except it is a <span style='color: rgb(" .. counterpartColour.r .. ", " .. counterpartColour.g .. ", " .. counterpartColour.b .. ")'>traitor</span> role."

            return html
        end
    end)
end
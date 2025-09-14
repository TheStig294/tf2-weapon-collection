CreateConVar("tf2_weapon_collection_auto_reload", 1, FCVAR_REPLICATED, "Whether weapons from the TF2 Weapon Collection should auto-reload", 0, 1)
local detectiveCvar = CreateConVar("tf2_weapon_collection_detective_buyable", "knife,medigun,rpg,stickybomblauncher", FCVAR_ARCHIVE + FCVAR_REPLICATED, "TF2 weapons a detective can buy (Requires map change to take effect)")
local detectiveWeapons = string.Explode(",", detectiveCvar:GetString())
local traitorCvar = CreateConVar("tf2_weapon_collection_traitor_buyable", "knife,inviswatch,rpg,stickybomblauncher", FCVAR_ARCHIVE + FCVAR_REPLICATED, "TF2 weapons a traitor can buy (Requires map change to take effect)")
local traitorWeapons = string.Explode(",", traitorCvar:GetString())
local floorCvar = CreateConVar("tf2_weapon_collection_spawns_on_floor", "bonesaw,caber,escapeplan,eurekaeffect,flamethrower,goldenfryingpan,grenadelauncher,lollichop,machete,minigun,pistol,revolver,sandman,sandvich,scattergun,shotgun,smg,sniper,syringegun", FCVAR_ARCHIVE + FCVAR_REPLICATED, "TF2 weapons that spawn on the ground (Requires map change to take effect)")
local floorWeapons = string.Explode(",", floorCvar:GetString())

local function ToDictionary(tab)
    local dictionary = {}

    for _, value in ipairs(tab) do
        dictionary["weapon_ttt_tf2_" .. value] = true
    end

    return dictionary
end

local isDetective = ToDictionary(detectiveWeapons)
local isTraitor = ToDictionary(traitorWeapons)
local isFloor = ToDictionary(floorWeapons)

hook.Add("PreRegisterSWEP", "TF2WeaponCollectionCommonConvars", function(SWEP, class)
    if not class:StartsWith("weapon_ttt_tf2_") then return end
    SWEP.CanBuy = {}

    if isDetective[class] then
        table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
        SWEP.Kind = WEAPON_EQUIP
        SWEP.Slot = 6
    end

    if isTraitor[class] then
        table.insert(SWEP.CanBuy, ROLE_TRAITOR)
        SWEP.Kind = WEAPON_EQUIP
        SWEP.Slot = 6
    end

    SWEP.AutoSpawnable = tobool(isFloor[class])
end)
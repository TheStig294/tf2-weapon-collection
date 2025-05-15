local EVENT = {}
EVENT.Title = ""
-- EVENT.Title = "It's time to..."
EVENT.AltTitle = "Meet The Randomat!"
EVENT.id = "tf2"

EVENT.Categories = {"gamemode", "rolechange", "largeimpact"}

function EVENT:Begin()
    local REDSpawn, BLUSpawn
    local playerSpawns = ents.FindByClass("info_player_start")

    if #playerSpawns >= 1 then
        REDSpawn = playerSpawns[math.random(#playerSpawns)]:GetPos()
    end

    local weaponSpawns = {}

    for _, ent in ents.Iterator() do
        if ent.AutoSpawnable then
            table.insert(weaponSpawns, ent:GetPos())
        end
    end

    if not REDSpawn then
        REDSpawn = weaponSpawns[math.random(#weaponSpawns)]
    end

    local maxDist = 0

    for _, pos in ipairs(weaponSpawns) do
        local dist = pos:DistToSqr(REDSpawn)

        if dist > maxDist then
            maxDist = dist
            BLUSpawn = pos
        end
    end

    local REDIntel = ents.Create("ttt_tf2_intelligence")
    REDIntel:SetPos(REDSpawn)
    REDIntel:Spawn()
    local BLUIntel = ents.Create("ttt_tf2_intelligence")
    BLUIntel:SetPos(BLUSpawn)
    BLUIntel:Spawn()
    BLUIntel:SetBLU(true)
end

Randomat:register(EVENT)
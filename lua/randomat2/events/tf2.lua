local EVENT = {}
EVENT.Title = ""
-- EVENT.Title = "It's time to..."
EVENT.AltTitle = "Meet The Randomat!"
EVENT.id = "tf2"

EVENT.Categories = {"gamemode", "rolechange", "largeimpact"}

function EVENT:Begin()
    local pos = Entity(2):GetPos()
    local intel = ents.Create("ttt_tf2_intelligence")
    intel:SetPos(pos)
    intel:Spawn()
    intel:SetBLU(true)
end

Randomat:register(EVENT)
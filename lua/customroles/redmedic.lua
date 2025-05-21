if SERVER then
    AddCSLuaFile()
end

hook.Add("TF2ClassChanged", "TF2Medic_ClassChangeReset", function(ply, class, oldClass)
    if class.name == "medic" then
        timer.Create("TF2MedicPassiveHealthRegen" .. ply:SteamID64(), 1, 0, function()
            if ply:Health() < ply:GetMaxHealth() then
                ply:SetHealth(ply:Health() + 1)
            end
        end)
    elseif oldClass and oldClass.name == "medic" then
        timer.Remove("TF2MedicPassiveHealthRegen" .. ply:SteamID64())
    end
end)
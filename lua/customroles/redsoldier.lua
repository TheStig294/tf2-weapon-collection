if SERVER then
    AddCSLuaFile()

    hook.Add("EntityTakeDamage", "TF2Soldier_FallDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not TF2WC:IsClass(ent, "soldier") then return end
        if dmg:IsFallDamage() then return true end
    end)
end
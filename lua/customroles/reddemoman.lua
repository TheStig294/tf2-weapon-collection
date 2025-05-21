if SERVER then
    AddCSLuaFile()

    hook.Add("EntityTakeDamage", "TF2Demoman_ExplosionDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not TF2WC:IsClass(ent, "demoman") then return end
        if dmg:IsExplosionDamage() then return true end
    end)
end
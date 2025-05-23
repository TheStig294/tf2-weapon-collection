if SERVER then
    local immuneDamageTypes = DMG_BURN + DMG_SLOWBURN + DMG_PLASMA

    hook.Add("EntityTakeDamage", "TF2Pyro_FireDamageImmunity", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not TF2WC:IsClass(ent, "pyro") then return end
        if dmg:IsDamageType(immuneDamageTypes) then return true end
    end)
end
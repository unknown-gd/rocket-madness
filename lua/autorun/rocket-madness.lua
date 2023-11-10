local addonName = "Rocket Madness"
local timer_Simple = timer.Simple
local table_remove = table.remove
local math_max = math.max
local ipairs = ipairs
local SERVER = SERVER

hook.Add( "OnEntityCreated", addonName, function( entity )
    if entity:GetClass() ~= "rpg_missile" then return end

    timer_Simple( 0, function()
        if not entity:IsValid() then return end

        local ply = entity:GetOwner()
        if not ply or not ply:IsValid() then return end
        if not ply:IsPlayer() then return end
        if not ply:Alive() then return end

        if SERVER then
            local weapon = ply:GetWeapon( "weapon_rpg" )
            if not weapon or not weapon:IsValid() then return end

            local clip1 = math_max( weapon:Clip1(), ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ) )
            if clip1 <= 0 then return end

            ply:StripWeapon( "weapon_rpg" )
            weapon:Remove()

            weapon = ply:Give( "weapon_rpg", true )
            weapon:SetDeploySpeed( 16 )
            weapon:SetClip1( clip1 )

            ply:SelectWeapon( "weapon_rpg" )
            return
        end

        local history = GAMEMODE.PickupHistory
        if not istable( history ) then return end

        for index, item in ipairs( history ) do
            if item.name ~= "#HL2_RPG" then continue end
            table_remove( history, index )
            break
        end
    end )
end )

if SERVER then
    hook.Add( "PlayerAmmoChanged", addonName, function( ply, ammoID, old, new )
        local weapon = ply:GetActiveWeapon()
        if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_rpg" and weapon:GetPrimaryAmmoType() == ammoID then
            weapon:SetClip1( new )
        end
    end )

    hook.Add( "WeaponEquip", addonName, function( weapon, ply )
        if weapon:GetClass() ~= "weapon_rpg" then return end
        weapon:SetClip1( ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ) )
    end )
end
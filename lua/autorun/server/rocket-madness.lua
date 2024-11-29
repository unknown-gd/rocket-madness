local physenv_GetGravity = physenv.GetGravity
local timer_Simple = timer.Simple

local flags = bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY )
local offset = Vector( 0, 0, 3 )

local mp_rpg_reload_time = CreateConVar( "mp_rpg_reload_time", "0.25", flags, "Time to launch the next RPG rocket.", 0, 300 )
local mp_rpg_missile_original_collisions = CreateConVar( "mp_rpg_missile_original_collisions", "0", flags, "Use the original collision group, which means the missiles will collide with each other!", 0, 1 )

hook.Add( "OnEntityCreated", "Rocket Madness", function( entity )
	local className = entity:GetClass()
	if className == "item_rpg_round" then
		if math.random( 1, 10 ) ~= 2 then return end

		timer_Simple( math.Rand( 0, 3 ), function()
			if not entity:IsValid() then return end

			local rocket = ents.Create("rpg_missile")
			rocket:SetPos( entity:LocalToWorld( offset ) )
			rocket:SetAngles( entity:GetAngles() + Angle( math.random( -30, -180 ), math.random( -180, 180 ), math.random( -30, -180 ) ) )
			rocket:Spawn()
			rocket:SetVelocity( physenv_GetGravity() * -0.5 )
			entity:Remove()
		end )
	elseif className == "rpg_missile" then
		timer_Simple( 0, function()
			if not entity:IsValid() then return end

			---@class Player
			local owner = entity:GetOwner()
			if not ( owner:IsValid() and owner:IsPlayer() and owner:Alive() ) then return end

			if not mp_rpg_missile_original_collisions:GetBool() then
				entity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
			end

			local weapon = owner:GetWeapon( "weapon_rpg" )
			if not ( weapon and weapon:IsValid() ) then return end

			local clip1 = math.max( weapon:Clip1(), owner:GetAmmoCount( weapon:GetPrimaryAmmoType() ) )
			if clip1 < 2 then return end -- we need at least 1 missile to control working

			owner:StripWeapon( "weapon_rpg" ) -- remove wont work here

			weapon = owner:Give( "weapon_rpg", true )
			if not ( weapon and weapon:IsValid() ) then return end

			weapon:SetNextPrimaryFire( CurTime() + mp_rpg_reload_time:GetFloat() )
			weapon:SetDeploySpeed( 16 )
			weapon:SetClip1( clip1 )

			owner:SetActiveWeapon( weapon ) -- not sure
			-- owner:SelectWeapon( "weapon_rpg" )
		end )
	end
end )

hook.Add( "PlayerAmmoChanged", "Rocket Madness", function( ply, ammoID, _, amount )
	local weapon = ply:GetActiveWeapon() ---@cast weapon Weapon
	if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_rpg" and weapon:GetPrimaryAmmoType() == ammoID then
		weapon:SetClip1( amount ) -- clip sync
	end
end )

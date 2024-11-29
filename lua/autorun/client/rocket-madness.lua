local table_remove = table.remove
local timer_Simple = timer.Simple
local LocalPlayer = LocalPlayer

hook.Add( "OnEntityCreated", "Rocket Madness", function( entity )
	if entity:GetClass() ~= "rpg_missile" then return end

	timer_Simple( 0, function()
		if not ( entity:IsValid() and entity:GetOwner() == LocalPlayer() ) then return end

		local history = GAMEMODE.PickupHistory
		if not istable( history ) then return end

		for index = table.maxn( history ), 1, -1 do
			local data = history[ index ]
			if data and data.name == "#HL2_RPG" then
				table_remove( history, index )
			end
		end
	end )
end, PRE_HOOK )

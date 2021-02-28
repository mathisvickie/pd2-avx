
local MessageInGame=function(Text)
	if managers.hud then managers.hud:show_hint({text=Text}) end
end

local SpawnVehicle=function(VehiclePath)
	if not Utils:IsInCustody() then
		World:spawn_unit(Idstring(VehiclePath),managers.player:player_unit():position(),Rotation(managers.player:player_unit():camera():rotation():yaw(),0.0,0.0))
		managers.player:warp_to(managers.player:player_unit():position()+Vector3(0.0,0.0,200.0),managers.player:player_unit():camera():rotation())
	end
end

local DeactivateUnitBrain=function()
	for u_key, u_data in pairs( managers.enemy:all_enemies() ) do
		u_data.unit:brain():set_active( false )
	end
	for u_key, u_data in pairs( managers.enemy:all_civilians() ) do
		u_data.unit:brain():set_active( false )
	end
end

local DeleteBorders=function()
	local net_session = managers.network:session()

	if(net_session) then
		local send_to_peers = net_session.send_to_peers

		local CollisionData = {
			["673ea142d68175df"] = true,
			["86efb80bf784046f"] = true,
			["b37a4188fde4c161"] = true,
			["7ae8fcbfe6a00f7b"] = true,
			["c5c4442c5e147cb0"] = true,
			["8f3cb89b79b42ec4"] = true,
			["e8fe662bb4d262d3"] = true,
			["9d8b22836aa015ed"] = true,
			["63be2c801283f573"] = true,
			["78f4407343b48f6d"] = true,
			["29d0139549a54de7"] = true,
			["e379cc9592197cd8"] = true,
			["7a4c85917d8d8323"] = true,
			["9eda9e73ac0ef710"] = true,
			["276de19dc5541f30"] = true,
			["6cdb4f6f58ec4fa8"] = true
		}
		for _,unit in pairs(World:find_units_quick("all", 1)) do
			if CollisionData[unit:name():key()] then
				send_to_peers(net_session, 'remove_unit', unit)
				unit:set_slot(0)
			end
		end  
	end

end

local StartHelicopterMOD=function(TempHelicopterUnitName)
	if managers.player:player_unit() and not Utils:IsInCustody() and not HelicopterMOD then
		
		HelicopterUnitName=TempHelicopterUnitName
		HelicopterUnit=World.spawn_unit(World,Idstring(HelicopterUnitName),managers.player:player_unit():position(),Rotation(managers.player:player_unit():camera():rotation():yaw(),0.0,0.0))

		PlayerStandard._can_stand=function(self)
			return true
		end

		IsInHelicopter=true
		EnterPressed=false
		MoveSpeed=0.0
		AngleZ=0.0
		HelicopterMOD=true
	end
end

if LuaNetworking:IsHost() then
	local Options={}

	local Vehicles={
		"Falcogini","units/pd2_dlc_cage/vehicles/fps_vehicle_falcogini_1/fps_vehicle_falcogini_1",
		"Longfellow","units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_muscle_1/fps_vehicle_muscle_1",
		"Forklift","units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_forklift_1/fps_vehicle_forklift_1",
		"Boxtruck","units/pd2_dlc_jolly/vehicles/fps_vehicle_box_truck_1/fps_vehicle_box_truck_1",
		"Rib Boat","units/pd2_dlc_jerry/vehicles/fps_vehicle_boat_rib_1/fps_vehicle_boat_rib_1",
		"Rusts Bike","units/pd2_dlc_born/vehicles/fps_vehicle_bike_1/fps_vehicle_bike_1",
		"Bike","units/pd2_dlc_born/vehicles/fps_vehicle_bike_2/fps_vehicle_bike_2",
		"[BETA] Helicopter","units/payday2/vehicles/air_vehicle_blackhawk/vehicle_blackhawk"
	}

	local Index
	for Index=1,#Vehicles,2 do
		if Index+1==#Vehicles then
			table.insert(Options,{text=Vehicles[Index],callback=StartHelicopterMOD,data=Vehicles[Index+1]})
		else
			table.insert(Options,{text=Vehicles[Index],callback=SpawnVehicle,data=Vehicles[Index+1]})
		end
	end
	table.insert(Options,{text="[DEBUG] Deactivate unit brain",callback=DeactivateUnitBrain})
	table.insert(Options,{text="[DEBUG] Delete invisible borders",callback=DeleteBorders})
	table.insert(Options,{})
	table.insert(Options,{text="Cancel",is_cancel_button=true})

	QuickMenu:new("Advanced Vehicle Extension","Select vehicle to spawn:",Options):Show()
else
	MessageInGame("Vehicles can be spawned only by a host.")
end

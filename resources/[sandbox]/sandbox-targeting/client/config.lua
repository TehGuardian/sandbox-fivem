Config = {
	DefaultIcons = {
		ped = "person-walking",
		player = "person",
		entity = "eye",
	},
	VehicleIcons = {
		[0] = "car",
		[1] = "car",
		[2] = "car",
		[3] = "car",
		[4] = "car",
		[5] = "car",
		[6] = "car",
		[7] = "car",
		[8] = "motorcycle",
		[9] = "truck-monster",
		[10] = "truck-pickup",
		[11] = "car",
		[12] = "car",
		[13] = "bicycle",
		[14] = "ship",
		[15] = "helicopter",
		[16] = "plane",
		[17] = "taxi-bus",
		[18] = "car",
		[19] = "car",
		[20] = "truck",
		[21] = "train",
	},
	BlaclistedCornering = {
		[8] = true,
		[13] = true,
		[14] = true,
		[15] = true,
		[16] = true,
		[18] = true,
		[19] = true,
		[21] = true,
	},
}

Config.VehicleMenu = {
	{
		icon = "gas-pump",
		isEnabled = function(data, entityData)
			if Vehicles ~= nil and Vehicles.Fuel:CanBeFueled(entityData.entity) then
				return true
			end
			return false
		end,
		textFunc = function(data, entityData)
			if Vehicles ~= nil then
				local fuelData = Vehicles.Fuel:CanBeFueled(entityData.entity)
				if fuelData then
					if fuelData.needsFuel then
						return string.format("Refuel For $%d", fuelData.cost)
					else
						return "Fuel Tank Full"
					end
				end
			end
			return ""
		end,
		event = "Vehicles:Client:StartFueling",
		data = {},
		minDist = 2.0,
	},
	{
		icon = "credit-card",
		isEnabled = function(data, entityData)
			if Vehicles ~= nil then
				local fuelData = Vehicles.Fuel:CanBeFueled(entityData.entity)
				if fuelData and fuelData.needsFuel then
					return true
				end
			end
			return false
		end,
		textFunc = function(data, entityData)
			if Vehicles ~= nil then
				local fuelData = Vehicles.Fuel:CanBeFueled(entityData.entity)
				if fuelData then
					if fuelData.needsFuel then
						return string.format("Refuel For $%d (Pay by Card)", fuelData.cost)
					else
						return "Fuel Tank Full"
					end
				end
			end
			return ""
		end,
		event = "Vehicles:Client:StartFueling",
		data = {
			bank = true,
		},
		minDist = 2.0,
	},
	{
		icon = "gas-pump",
		isEnabled = function(data, entityData)
			local hasWeapon, weapon = GetCurrentPedWeapon(LocalPlayer.state.ped)
			if
				Vehicles ~= nil
				and hasWeapon
				and weapon == `WEAPON_PETROLCAN`
				and GetVehicleClass(entityData.entity) ~= 13
			then
				return true
			end
			return false
		end,
		text = "Refuel With Petrol Can",
		event = "Vehicles:Client:StartJerryFueling",
		data = {},
		minDist = 2.0,
	},
	{
		icon = "garage-open",
		isEnabled = function(data, entityData)
			if Vehicles ~= nil and Vehicles:CanBeStored(entityData.entity) then
				return true
			end
			return false
		end,
		text = "Store Vehicle",
		event = "Vehicles:Client:StoreVehicle",
		data = {},
		minDist = 4.0,
	},
	{
		icon = "truck-ramp-box",
		isEnabled = function(data, entityData)
			local vehState = Entity(entityData.entity).state
			return not LocalPlayer.state.isDead
				and vehState.VIN ~= nil
				and not vehState.wasThermited
				and GetEntityHealth(entityData.entity) > 0
				and isNearTrunk(entityData.entity, 4.0)
		end,
		text = "View Trunk",
		event = "Inventory:Client:Trunk",
		data = {},
		minDist = 3.0,
	},
	{
		icon = "key",
		text = "Give Keys",
		isEnabled = function(data, entityData)
			local vehEnt = Entity(entityData.entity)
			return Vehicles ~= nil and Vehicles.Keys:Has(vehEnt.state.VIN, vehEnt.state.GroupKeys)
		end,
		event = "Vehicles:Client:GiveKeys",
		data = {},
		minDist = 3.0,
	},
	{
		icon = "person-seat",
		isEnabled = function(data, entityData)
			local vehState = Entity(entityData.entity).state
			return not LocalPlayer.state.isDead
				and vehState.VIN ~= nil
				and not vehState.wasThermited
				and GetEntityHealth(entityData.entity) > 0
				and isNearTrunk(entityData.entity, 4.0)
				and LocalPlayer.state.isK9Ped
		end,
		text = "K9 - Get In Vehicle",
		event = "Vehicles:Client:K9GetInNearestSeat",
		data = {},
		minDist = 3.0,
	},
	{
		icon = "trash",
		text = "Toss Garbage",
		event = "Garbage:Client:TossBag",
		model = `trash2`,
		tempjob = "Garbage",
		data = {},
		minDist = 10.0,
		isEnabled = function(data, entityData)
			return LocalPlayer.state.carryingGarbabge and LocalPlayer.state.inGarbagbeZone and isNearTrunk(entityData.entity, 4.0, true)
		end,
	},
	{
		icon = "capsules",
		text = "Handoff Contraband",
		event = "OxyRun:Client:MakeSale",
		item = "contraband",
		data = {},
		minDist = 3.0,
		isEnabled = function(data, entityData)
			return LocalPlayer.state.oxyJoiner ~= nil
				and LocalPlayer.state.oxyBuyer ~= nil
				and VehToNet(entityData.entity) == LocalPlayer.state.oxyBuyer.veh
		end,
	},
	{
		icon = "lock",
		isEnabled = function(data, entityData)
			local vehState = Entity(entityData.entity).state
			if
				vehState
				and vehState.VIN
				and not vehState.wasThermited
				and Vehicles ~= nil
				and Vehicles.Keys:Has(vehState.VIN)
			then
				return true
			end
			return false
		end,
		text = "Toggle Locks",
		event = "Vehicles:Client:ToggleLocks",
		data = {},
		minDist = 25.0,
	},
	{
		icon = "fas fa-bicycle",
		isEnabled = function(data, entityData)
			return GetVehicleClass(entityData.entity) == 13
		end,
		text = "Pick Up Bike",
		event = "Vehicle:Client:PickupBike",
		data = {},
		minDist = 3.0,
	},
	{
		icon = "truck-tow",
		text = "Request Tow",
		event = "Vehicles:Client:RequestTow",
		data = {},
		minDist = 2.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
		},
		isEnabled = function(data, entityData)
			local vehState = Entity(entityData.entity).state
			if vehState and vehState.towObjective or (GlobalState["Duty:tow"] or 0) == 0 then
				return false
			end
			return true
		end,
	},
	{
		icon = "truck-tow",
		text = "Request Impound",
		event = "Vehicles:Client:RequestImpound",
		data = {},
		minDist = 2.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
		},
		isEnabled = function(data, entityData)
			local vehState = Entity(entityData.entity).state
			if vehState and vehState.towObjective then
				return false
			end
			return true
		end,
	},
	{
		icon = "truck-tow",
		text = "Tow - Impound",
		event = "Tow:Client:RequestImpound",
		data = {},
		minDist = 4.0,
		jobPerms = {
			{
				job = "tow",
				reqDuty = true,
			},
		},
		isEnabled = function(data, entityData)
			if entityData.entity and DoesEntityExist(entityData.entity) then
				if Polyzone:IsCoordsInZone(GetEntityCoords(entityData.entity), "tow_impound_zone") then
					return true
				end
			end
			return false
		end,
	},

	{
		icon = "print-magnifying-glass",
		isEnabled = function(data, entityData)
			return Vehicles:HasAccess(entityData.entity)
				and Vehicles.Utils:IsCloseToFrontOfVehicle(entityData.entity)
				and (GetVehicleDoorAngleRatio(entityData.entity, 4) >= 0.1)
		end,
		text = "Inspect VIN",
		event = "Vehicles:Client:InspectVIN",
		data = {},
		minDist = 10.0,
	},
	{
		icon = "screwdriver",
		isEnabled = function(data, entityData)
			if DoesEntityExist(entityData.entity) then
				local vehState = Entity(entityData.entity).state
				if vehState.FakePlate then
					return (
						(Vehicles:HasAccess(entityData.entity, true))
						or LocalPlayer.state.onDuty == "police" and LocalPlayer.state.inPdStation
					)
						and (
							Vehicles.Utils:IsCloseToRearOfVehicle(entityData.entity)
							or Vehicles.Utils:IsCloseToFrontOfVehicle(entityData.entity)
						)
				end
			end
			return false
		end,
		text = "Remove Plate",
		event = "Vehicles:Client:RemoveFakePlate",
		data = {},
		minDist = 10.0,
	},
	{
		icon = "screwdriver",
		isEnabled = function(data, entityData)
			if DoesEntityExist(entityData.entity) then
				local vehState = Entity(entityData.entity).state
				if vehState.Harness and vehState.Harness > 0 then
					return Vehicles:HasAccess(entityData.entity, true)
				end
			end
			return false
		end,
		text = "Remove Harness",
		event = "Vehicles:Client:RemoveHarness",
		data = {},
		minDist = 10.0,
	},
	{
		icon = "person-seat",
		text = "Seat In Vehicle",
		event = "Escort:Client:PutIn",
		data = {},
		minDist = 4.0,
		isEnabled = function(data, entity)
			if
				LocalPlayer.state.isEscorting == nil
				or LocalPlayer.state.isDead
				or GetVehicleDoorLockStatus(entity.entity) ~= 1
			then
				return false
			else
				local vehmodel = GetEntityModel(entity.entity)
				for i = -1, GetVehicleModelNumberOfSeats(vehmodel) do
					if GetPedInVehicleSeat(entity.entity, i) == 0 then
						return true
					end
				end
				return false
			end
		end,
	},
	{
		icon = "person-seat",
		text = "Unseat From Vehicle",
		event = "Escort:Client:PullOut",
		data = {},
		minDist = 4.0,
		isEnabled = function(data, entity)
			if
				LocalPlayer.state.isEscorting ~= nil
				or LocalPlayer.state.isDead
				or GetVehicleDoorLockStatus(entity.entity) ~= 1
			then
				return false
			else
				local vehmodel = GetEntityModel(entity.entity)
				for i = -1, GetVehicleModelNumberOfSeats(vehmodel) do
					local p = GetPedInVehicleSeat(entity.entity, i)
					if p ~= 0 and IsPedAPlayer(p) then
						return true
					end
				end
				return false
			end
		end,
	},
	{
		icon = "child",
		text = "Put In Trunk",
		event = "Trunk:Client:PutIn",
		data = {},
		minDist = 4.0,
		isEnabled = function(data, entity)
			return LocalPlayer.state.isEscorting ~= nil
				and not LocalPlayer.state.isDead
				and not LocalPlayer.state.inTrunk
				and isNearTrunk(entity.entity, 4.0, true)
		end,
	},
	{
		icon = "child",
		text = "Pull Out Of Trunk",
		event = "Trunk:Client:PullOut",
		data = {},
		minDist = 4.0,
		isEnabled = function(data, entity)
			local entState = Entity(entity.entity).state
			return LocalPlayer.state.isEscorting == nil
				and not LocalPlayer.state.isDead
				and not LocalPlayer.state.inTrunk
				and isNearTrunk(entity.entity, 4.0, false)
				and entState.trunkOccupied
		end,
	},
	{
		icon = "child",
		text = "Get In Trunk",
		event = "Trunk:Client:GetIn",
		data = {},
		minDist = 4.0,
		jobs = false,
		isEnabled = function(data, entityData)
			local entState = Entity(entityData.entity).state
			return LocalPlayer.state.isEscorting == nil
				and not LocalPlayer.state.isDead
				and not LocalPlayer.state.inTrunk
				and entState.trunkOccupied == nil
				and isNearTrunk(entityData.entity, 4.0, true)
		end,
	},
	-- Mechanic
	{
		icon = "toolbox",
		text = "Regular Body & Engine Repair",
		event = "Mechanic:Client:StartRegularRepair",
		data = {},
		isEnabled = function(data, entityData)
			if
				DoesEntityExist(entityData.entity)
				and (Vehicles.Utils:IsCloseToRearOfVehicle(entityData.entity) or Vehicles.Utils:IsCloseToFrontOfVehicle(
					entityData.entity
				))
				and Mechanic:CanAccessVehicleAsMechanic(entityData.entity)
			then
				local engineHealth = GetVehicleEngineHealth(entityData.entity)
				local bodyHealth = GetVehicleBodyHealth(entityData.entity)
				if bodyHealth < 1000 or engineHealth < 900 then
					return true
				end
			end
			return false
		end,
		minDist = 10.0,
	},
	{
		icon = "car-wrench",
		text = "Run Diagnostics",
		event = "Mechanic:Client:RunDiagnostics",
		data = {},
		isEnabled = function(data, entityData)
			if
				DoesEntityExist(entityData.entity)
				and (Vehicles.Utils:IsCloseToRearOfVehicle(entityData.entity) or Vehicles.Utils:IsCloseToFrontOfVehicle(
					entityData.entity
				))
				and Mechanic:CanAccessVehicleAsMechanic(entityData.entity)
			then
				return true
			end
			return false
		end,
		minDist = 10.0,
	},
	{
		icon = "gauge-simple-max",
		text = "Run Performance Diagnostics",
		event = "Mechanic:Client:RunPerformanceDiagnostics",
		data = {},
		isEnabled = function(data, entityData)
			if
				DoesEntityExist(entityData.entity)
				and (Vehicles.Utils:IsCloseToRearOfVehicle(entityData.entity) or Vehicles.Utils:IsCloseToFrontOfVehicle(
					entityData.entity
				))
				and Mechanic:CanAccessVehicleAsMechanic(entityData.entity)
			then
				return true
			end
			return false
		end,
		minDist = 10.0,
	},
	{
		icon = "car-tilt",
		isEnabled = function(data, entityData)
			if DoesEntityExist(entityData.entity) and (not IsVehicleOnAllWheels(entityData.entity)) then
				return true
			end
			return false
		end,
		text = "Flip Vehicle",
		event = "Vehicles:Client:FlipVehicle",
		data = {},
		minDist = 2.0,
		jobs = false,
	},
	{
		icon = "truck-tow",
		isEnabled = function(data, entityData)
			local veh = entityData.entity
			local vehEnt = Entity(veh)
			if DoesEntityExist(veh) and Tow:IsTowTruck(veh) and not vehEnt.state.towingVehicle then
				local rearWheel = GetEntityBoneIndexByName(veh, "wheel_lr")
				local rearWheelCoords = GetWorldPositionOfEntityBone(veh, rearWheel)
				if #(rearWheelCoords - LocalPlayer.state.myPos) <= 3.0 then
					return true
				end
			end
			return false
		end,
		text = "Tow - Attach Vehicle",
		event = "Vehicles:Client:BeginTow",
		data = {},
		minDist = 2.0,
		jobs = false,
	},
	{
		icon = "truck-tow",
		isEnabled = function(data, entityData)
			local veh = entityData.entity
			local vehEnt = Entity(veh)
			if DoesEntityExist(veh) and Tow:IsTowTruck(veh) and vehEnt.state.towingVehicle then
				local rearWheel = GetEntityBoneIndexByName(veh, "wheel_lr")
				local rearWheelCoords = GetWorldPositionOfEntityBone(veh, rearWheel)
				if #(rearWheelCoords - LocalPlayer.state.myPos) <= 3.0 then
					return true
				end
			end
			return false
		end,
		text = "Tow - Detach Vehicle",
		event = "Vehicles:Client:ReleaseTow",
		data = {},
		minDist = 2.0,
		jobs = false,
	},
	{
		icon = "rectangle-barcode",
		text = "Run Plate",
		event = "Police:Client:RunPlate",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
		},
	},
	{
		icon = "anchor",
		isEnabled = function(data, entityData)
			if not LocalPlayer.state.isDead and Entity(entityData.entity).state.VIN ~= nil then
				local vehModel = GetEntityModel(entityData.entity)
				if
					IsThisModelABoat(vehModel)
					or IsThisModelAJetski(vehModel)
					or IsThisModelAnAmphibiousCar(vehModel)
					or IsThisModelAnAmphibiousQuadbike(vehModel)
				then
					return true
				end
			end
		end,
		text = "Toggle Anchor",
		event = "Vehicles:Client:AnchorBoat",
		data = {},
		minDist = 5.0,
	},
	{
		icon = "car-wrench",
		isEnabled = function(data, entity)
			local entState = Entity(entity.entity).state
			return not LocalPlayer.state.isDead
				and LocalPlayer.state.inChopZone ~= nil
				and LocalPlayer.state.chopping == nil
				and not entState.Owned
		end,
		text = "Start Chopping",
		event = "Laptop:Client:LSUnderground:Chopping:StartChop",
		data = {},
		minDist = 10.0,
	},
	{
		icon = "clothes-hanger",
		isEnabled = function(data, entity)
			local entState = Entity(entity.entity).state
			local rvModels = { [`cararv`] = true, [`guardianrv`] = true, [`sandroamer`] = true, [`sandkingrv`] = true }
			return not LocalPlayer.state.isDead
				and rvModels[GetEntityModel(entity.entity)]
				and Vehicles:HasAccess(entity.entity)
		end,
		text = "Open Wardrobe",
		event = "Wardrobe:Client:ShowBitch",
		data = {},
		minDist = 2.0,
	},
	{
		icon = "clothes-hanger",
		isEnabled = function(data, entity)
			return not LocalPlayer.state.cornering
				and not Entity(entity.entity).state.cornering
				and not Config.BlaclistedCornering[GetVehicleClass(entity.entity)]
		end,
		tempjob = "CornerDealing",
		text = "Start Corner Dealing",
		event = "CornerDealing:Client:StartCornering",
		data = {},
		minDist = 2.0,
	},
	{
		icon = "clothes-hanger",
		isEnabled = function(data, entity)
			return LocalPlayer.state.cornering and Entity(entity.entity).state.cornering
		end,
		tempjob = "CornerDealing",
		text = "Stop Corner Dealing",
		event = "CornerDealing:Client:StopCornering",
		data = {},
		minDist = 2.0,
	},
	{
		icon = "hand",
		text = "Grab Loot",
		event = "Robbery:Client:MoneyTruck:GrabLoot",
		model = `stockade`,
		data = {},
		minDist = 10.0,
		isEnabled = function(data, entity)
			local entState = Entity(entity.entity).state
			return not entState.beingLooted
				and entState.wasThermited
				and not entState.wasLooted
				and GetEntityHealth(entity.entity) > 0
				and isNearTrunk(entity.entity, 4.0, true)
		end,
	},
	{
		icon = "hand",
		text = "Grab Loot",
		event = "Robbery:Client:MoneyTruck:GrabLoot",
		model = `stockade2`,
		data = {},
		minDist = 10.0,
		isEnabled = function(data, entity)
			local entState = Entity(entity.entity).state
			return not entState.beingLooted
				and entState.wasThermited
				and not entState.wasLooted
				and GetEntityHealth(entity.entity) > 0
				and isNearTrunk(entity.entity, 4.0, true)
		end,
	},
	{
		icon = "car-garage",
		isEnabled = function(data, entityData)
			local inZone = Polyzone:IsCoordsInZone(GetEntityCoords(entityData.entity), false, "dealerBuyback")
			if inZone then
				return LocalPlayer.state.onDuty == inZone.dealerId
			end
		end,
		text = "Vehicle Buy Back",
		event = "Dealerships:Client:StartBuyback",
		data = {},
		minDist = 5.0,
		jobPerms = {
			{
				permissionKey = "dealership_buyback",
			},
		},
	},
}

Config.PlayerMenu = {
	{
		icon = "money-bill-1-wave",
		text = "Give Cash",
		event = "Hud:Client:GiveCash",
		data = {},
		minDist = 3.0,
	},
	{
		icon = "magnifying-glass",
		text = "Search",
		event = "Police:Client:Search",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
			{
				job = "securoserv",
				reqDuty = true,
			},
		},
	},
	{
		icon = "walkie-talkie",
		text = "Check Radio Channel",
		event = "Police:Client:GetRadioChannel",
		data = {},
		minDist = 3.0,
		isEnabled = function(data, entityData)
			if entityData ~= nil then
				local pState = Player(entityData.serverId).state
				if pState then
					return (pState.isDead and not pState.deadData?.isMinor) or pState.isCuffed
				end
			end
		end,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
		},
	},
	{
		icon = "gun",
		text = "GSR Test",
		event = "Police:Client:GSR",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
		},
	},
	{
		icon = "beer-mug",
		text = "BAC Test",
		event = "Police:Client:BAC",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
			{
				job = "ems",
				reqDuty = true,
			},
		},
	},
	{
		icon = "dna",
		text = "Take DNA Swab",
		event = "Police:Client:DNASwab",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
			{
				job = "ems",
				reqDuty = true,
			},
		},
	},
	{
		icon = "capsules",
		text = "Perform Drug Test",
		event = "EMS:Client:DrugTest",
		data = {},
		minDist = 3.0,
		jobPerms = {
			{
				job = "ems",
				reqDuty = true,
			},
		},
	},
	{
		icon = "gun",
		text = "Rob",
		event = "Robbery:Client:Holdup:Do",
		data = {},
		minDist = 3.0,
		isEnabled = function(data, target)
			local playerState = Player(target.serverId).state
			return (
				not LocalPlayer.state.onDuty
				or (
					LocalPlayer.state.onDuty ~= "police"
					and LocalPlayer.state.onDuty ~= "prison"
					and LocalPlayer.state.onDuty ~= "ems"
				)
			)
				and (
					playerState.isDead
					or playerState.isCuffed
					or IsEntityPlayingAnim(
						GetPlayerPed(GetPlayerFromServerId(target.serverId)),
						"missminuteman_1ig_2",
						"handsup_base",
						3
					)
				)
		end,
	},
	{
		icon = "location-dot-slash",
		text = "Disable Tracker",
		event = "MDT:Client:DisableTracker",
		data = {},
		minDist = 3.0,
		isEnabled = function(data, target)
			local playerState = Player(target.serverId).state
			return (
				not LocalPlayer.state.onDuty
				or (LocalPlayer.state.onDuty ~= "police" and LocalPlayer.state.onDuty ~= "prison" and LocalPlayer.state.onDuty ~= "ems")
			)
				and (playerState.onDuty == "police" or playerState.onDuty == "prison" or playerState.onDuty == "ems")
				and not playerState.trackerDisabled
				and (
					playerState.isDead
					or playerState.isCuffed
					or IsEntityPlayingAnim(
						GetPlayerPed(GetPlayerFromServerId(target.serverId)),
						"missminuteman_1ig_2",
						"handsup_base",
						3
					)
				)
		end,
	},
	{
		icon = "link",
		text = "Cuff",
		event = "Handcuffs:Client:SoftCuff",
		data = {},
		minDist = 1.5,
		anyItems = {
			{ item = "pdhandcuffs", count = 1 },
			{ item = "handcuffs", count = 1 },
			{ item = "fluffyhandcuffs", count = 1 },
		},
		isEnabled = function(data, target)
			return not Player(target.serverId).state.isCuffed and not LocalPlayer.state.isDead
		end,
	},
	{
		icon = "link-slash",
		text = "Uncuff",
		event = "Handcuffs:Client:Uncuff",
		data = {},
		minDist = 1.5,
		anyItems = {
			{ item = "pdhandcuffs", count = 1 },
			{ item = "handcuffs", count = 1 },
			{ item = "fluffyhandcuffs", count = 1 },
		},
		isEnabled = function(data, target)
			return Player(target.serverId).state.isCuffed
		end,
	},
	{
		icon = "person-walking",
		text = "Uncuff Ankles",
		event = "Handcuffs:Client:SoftCuff",
		data = {},
		minDist = 1.5,
		anyItems = {
			{ item = "pdhandcuffs", count = 1 },
			{ item = "handcuffs", count = 1 },
			{ item = "fluffyhandcuffs", count = 1 },
		},
		isEnabled = function(data, target)
			local playerState = Player(target.serverId)
			return playerState.state.isCuffed and playerState.state.isHardCuffed
		end,
	},
	{
		icon = "person-walking",
		text = "Cuff Ankles",
		event = "Handcuffs:Client:HardCuff",
		data = {},
		minDist = 1.5,
		anyItems = {
			{ item = "pdhandcuffs", count = 1 },
			{ item = "handcuffs", count = 1 },
			{ item = "fluffyhandcuffs", count = 1 },
		},
		isEnabled = function(data, target)
			local playerState = Player(target.serverId)
			return playerState.state.isCuffed and not playerState.state.isHardCuffed
		end,
	},
	{
		icon = "hockey-mask",
		text = "Remove Mask",
		event = "Police:Client:RemoveMask",
		data = {},
		minDist = 1.5,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
			{
				job = "ems",
				reqDuty = true,
			},
		},
		isEnabled = function(data, target)
			return GetPedDrawableVariation(target.entity, 1) ~= -1
		end,
	},
	{
		icon = "face-head-bandage",
		text = "Evaluate",
		event = "EMS:Client:Evaluate",
		minDist = 3.0,
		jobPerms = {
			{
				job = "police",
				reqDuty = true,
			},
			{
				job = "prison",
				reqDuty = true,
			},
			{
				job = "ems",
				reqDuty = true,
			},
		},
	},
	{
		icon = "hood-cloak",
		text = "Remove Blindfold",
		event = "HUD:Client:RemoveBlindfold",
		minDist = 3.0,
		isEnabled = function(data, target)
			local playerState = Player(target.serverId)
			return playerState.state.isBlindfolded
		end,
	},
	{
		event = "Escort:client:pickupk9",
		icon = "fa-hands",
		text = "Pickup K9",
		minDist = 1.5,
		data = { data },
		isEnabled = function(data, target)
			if not IsPedAPlayer(target.entity) then
				return false
			end
			print(
				"player?:",
				IsPedAPlayer(target.entity),
				target.entity,
				GetIsEntityK9Ped(target.entity),
				target.serverId,
				Player(target.serverId).SID,
				target.id
			)
			if IsPedAPlayer(target.entity) and GetIsEntityK9Ped(target.entity) then
				return true
			end
			return false
		end,
		action = function(entity)
			if not IsPedAPlayer(entity) then return false end
			local targetPlayerSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
			local playerId = GetPlayerServerId(entity)
			if playerId == nil then return end
			TriggerServerEvent('animations:pickupk9', targetPlayerSrc)
			TriggerEvent('animations:client:EmoteCommandStart', {"carry"})
			return true
		end,
	},
}

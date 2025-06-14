FLAGGED_PLATES = {}

AddEventHandler("Radar:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Database = exports["sandbox-base"]:FetchComponent("Database")
	Callbacks = exports["sandbox-base"]:FetchComponent("Callbacks")
	Logger = exports["sandbox-base"]:FetchComponent("Logger")
	Utils = exports["sandbox-base"]:FetchComponent("Utils")
	Chat = exports["sandbox-base"]:FetchComponent("Chat")
	Jobs = exports["sandbox-base"]:FetchComponent("Jobs")
	Fetch = exports["sandbox-base"]:FetchComponent("Fetch")
	Radar = exports["sandbox-base"]:FetchComponent("Radar")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["sandbox-base"]:RequestDependencies("Radar", {
		"Database",
		"Callbacks",
		"Logger",
		"Utils",
		"Chat",
		"Jobs",
		"Fetch",
		"Radar",
	}, function(error)
		if #error > 0 then
			return
		end -- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		RegisterChatCommands()
	end)
end)

CreateThread(function()
	GlobalState.RadarFlaggedPlates = {}
end)

function RegisterChatCommands()
	Chat:RegisterCommand(
		"flagplate",
		function(src, args, raw)
			local plate = args[1]
			local reason = args[2]

			if plate and reason then
				Radar:AddFlaggedPlate(plate:upper(), reason)

				Chat.Send.System:Single(src, "Plate Flagged: " .. plate)
			end
		end,
		{
			help = "Flag a Plate",
			params = {
				{ name = "Plate", help = "The Plate to Flag" },
				{ name = "Reason", help = "Reason Why the Plate is Flagged" },
			},
		},
		2,
		{
			{ Id = "police", Level = 1 },
		}
	)

	Chat:RegisterCommand(
		"unflagplate",
		function(src, args, raw)
			local plate = args[1]

			if plate then
				Radar:RemoveFlaggedPlate(plate)
				Chat.Send.System:Single(src, "Removed Flagged Plate: " .. plate) 
			end
		end,
		{
			help = "Unflag a Plate",
			params = {
				{ name = "Plate", help = "The Plate to Unflag" },
			},
		},
		1,
		{
			{ Id = "police", Level = 1 },
		}
	)

	Chat:RegisterCommand(
		"radar",
		function(src)
			TriggerClientEvent("Radar:Client:ToggleRadarDisabled", src)
		end,
		{
			help = "Toggle Radar",
		},
		0,
		{
			{ Id = "police", Level = 1 },
		}
	)
end

RADAR = {
	AddFlaggedPlate = function(self, plate, reason)
		if not reason then
			reason = "No Reason Specified"
		end

		Logger:Trace("Radar", string.format("New Flagged Plate: %s, Reason: %s", plate, reason))
		FLAGGED_PLATES[plate] = reason

		GlobalState.RadarFlaggedPlates = FLAGGED_PLATES
	end,
	RemoveFlaggedPlate = function(self, plate)
		Logger:Trace("Radar", string.format("Plate Unflagged: %s", plate))
		FLAGGED_PLATES[plate] = nil

		GlobalState.RadarFlaggedPlates = FLAGGED_PLATES
	end,
	ClearFlaggedPlates = function(self)
		Logger:Trace("Radar", "All Plates Unflagged")
		FLAGGED_PLATES = {}

		GlobalState.RadarFlaggedPlates = FLAGGED_PLATES
	end,
	GetFlaggedPlates = function(self)
		return FLAGGED_PLATES
	end,
	CheckPlate = function(self, plate)
		return FLAGGED_PLATES[plate]
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["sandbox-base"]:RegisterComponent("Radar", RADAR)
end)

RegisterNetEvent("Radar:Server:StolenVehicle", function(plate)
	if type(plate) == "string" then
		Radar:AddFlaggedPlate(plate, "Vehicle Reported Stolen")
	end
end)

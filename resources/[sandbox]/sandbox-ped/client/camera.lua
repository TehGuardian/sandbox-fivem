Camera = {}

Camera.entity = nil
Camera.position = vector3(0.0, 0.0, 0.0)
Camera.currentView = "standard"
Camera.active = false
Camera.updateRot = false
Camera.updateZoom = false
Camera.radius = 1.25
Camera.angleX = 30.0
Camera.angleY = 0.0
Camera.mouseX = 0
Camera.mouseY = 0

Camera.radiusMin = 1.0
Camera.radiusMax = 2.25
Camera.angleYMin = -30.0
Camera.angleYMax = 80.0

Camera.Activate = function(delay)
	if delay then
		Wait(delay)
	end

	if not DoesCamExist(Camera.entity) then
		Camera.entity = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	end

	local playerPed = PlayerPedId()
	FreezePedCameraRotation(playerPed, true)
	FreezeEntityPosition(playerPed, true)

	Camera.SetView(Camera.currentView)

	SetCamActive(Camera.entity, true)
	RenderScriptCams(true, true, 500, true, true)

	Camera.active = true
end

Camera.Deactivate = function()
	local playerPed = PlayerPedId()

    ClearPedTasksImmediately(PlayerPedId())

	SetCamActive(Camera.entity, false)
	RenderScriptCams(false, true, 500, true, true)

	FreezePedCameraRotation(playerPed, false)
	FreezeEntityPosition(playerPed, false)
	Camera.active = false
end

Camera.SetView = function(view)
	local boneIndex = -1
	if view == "standard" then
		boneIndex = 11816
		Camera.radiusMin = 1.0
		Camera.radiusMax = 3.0
		Camera.angleYMin = 0.1
		Camera.angleYMax = 15.0
	elseif view == "head" then
		boneIndex = 31086
		Camera.radius = nil
		Camera.radiusMin = 0.8
		Camera.radiusMax = 1.0
		Camera.angleYMin = 40.0
		Camera.angleYMax = 60.0
	elseif view == "body" then
		boneIndex = 11816
		Camera.radius = nil
		Camera.radiusMin = 1.0
		Camera.radiusMax = 2.0
		Camera.angleYMin = 0.1
		Camera.angleYMax = 35.0
	elseif view == "legs" then
		boneIndex = 46078
		Camera.radius = nil
		Camera.radiusMin = 1.1
		Camera.radiusMax = 1.25
		Camera.angleYMin = -30.0
		Camera.angleYMax = 10.0
	end

	Camera.radius = Camera.radiusMax - Camera.radiusMin

	Camera.angleY = Camera.angleYMin
	Camera.angleX = GetEntityHeading(PlayerPedId()) + 90.0

	Camera.position = Camera.CalculatePosition(false)
	SetCamCoord(Camera.entity, Camera.position.x, Camera.position.y, Camera.position.z)

	targetPos = GetPedBoneCoords(PlayerPedId(), boneIndex, 0.0, 0.0, 0.0)
	PointCamAtCoord(Camera.entity, targetPos.x, targetPos.y, targetPos.z)

	Camera.currentView = view
end

Camera.CalculateMaxRadius = function()
	if Camera.radius < Camera.radiusMin then
		Camera.radius = Camera.radiusMin
	elseif Camera.radius > Camera.radiusMax then
		Camera.radius = Camera.radiusMax
	end

	local result = Camera.radius

	local playerPed = PlayerPedId()
	local pedCoords = GetEntityCoords(PlayerPedId())

	local behindX = pedCoords.x
		+ ((Cos(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Cos(Camera.angleX)))
			/ 2
			* (Camera.radius + 0.5)
	local behindY = pedCoords.x
		+ ((Sin(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Sin(Camera.angleX)))
			/ 2
			* (Camera.radius + 0.5)
	local behindZ = (Sin(Camera.angleY)) * (Camera.radius + 0.5)

	local testRay = StartShapeTestRay(
		pedCoords.x,
		pedCoords.y,
		pedCoords.z + 0.5,
		behindX,
		behindY,
		behindZ,
		-1,
		playerPed,
		0
	)
	local _, hit, hitCoords = GetShapeTestResult(testRay)
	local hitDist = Vdist(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, hitCoords)

	if hit and hitDist < Camera.radius + 0.5 then
		result = hitDist
	end

	return result
end

Camera.CalculatePosition = function(adjustedAngle)
	if adjustedAngle then
		Camera.angleX = Camera.angleX - Camera.mouseX * 0.1
		Camera.angleY = Camera.angleY + Camera.mouseY * 0.1
	end

	if Camera.angleY > Camera.angleYMax then
		Camera.angleY = Camera.angleYMax
	elseif Camera.angleY < Camera.angleYMin then
		Camera.angleY = Camera.angleYMin
	end

	local radiusMax = Camera.CalculateMaxRadius()

	local offsetX = ((Cos(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Cos(Camera.angleX)))
		/ 2
		* radiusMax
	local offsetY = ((Sin(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Sin(Camera.angleX)))
		/ 2
		* radiusMax
	local offsetZ = (Sin(Camera.angleY)) * radiusMax

	local pedCoords = GetEntityCoords(PlayerPedId())

	return vector3(pedCoords.x + offsetX, pedCoords.y + offsetY, pedCoords.z + offsetZ)
end

CreateThread(function()
	while true do
		if Camera.active or FROZEN then
			DisableFirstPersonCamThisFrame()

			DisableControlAction(2, 30, true)
			DisableControlAction(2, 31, true)
			DisableControlAction(2, 32, true)
			DisableControlAction(2, 33, true)
			DisableControlAction(2, 34, true)
			DisableControlAction(2, 35, true)

			DisableControlAction(0, 25, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 1, true)
			DisableControlAction(0, 2, true)
			DisableControlAction(0, 106, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 30, true)
			DisableControlAction(0, 31, true)
			DisableControlAction(0, 21, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 58, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 75, true)

			DisableControlAction(27, 75, true)

			if Camera.updateZoom then
				local pos = Camera.CalculatePosition(false)
				SetCamCoord(Camera.entity, pos.x, pos.y, pos.z)
				Camera.updateZoom = false
			end
		end

		Wait(0)
	end
end)

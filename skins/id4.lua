local skinData = {
	-- names
	skinName = "id4",
	ytdName = "id4",
	-- texture dictionary informations:
	-- night textures are supposed to look like this:
	-- "needle", "tachometer", cst.ytdName, "fuelgauge"
	-- daytime textures this:
	-- "needle_day", "tachometer_day", "speedometer_day", "fuelgauge_day"
	-- these names are hardcoded

	-- where the speedo gets centered, values below are OFFSETS from this.
	centerCoords = {0.8,0.8},


	-- icon locations
	lightsLoc = {0.055,0.17,0.018,0.02},
	blinkerLoc = {0.08,0.17,0.022,0.03},
	fuelLoc = {0.035,0.17,0.012,0.025},
	oilLoc = {0.140,0.17,0.020,0.025},
	engineLoc = {0.170,0.17,0.020,0.025},

	-- gauge locations
	SpeedoBGLoc = {0.11, 0.015, 0.16,0.275},
	SpeedoNeedleLoc = {0.0,5.0,0.07,0.07},

	TachoBGloc = {0.110,-0,0.135,0.200},
	TachoNeedleLoc = {0.110,0.010,0.155,0.25},

	FuelBGLoc = {0.010, 0.123,0.050, 0.040},
	FuelGaugeLoc = {0.060,0.000,0.030,0.080},
	enableDigits = true,
	enableGear = true,

	-- you can also add your own values and use them in the code below, the sky is the limit!
	GearLoc = {0.092,0.1,0.008,0.019}, -- gear location
	Speed1Loc = {0.110,0.1,0.010,0.020}, -- 3rd digit
	Speed2Loc = {0.121,0.1,0.010,0.020}, -- 2nd digit
	Speed3Loc = {0.131,0.1,0.010,0.020}, -- 1st digit
	UnitLoc = {0.121,0.0982,0.05,0.02},
	RotMult = 2.036936,
	RotStep = 2.32833,
	rpmScaleDecrease = 23,

	-- rpm scale, defines how "far" the rpm gauge goes before hitting redline
	rpmScale = 210,

}

addSkin(skinData)


-- addon code

local idcars = {"FUTO", "AE86", "86", "BLISTA2", "86coupe", "levin86"} -- cars that use the AE86 speed chime and ae86 RPM background
local labelType = "8k"
local curDriftAlpha = 0
local curAlpha = 0
local useKPH = GetResourceKvpString("initiald_unit") -- handle our unit saving
if not useKPH then
	SetResourceKvp("initiald_unit", "true")
	useKPH = true
end
if useKPH	== "true" then
	useKPH = true
elseif useKPH == "false" then
	useKPH = false
end

function angle(veh)
	if not veh then return false end
	local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
	local modV = math.sqrt(vx*vx + vy*vy)


	local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	if GetEntitySpeed(veh)* 3.6 < 40 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --speed over 25 km/h

	local cosX = (sn*vx + cs*vy)/modV
	return math.deg(math.acos(cosX))*0.5, modV
end
local function BlinkDriftText(hide)
	if overwriteAlpha then curDriftAlpha = 0 return end
	if hide == true or goDown == true then
		curDriftAlpha = curDriftAlpha-15
	elseif not hide or goDown == false then
		curDriftAlpha = curDriftAlpha+15
	end
	if curDriftAlpha <= 0 then
		curDriftAlpha = 0
		goDown = false
	elseif curDriftAlpha >= 255 then
		curDriftAlpha = 255
		if driftSprite ~= "drift_yellow" then
			goDown = true
		end
	end
end
SpeedChimeActive = false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if getCurrentSkin() == skinData.skinName then
			if overwriteAlpha then curAlpha = 0 end
			if not overwriteAlpha then
				if IsPedInAnyVehicle(PlayerPed,true) and GetSeatPedIsTryingToEnter(PlayerPed) == -1 or GetPedInVehicleSeat(veh, -1) == PlayerPed then
						if curAlpha >= 255 then
							curAlpha = 255
						else
							curAlpha = curAlpha+5
						end
				elseif not IsPedInAnyVehicle(PlayerPed,false) then
						if curAlpha <= 0 then
							curAlpha = 0
						else
							curAlpha = curAlpha-5
						end
					end
			end
			speedTable = {}
			showFuelGauge = false
			if DoesCurrentVehExist then
				if vehclass >= 0 and vehclass <= 5 then
					labelType = "8k"
					skinData.rpmScale = 210
				elseif vehclass == 6 then
					labelType = "9k"
					skinData.rpmScale = 240
				elseif vehclass == 7 then
					labelType = "10k"
					skinData.rpmScale = 240
				elseif vehclass == 8 then
					labelType = "13k"
					skinData.rpmScale = 225
				end
				for i,theName in ipairs(idcars) do
					if string.find(GetDisplayNameFromVehicleModel(vehmodel), theName) ~= nil and string.find(GetDisplayNameFromVehicleModel(vehmodel), theName) >= 0 then
						labelType = "86"
						skinData.rpmScale = 242
					end
					if GetDisplayNameFromVehicleModel(vehmodel) == theName then
						if not SpeedChimeActive and GetEntitySpeed(veh)*3.6 > 105.0 then
							SpeedChimeActive = true
							TriggerEvent("initiald:Sound:PlayOnOne","initiald",0.7,true)
						elseif SpeedChimeActive and GetEntitySpeed(veh)*3.6 < 105.0 then
							SpeedChimeActive = false
							TriggerEvent("initiald:Sound:StopOnOne")
						end
					end
				end

				_,lightson,highbeams = GetVehicleLightsState(veh)
				if lightson == 1 or highbeams == 1 then
					curTachometer = "night_labels_"..labelType
				else
					curTachometer = "labels_"..labelType
				end
				curSpeedometer = "nodrift_background"

				local gear = GetVehicleCurrentGear(veh)+1

				if not gear then gear = 1 end
				if gear == 1 then gear = 0 end
				SetOverriddenTexture("tachometerbg", curTachometer)
				SetOverriddenTexture("speedometerbg", curSpeedometer)

				--DrawSprite(skinData.ytdName, curSpeedometer, skinData.centerCoords[1]+skinData.SpeedoBGLoc[1],skinData.centerCoords[2]+skinData.SpeedoBGLoc[2],skinData.SpeedoBGLoc[3],skinData.SpeedoBGLoc[4], 0.0, 255, 255, 255, curAlpha)
				--DrawSprite(skinData.ytdName, curTachometer, skinData.centerCoords[1]+skinData.TachoBGloc[1],skinData.centerCoords[2]+skinData.TachoBGloc[2],skinData.TachoBGloc[3],skinData.TachoBGloc[4], 0.0, 255, 255, 255, curAlpha)
				--DrawSprite(skinData.ytdName, "gear_"..gear, skinData.centerCoords[1]+skinData.GearLoc[1],skinData.centerCoords[2]+skinData.GearLoc[2],skinData.GearLoc[3],skinData.GearLoc[4], 0.0, 255, 255, 255, curAlpha)

				local speed = GetEntitySpeed(veh)

				if useKPH then
					speed = GetEntitySpeed(veh)* 3.6
				else
					speed = GetEntitySpeed(veh)*2.236936
				end
				if not speed then speed = "0.0" end
				--[[
				speed = tonumber(string.format("%." .. (0) .. "f", speed))
				speed = tostring(speed)
				for i = 1, string.len(speed) do
					speedTable[i] = speed:sub(i, i)
				end
				if string.len(speed) == 1 then
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[1], skinData.centerCoords[1]+skinData.Speed3Loc[1],skinData.centerCoords[2]+skinData.Speed3Loc[2],skinData.Speed3Loc[3],skinData.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
				elseif string.len(speed) == 2 then
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[1], skinData.centerCoords[1]+skinData.Speed2Loc[1],skinData.centerCoords[2]+skinData.Speed2Loc[2],skinData.Speed2Loc[3],skinData.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[2], skinData.centerCoords[1]+skinData.Speed3Loc[1],skinData.centerCoords[2]+skinData.Speed3Loc[2],skinData.Speed3Loc[3],skinData.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
				elseif string.len(speed) == 3 then
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[1], skinData.centerCoords[1]+skinData.Speed1Loc[1],skinData.centerCoords[2]+skinData.Speed1Loc[2],skinData.Speed1Loc[3],skinData.Speed1Loc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[2], skinData.centerCoords[1]+skinData.Speed2Loc[1],skinData.centerCoords[2]+skinData.Speed2Loc[2],skinData.Speed2Loc[3],skinData.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(skinData.ytdName, "speed_digits_"..speedTable[3], skinData.centerCoords[1]+skinData.Speed3Loc[1],skinData.centerCoords[2]+skinData.Speed3Loc[2],skinData.Speed3Loc[3],skinData.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
				elseif string.len(speed) >= 4 then
					DrawSprite(skinData.ytdName, "speed_digits_9", skinData.centerCoords[1]+skinData.Speed3Loc[1],skinData.centerCoords[2]+skinData.Speed3Loc[2],skinData.Speed3Loc[3],skinData.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(skinData.ytdName, "speed_digits_9", skinData.centerCoords[1]+skinData.Speed2Loc[1],skinData.centerCoords[2]+skinData.Speed2Loc[2],skinData.Speed2Loc[3],skinData.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(skinData.ytdName, "speed_digits_9", skinData.centerCoords[1]+skinData.Speed1Loc[1],skinData.centerCoords[2]+skinData.Speed1Loc[2],skinData.Speed1Loc[3],skinData.Speed1Loc[4], 0.0, 255, 255, 255, curAlpha)
				end
				]]

				if GetPedInVehicleSeat(veh, -1) == PlayerPed and vehclass >= 0 and vehclass < 13 or vehclass >= 17 then
					if angle(veh) >= 10 and angle(veh) <= 18 and GetEntityHeightAboveGround(veh) <= 1.5 then
						driftSprite = "drift_blue"
						DrawSprite(skinData.ytdName, driftSprite, skinData.centerCoords[1]+skinData.FuelBGLoc[1],skinData.centerCoords[2]+skinData.FuelBGLoc[2],skinData.FuelBGLoc[3],skinData.FuelBGLoc[4], 0.0, 255, 255, 255, curDriftAlpha)
						BlinkDriftText(false)
					elseif angle(veh) > 18 and GetEntityHeightAboveGround(veh) <= 1.5 then
						driftSprite = "drift_yellow"
						DrawSprite(skinData.ytdName, driftSprite, skinData.centerCoords[1]+skinData.FuelBGLoc[1],skinData.centerCoords[2]+skinData.FuelBGLoc[2],skinData.FuelBGLoc[3],skinData.FuelBGLoc[4], 0.0, 255, 255, 255, curDriftAlpha)
						BlinkDriftText(false)
					elseif angle(veh) < 10 and GetEntityHeightAboveGround(veh) <= 1.5 then
						driftSprite = "drift_blue"
						DrawSprite(skinData.ytdName, driftSprite, skinData.centerCoords[1]+skinData.FuelBGLoc[1],skinData.centerCoords[2]+skinData.FuelBGLoc[2],skinData.FuelBGLoc[3],skinData.FuelBGLoc[4], 0.0, 255, 255, 255, curDriftAlpha)
						BlinkDriftText(true)
					end
				else
					curDriftAlpha = 0
				end


			end
		end
	end
end)

function switchUnit()
	useKPH = not useKPH
end

Citizen.CreateThread(function()
	RegisterCommand("speedounit", function(source, args, rawCommand)
		if getCurrentSkin() == skinData.skinName then
			useKPH = not useKPH
			SetResourceKvp("initiald_unit", tostring(useKPH))
		end
	end, false)


	RegisterNetEvent('initiald:Sound:PlayOnOne')
	AddEventHandler('initiald:Sound:PlayOnOne', function(soundFile, soundVolume, loop)
	    SendNUIMessage({
	        transactionType     = 'playSound',
	        transactionFile     = soundFile,
	        transactionVolume   = soundVolume,
			transactionLoop   = loop
	    })
	end)

	RegisterNetEvent('initiald:Sound:StopOnOne')
	AddEventHandler('initiald:Sound:StopOnOne', function()
	    SendNUIMessage({
	        transactionType     = 'stopSound'
	    })
	end)

end)

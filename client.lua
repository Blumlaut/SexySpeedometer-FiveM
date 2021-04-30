--SETTINGS--
showFuelGauge = true -- use fuel gauge?
skins = {}
--SETTINGS END--
overwriteAlpha = false
scriptReady = false

local OverriddenTextures = {}

function addSkin(skin)
	table.insert(skins,skin)
end

function getAvailableSkins()
	local tt = {}
	for i,theSkin in pairs(skins) do
		table.insert(tt,theSkin.skinName)
	end
	return tt
end

function toggleFuelGauge(toggle)
	showFuelGauge = toggle
end

function changeSkin(skin)
	for i,theSkin in pairs(skins) do
		if theSkin.skinName == skin then
			cst = theSkin
			currentSkin = theSkin.skinName
			SetResourceKvp("sexyspeedo_skin", skin)
			showFuelGauge = true
			overwriteAlpha = false
			for i,v in pairs(OverriddenTextures) do 
				OverriddenTextures[i]=nil
			end
			return true
		end
	end
	return false
end

function DoesSkinExist(skinName)
	for i,theSkin in pairs(getAvailableSkins()) do
		if theSkin == skinName then
			return true
		end
	end
	return false
end

function getCurrentSkin()
	return currentSkin
end

function toggleSpeedo(state)
	if state == true then
		overwriteAlpha = false
	elseif state == false then
		overwriteAlpha = true
	else
		overwriteAlpha = not overwriteAlpha
	end
end

local textureTypes = {
	"needle", "tachometer", "speedometer", "fuelneedle", "fuelgauge","speedometerbg","tachometerbg", "blinker", "engine", "fuel", "lights", "oil", "gear", "kmh", "mph", "digits", "turbo"
}



function SetOverriddenTexture(type, state)
	for i, item in pairs(textureTypes) do 
		if item == type then
			OverriddenTextures[type] = state
		end
	end
end

Citizen.CreateThread(function()
	currentSkin = GetResourceKvpString("sexyspeedo_skin")
	while not skins[1] do
		Wait(100)
	end
	-- init values
	RPM = 0
	gear = 0
	speed = 0
	if not currentSkin or currentSkin == "default" then
		SetResourceKvp("sexyspeedo_skin", "default")
		if DoesSkinExist("default") then
			currentSkin = "default"
			changeSkin("default")
		else
			currentSkin = skins[1].skinName
			changeSkin(skins[1].skinName)
		end
	else
		for i,theSkin in pairs(skins) do
			if theSkin.skinName == currentSkin then
				cst = theSkin
				changeSkin(theSkin.skinName) -- make sure to set the skin properly
			end
		end
		if not cst then 
			changeSkin(skins[1].skinName) 
		end
	end
	scriptReady = true
end)

--cst = {skinName = "default",ytdName = "default",lightsIconLocation = {0.810,0.892,0.018,0.02},blinkerIconLocation = {0.905,0.834,0.022,0.03},fuelIconLocation = {0.905,0.890,0.012,0.025},oilIconLocation = {0.900,0.862,0.020,0.025},engineIconLocation = {0.930,0.892,0.020,0.025},SpeedometerBGLocation = {0.800,0.860,0.12,0.185},SpeedometerNeedleLocation = {0.800,0.862,0.076,0.15},TachometerBGLocation = {0.920,0.860,0.12,0.185},TachoNeedleLocation = {0.920,0.862,0.076,0.15},FuelBGLocation = {0.860, 0.780,0.04, 0.04},FuelGaugeLocation = {0.860,0.800,0.040,0.08},RotMultiplier = 2.036936,RotStep = 2.32833}
-- temporary skinTable incase what i had in mind doesnt work

RegisterCommand("speedoskin", function(source, args, rawCommand)
	if args[1] then
		changeSkin(args[1])
	end
end, false)

RegisterCommand("speedoskins", function(source, args, rawCommand)
	local s = getAvailableSkins()
	local ss = ""
	for i,s in pairs(s) do
		ss = ss..""..s..", "
	end
	TriggerEvent("chat:addMessage", { args = { "Available Skins", ss } })
end, false)

RegisterCommand("togglespeedo", function(source, args, rawCommand)
	toggleSpeedo()
end, false)

RegisterCommand("speedounit", function(source, args, rawCommand)
	useKPH = not useKPH
	cst.useKPH = useKPH
	SetResourceKvp("initiald_unit", tostring(useKPH))
end, false)

Citizen.CreateThread(function()
	PlayerPed = PlayerPedId()
	repeat
		Wait(50)
	until scriptReady
	while true do
		Citizen.Wait(300)
		PlayerPed = PlayerPedId()
		inVehicleAtGetin = IsPedInAnyVehicle(PlayerPed, true)
		inVehicle = IsPedInAnyVehicle(PlayerPed, false)
		HasTextureDictLoaded = HasStreamedTextureDictLoaded(cst.ytdName)
		if inVehicleAtGetin or inVehicle then
			veh = GetVehiclePedIsUsing(PlayerPed)
			DoesCurrentVehExist = (DoesEntityExist(veh) and not IsEntityDead(veh))
			if DoesCurrentVehExist then 
				vehclass = GetVehicleClass(veh)
				vehmodel = GetEntityModel(veh)
				engineHealth = GetVehicleEngineHealth(veh)
				OilLevel = GetVehicleOilLevel(veh)
				FuelLevel = GetVehicleFuelLevel(veh)
				_,lightson,highbeams = GetVehicleLightsState(veh)
				vehdisplayname = GetDisplayNameFromVehicleModel(vehmodel)
				vehindicators = GetVehicleIndicatorLights(veh)
				pedInVehicleSeat = GetPedInVehicleSeat(veh, -1)
				MaxFuelLevel = GetVehicleHandlingFloat(veh, "CHandlingData", "fPetrolTankVolume")
			end
		else
			veh = nil
			DoesCurrentVehExist = false
			pedInVehicleSeat = nil
		end
	end
end)
Citizen.CreateThread(function()
	repeat
		Wait(10)
	until scriptReady
	while true do
		degree, step = 0-(cst.speedDecrease or 0), cst.RotStep
		if (DoesCurrentVehExist) then 
			RPM = GetVehicleCurrentRpm(veh)
			gear = GetVehicleCurrentGear(veh)+1
			speed = GetEntitySpeed(veh)
			if not GetIsVehicleEngineRunning(veh) then RPM = 0 end -- fix for R*'s Engine RPM fuckery
			if RPM > 0.99 then
				RPM = RPM*100
				RPM = RPM+math.random(-2,2)
				RPM = RPM/100
			end
			if speed > 0 then degree= ((speed*2.036936)*step)-(cst.speedDecrease or 0) end
			--if degree > 290 then degree=290-(cst.speedDecrease or 0) end
		else
			Wait(200)
		end
		Citizen.Wait(10)
	end
end)

curNeedle, curTachometer, curSpeedometer, curFuelGauge, curAlpha = "needle_day", "tachometer_day", "speedometer_day", "fuelgauge_day",0
RPM, degree, blinkertick, showBlinker = 0, 0, 0, false
overwriteChecks = false -- debug value to display all icons
Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/togglespeedo', 'show/hide speedometer' )
	TriggerEvent('chat:addSuggestion', '/speedoskins', 'show all available speedometer skins' )
	TriggerEvent('chat:addSuggestion', '/speedoskin', 'change the speedometer skin', { {name='skin', help="the skin name"} } )
	repeat
		Wait(500)
	until scriptReady

	while true do
		Citizen.Wait(0)
		if (inVehicleAtGetin or inVehicle) then
			if overwriteAlpha then curAlpha = 0 end
			if not overwriteAlpha then
				if inVehicleAtGetin and GetSeatPedIsTryingToEnter(PlayerPed) == -1 or pedInVehicleSeat == PlayerPed then
					if curAlpha >= 255 then
						curAlpha = 255
					else
						curAlpha = curAlpha+5
					end
				end
			end
		else
			if curAlpha <= 0 then
				curAlpha = 0
			else
				curAlpha = curAlpha-5
			end
		end

		if not HasTextureDictLoaded then
			RequestStreamedTextureDict(cst.ytdName, true)
			while not HasTextureDictLoaded do
				Wait(0)
			end
		else
			if (DoesCurrentVehExist) then
				if cst.useKPH == nil then cst.useKPH = true end
				blinkerstate = vehindicators -- owo whats this
				if blinkerstate == 0 then
					blinkerleft,blinkerright = false,false
				elseif blinkerstate == 1 then
					blinkerleft,blinkerright = true,false
				elseif blinkerstate == 2 then
					blinkerleft,blinkerright = false,true
				elseif blinkerstate == 3 then
					blinkerleft,blinkerright = true,true
				end
				if engineHealth <= 350 and engineHealth > 100 then
					showDamageYellow,showDamageRed = true,false
				elseif engineHealth <= 100 then
					showDamageYellow,showDamageRed = false, true
				else
					showDamageYellow,showDamageRed = false, false
				end
				if FuelLevel <= MaxFuelLevel*0.25 and FuelLevel > MaxFuelLevel*0.13 then
					showLowFuelYellow,showLowFuelRed = true,false
				elseif FuelLevel <= MaxFuelLevel*0.2 then
					showLowFuelYellow,showLowFuelRed = false,true
				else
					showLowFuelYellow,showLowFuelRed = false,false
				end
				if OilLevel <= 0.5 then
					showLowOil = true
				else
					showLowOil = false
				end
				if lightson == 1 or highbeams == 1 then
					curNeedle, curTachometer, curSpeedometer, curFuelGauge = "needle", "tachometer", "speedometer", "fuelgauge"
					if highbeams == 1 then
						showHighBeams,showLowBeams = true,false
					elseif lightson == 1 and highbeams == 0 then
						showHighBeams,showLowBeams = false,true
					end
				else
					curNeedle, curTachometer, curSpeedometer, curFuelGauge, showHighBeams, showLowBeams = "needle_day", "tachometer_day", "speedometer_day", "fuelgauge_day", false, false
				end
				if vehclass >= 0 and vehclass < 13 or vehclass >= 17 then
					
				else
					curAlpha = 0
				end
				if RPM < 0.12 or not RPM then
					RPM = 0.12
				end
			else
				RPM, degree = 0, 0
			end
			if overwriteChecks then
				showHighBeams,showLowBeams,showBlinker,blinkerleft,blinkerright,showDamageRed,showLowFuelRed,showLowOil = true, true, true, true, true ,true, true, true
			end
			if curAlpha ~= 0.0 then

				if showHighBeams then
					DrawSprite(cst.ytdName, OverriddenTextures["lights"] or cst.BeamLight or "lights", cst.centerCoords[1]+cst.lightsLoc[1],cst.centerCoords[2]+cst.lightsLoc[2],cst.lightsLoc[3],cst.lightsLoc[4],0, 0, 50, 240, curAlpha)
				elseif showLowBeams then
					DrawSprite(cst.ytdName, OverriddenTextures["lights"] or cst.BeamLight or "lights", cst.centerCoords[1]+cst.lightsLoc[1],cst.centerCoords[2]+cst.lightsLoc[2],cst.lightsLoc[3],cst.lightsLoc[4],0, 0, 255, 0, curAlpha)
				end
				if blinkerleft and showBlinker then
					DrawSprite(cst.ytdName, OverriddenTextures["blinker"] or cst.BlinkerLight or "blinker", cst.centerCoords[1]+cst.blinkerLoc[1],cst.centerCoords[2]+cst.blinkerLoc[2],cst.blinkerLoc[3],cst.blinkerLoc[4],180.0, 124,252,0, curAlpha)
				end
				if blinkerright and showBlinker then
					DrawSprite(cst.ytdName, OverriddenTextures["blinker"] or cst.BlinkerLight or "blinker", cst.centerCoords[1]+cst.blinkerLoc[1]+0.03,cst.centerCoords[2]+cst.blinkerLoc[2]-0.001,cst.blinkerLoc[3],cst.blinkerLoc[4],0.0, 124,252,0, curAlpha)
				end
				if MaxFuelLevel ~= 0 then
					if showLowFuelYellow then
						DrawSprite(cst.ytdName, OverriddenTextures["fuel"] or cst.FuelLight or "fuel", cst.centerCoords[1]+cst.fuelLoc[1],cst.centerCoords[2]+cst.fuelLoc[2],cst.fuelLoc[3],cst.fuelLoc[4],0, 255, 191, 0, curAlpha)
					elseif showLowFuelRed then
						DrawSprite(cst.ytdName, OverriddenTextures["fuel"] or cst.FuelLight or "fuel", cst.centerCoords[1]+cst.fuelLoc[1],cst.centerCoords[2]+cst.fuelLoc[2],cst.fuelLoc[3],cst.fuelLoc[4],0, 255, 0, 0, curAlpha)
					end
					if showLowOil then
						DrawSprite(cst.ytdName, OverriddenTextures["oil"] or cst.OilLight or "oil", cst.centerCoords[1]+cst.oilLoc[1],cst.centerCoords[2]+cst.oilLoc[2],cst.oilLoc[3],cst.oilLoc[4],0, 255, 0, 0, curAlpha)
					end -- MAKE SURE TO DRAW THIS BEFORE THE TACHO NEEDLE, OTHERWISE OVERLAPPING WILL HAPPEN!
				end
				if showDamageYellow then
					DrawSprite(cst.ytdName, OverriddenTextures["engine"] or cst.EngineLight or "engine", cst.centerCoords[1]+cst.engineLoc[1],cst.centerCoords[2]+cst.engineLoc[2],cst.engineLoc[3],cst.engineLoc[4],0, 255, 191, 0, curAlpha)
				elseif showDamageRed then
					DrawSprite(cst.ytdName, OverriddenTextures["engine"] or cst.EngineLight or "engine", cst.centerCoords[1]+cst.engineLoc[1],cst.centerCoords[2]+cst.engineLoc[2],cst.engineLoc[3],cst.engineLoc[4],0, 255, 0, 0, curAlpha)
				end
				DrawSprite(cst.ytdName, OverriddenTextures["speedometerbg"] or cst.SpeedometerBG or curSpeedometer, cst.centerCoords[1]+cst.SpeedoBGLoc[1],cst.centerCoords[2]+cst.SpeedoBGLoc[2],cst.SpeedoBGLoc[3],cst.SpeedoBGLoc[4], 0.0, 255, 255, 255, curAlpha)
				if MaxFuelLevel ~= 0 then
					DrawSprite(cst.ytdName, OverriddenTextures["tachometerbg"] or cst.TachometerBG or curTachometer, cst.centerCoords[1]+cst.TachoBGloc[1],cst.centerCoords[2]+cst.TachoBGloc[2],cst.TachoBGloc[3],cst.TachoBGloc[4], 0.0, 255, 255, 255, curAlpha)
					DrawSprite(cst.ytdName, OverriddenTextures["needle"] or cst.Needle or curNeedle, cst.centerCoords[1]+cst.TachoNeedleLoc[1],cst.centerCoords[2]+cst.TachoNeedleLoc[2],cst.TachoNeedleLoc[3],cst.TachoNeedleLoc[4],RPM*(cst.rpmScale)-(cst.rpmScaleDecrease or 0), 255, 255, 255, curAlpha)
				end
				DrawSprite(cst.ytdName, OverriddenTextures["needle"] or cst.Needle or  curNeedle, cst.centerCoords[1]+cst.SpeedoNeedleLoc[1],cst.centerCoords[2]+cst.SpeedoNeedleLoc[2],cst.SpeedoNeedleLoc[3],cst.SpeedoNeedleLoc[4],-5.00001+degree, 255, 255, 255, curAlpha)
				if (cst.ShowFuel and showFuelGauge) and FuelLevel and MaxFuelLevel ~= 0 then
					DrawSprite(cst.ytdName, OverriddenTextures["fuelgauge"] or cst.FuelGauge or curFuelGauge, cst.centerCoords[1]+cst.FuelBGLoc[1],cst.centerCoords[2]+cst.FuelBGLoc[2],cst.FuelBGLoc[3],cst.FuelBGLoc[4], 0.0, 255,255,255, curAlpha)
					DrawSprite(cst.ytdName, OverriddenTextures["fuelneedle"] or cst.FuelNeedle or curNeedle, cst.centerCoords[1]+cst.FuelGaugeLoc[1],cst.centerCoords[2]+cst.FuelGaugeLoc[2],cst.FuelGaugeLoc[3],cst.FuelGaugeLoc[4],80.0+FuelLevel/MaxFuelLevel*110, 255, 255, 255, curAlpha)
				end
				if (cst.enableGear) then

					if not gear then gear = 1 end
					if gear == 1 then gear = 0 end
					DrawSprite(cst.ytdName, "gear_"..gear, cst.centerCoords[1]+cst.GearLoc[1],cst.centerCoords[2]+cst.GearLoc[2],cst.GearLoc[3],cst.GearLoc[4], 0.0, 255, 255, 255, curAlpha)
				end

				if (cst.enableDigits) then

					if cst.useKPH == true or cst.useKPH == nil then
						displayspeed = speed* 3.6
					else
						displayspeed = speed*2.236936
					end
					displayspeed = tonumber(string.format("%." .. (0) .. "f", displayspeed))
					displayspeed = tostring(displayspeed)
					local speedTable = {}
					for i = 1, string.len(displayspeed) do
						speedTable[i] = displayspeed:sub(i, i)
					end
					if string.len(displayspeed) == 1 then
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[1], cst.centerCoords[1]+cst.Speed3Loc[1],cst.centerCoords[2]+cst.Speed3Loc[2],cst.Speed3Loc[3],cst.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
					elseif string.len(displayspeed) == 2 then
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[1], cst.centerCoords[1]+cst.Speed2Loc[1],cst.centerCoords[2]+cst.Speed2Loc[2],cst.Speed2Loc[3],cst.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[2], cst.centerCoords[1]+cst.Speed3Loc[1],cst.centerCoords[2]+cst.Speed3Loc[2],cst.Speed3Loc[3],cst.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
					elseif string.len(displayspeed) == 3 then
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[1], cst.centerCoords[1]+cst.Speed1Loc[1],cst.centerCoords[2]+cst.Speed1Loc[2],cst.Speed1Loc[3],cst.Speed1Loc[4], 0.0, 255, 255, 255, curAlpha)
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[2], cst.centerCoords[1]+cst.Speed2Loc[1],cst.centerCoords[2]+cst.Speed2Loc[2],cst.Speed2Loc[3],cst.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
						DrawSprite(cst.ytdName, "speed_digits_"..speedTable[3], cst.centerCoords[1]+cst.Speed3Loc[1],cst.centerCoords[2]+cst.Speed3Loc[2],cst.Speed3Loc[3],cst.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
					elseif string.len(displayspeed) >= 4 then
						DrawSprite(cst.ytdName, "speed_digits_9", cst.centerCoords[1]+cst.Speed3Loc[1],cst.centerCoords[2]+cst.Speed3Loc[2],cst.Speed3Loc[3],cst.Speed3Loc[4], 0.0, 255, 255, 255, curAlpha)
						DrawSprite(cst.ytdName, "speed_digits_9", cst.centerCoords[1]+cst.Speed2Loc[1],cst.centerCoords[2]+cst.Speed2Loc[2],cst.Speed2Loc[3],cst.Speed2Loc[4], 0.0, 255, 255, 255, curAlpha)
						DrawSprite(cst.ytdName, "speed_digits_9", cst.centerCoords[1]+cst.Speed1Loc[1],cst.centerCoords[2]+cst.Speed1Loc[2],cst.Speed1Loc[3],cst.Speed1Loc[4], 0.0, 255, 255, 255, curAlpha)
					end
				end
			end
		end
	end

end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if DoesCurrentVehExist and (blinkerleft or blinkerright) then
			showBlinker = true
			Citizen.Wait(500)
			showBlinker = false
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	repeat
		Wait(100) -- wait for any slowpokes not adding their skins fast enough
	until scriptReady
	TriggerEvent("sexyspeedometer:ready"--[[.. to Rock]], getAvailableSkins(), getCurrentSkin())
	-- AddEventHandler("sexyspeedometer:Ready", function(skins, currentSkin)
end)

curNeedle, curTachometer, curSpeedometer, curAlpha = "needle_day", "tachometer_day", "speedometer_day",	0
RPM, degree, blinkertick, showBlinker = 0, 0, 0, false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
		if IsPedInAnyVehicle(GetPlayerPed(-1),true) and GetSeatPedIsTryingToEnter(GetPlayerPed(-1)) == -1 or GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1) then
			if curAlpha >= 255 then
				curAlpha = 255
			else
				curAlpha = curAlpha+5
			end
		elseif not IsPedInAnyVehicle(GetPlayerPed(-1),false) then
			if curAlpha <= 0 then
				curAlpha = 0
			else
				curAlpha = curAlpha-5
			end
		end
		if not HasStreamedTextureDictLoaded("speedometer") then
			RequestStreamedTextureDict("speedometer", true)
			while not HasStreamedTextureDictLoaded("speedometer") do
				Wait(0)
			end
		else
			if DoesEntityExist(veh) and not IsEntityDead(veh) then
				degree, step = 0, 2.32833
				RPM = GetVehicleCurrentRpm(veh)
				if not GetIsVehicleEngineRunning(veh) then RPM = 0 end -- fix for R*'s Engine RPM fuckery
				if RPM > 0.99 then
					RPM = RPM*100
					RPM = RPM+math.random(-2,2)
					RPM = RPM/100
				end
				_,blinkerleft,blinkerright = "eh",true,true -- owo whats this
--				if blinkerleft or blinkerright then
--					if blinkertick >= 50 and blinkertick < 100 then
--						showBlinker = false
--					elseif blinkertick >= 0 then
--						showBlinker = true
--						SetVehicleIndicatorLights(veh, 1, true)
--						SetVehicleIndicatorLights(veh, 0, true)
--					end
--					if blinkertick >= 100 then
--						blinkertick = 0
--					end
--				end
				engineHealth = GetVehicleEngineHealth(veh)
				if engineHealth <= 350 and engineHealth > 100 then
					showDamageYellow,showDamageRed = true,false
				elseif engineHealth <= 100 then
					showDamageYellow,showDamageRed = false, true
				else
					showDamageYellow,showDamageRed = false, false
				end
				_,lightson,highbeams = GetVehicleLightsState(veh)
				if lightson == 1 or highbeams == 1 then	
					curNeedle, curTachometer, curSpeedometer = "needle", "tachometer", "speedometer"
					if highbeams == 1 then
						showHighBeams,showLowBeams = true,false
					elseif lightson == 1 and highbeams == 0 then
						showHighBeams,showLowBeams = false,true
					end
				else
					curNeedle, curTachometer, curSpeedometer, showHighBeams, showLowBeams = "needle_day", "tachometer_day", "speedometer_day", false, false
				end
				if GetEntitySpeed(veh) > 0 then degree=(GetEntitySpeed(veh)*2.036936)*step end
				if degree > 290 then degree=290 end
				if GetVehicleClass(veh) >= 0 and GetVehicleClass(veh) < 13 or GetVehicleClass(veh) > 17 then
				else
					curAlpha = 0
				end
			else
				RPM, degree = 0, 0
			end
			if showHighBeams then
				DrawSprite("speedometer", "lights", 0.810,0.892,0.018,0.02,0, 0, 50, 240, curAlpha)
			elseif showLowBeams then
				DrawSprite("speedometer", "lights", 0.810,0.892,0.018,0.02,0, 0, 255, 0, curAlpha)
			end
			if blinkerleft and showBlinker then
				DrawSprite("speedometer", "blinker", 0.905,0.834,0.022,0.03,180.0, 124,252,0, curAlpha)
			end
			if blinkerright and showBlinker then
				DrawSprite("speedometer", "blinker", 0.935,0.832,0.022,0.030,0.0, 124,252,0, curAlpha)
			end
			if showDamageYellow then
				DrawSprite("speedometer", "engine", 0.935,0.882,0.022,0.025,0, 255, 191, 0, curAlpha)
			elseif showDamageRed then
				DrawSprite("speedometer", "engine", 0.935,0.882,0.022,0.025,0, 255, 0, 0, curAlpha)
			end -- MAKE SURE TO DRAW THIS BEFORE THE TACHO NEEDLE, OTHERWISE OVERLAPPING WILL HAPPEN!
			DrawSprite("speedometer", curSpeedometer, 0.800,0.860,0.12,0.185, 0.0, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curTachometer, 0.920,0.860,0.12,0.185, 0.0, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curNeedle, 0.800,0.862,0.076,0.15,-5.00001+degree, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curNeedle, 0.920,0.862,0.076,0.15,RPM*280-30, 255, 255, 255, curAlpha)
		end
	end
	
end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(485)
		showBlinker = true
		Citizen.Wait(485)
		showBlinker = false
	end
end
)
			

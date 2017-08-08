curNeedle = "needle_day"
curTachometer = "tachometer_day"
curSpeedometer = "speedometer_day"
curAlpha = 0
RPM = 0
degree = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if IsPedInAnyVehicle(GetPlayerPed(-1),true) then
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
				degree, step = 0, 2.05833
				RPM = GetVehicleCurrentRpm(veh)
				if not GetIsVehicleEngineRunning(veh) then RPM = 0 end -- fix for R*'s Engine RPM fuckery
				if RPM > 0.99 then
					RPM = RPM*100
					RPM = RPM+math.random(-2,2)
					RPM = RPM/100
				end
				_,lightson,highbeams = GetVehicleLightsState(veh)
				if lightson == 1 or highbeams == 1 then	
					curNeedle, curTachometer, curSpeedometer = "needle", "tachometer", "speedometer"
					if highbeams == 1 then
						DrawSprite("speedometer", "lights", 0.810,0.892,0.02,0.02,0, 0, 50, 240, curAlpha)
					else
						DrawSprite("speedometer", "lights", 0.810,0.892,0.02,0.02,0, 0, 255, 0, curAlpha)
					end
				else
					curNeedle, curTachometer, curSpeedometer = "needle_day", "tachometer_day", "speedometer_day"
				end
				if GetEntitySpeed(veh) > 0 then degree=(GetEntitySpeed(veh)*2.236936)*step end
				if degree > 290 then degree=290 end
				if GetVehicleClass(veh) >= 0 and GetVehicleClass(veh) < 13 or GetVehicleClass(veh) > 17 then
				else
					curAlpha = 0
				end
			else
				RPM, degree = 0, 0
			end
			DrawSprite("speedometer", curSpeedometer, 0.800,0.860,0.12,0.185, 0.0, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curTachometer, 0.920,0.860,0.12,0.185, 0.0, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curNeedle, 0.800,0.862,0.076,0.15,-5.00001+degree, 255, 255, 255, curAlpha)
			DrawSprite("speedometer", curNeedle, 0.920,0.862,0.076,0.15,RPM*280-30, 255, 255, 255, curAlpha)
		end
	end
end)
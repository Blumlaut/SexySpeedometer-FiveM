

local skinData = {
	-- names
	skinName = "default", -- the name that is display ingame/in sexyspeedo, make sure its lowercase+no spaces
	ytdName = "default", -- the name of the texture dictionary
	--[[ 
	texture dictionary informations:
	night textures are supposed to look like this:
	"needle", "tachometer", "speedometer", "fuelgauge"
	daytime textures this:
	"needle_day", "tachometer_day", "speedometer_day", "fuelgauge_day"
	further textures:
	
	BeamLight
	BlinkerLight
	FuelLight
	OilLight
	EngineLight
	FuelNeedle
	SpeedometerBG
	TachometerBG
	--]]

	-- where the speedo gets centered, values below are OFFSETS from this.
	centerCoords = {0.8,0.8},


	-- icon locations
	-- these are xy,width,height
	lightsLoc = {0.010,0.092,0.018,0.02},
	blinkerLoc = {0.105,0.034,0.022,0.03},
	fuelLoc = {0.105,0.090,0.012,0.025},
	oilLoc = {0.100,0.062,0.020,0.025},
	engineLoc = {0.130,0.092,0.020,0.025},

	-- gauge locations
	SpeedoBGLoc = {0.000,0.060,0.12,0.185},
	SpeedoNeedleLoc = {0.000,0.062,0.076,0.15},

	TachoBGloc = {0.120,0.060,0.12,0.185},
	TachoNeedleLoc = {0.120,0.062,0.076,0.15},

	enableGear = false, -- REQUIRES "gear_1"-9 textures!!
	enableDigits = false, -- REQUIRES "speed_digits_1"-9 textures!!
	
	Speed1Loc = {0.090,-0.020,0.022,0.05}, -- 3rd digit
	Speed2Loc = {0.106,-0.020,0.022,0.05}, -- 2nd digit
	Speed3Loc = {0.126,-0.020,0.022,0.05}, -- 1st digit

	GearLoc = {0.010,-0.033,0.025,0.055}, -- gear location

	ShowFuel = true,
	FuelBGLoc = {0.060, -0.020,0.04, 0.04},
	FuelGaugeLoc = {0.060,0.000,0.040,0.08},

	-- here is where it gets complicated, this is the Rotation "Multiplier" and "Step"
	RotMult = 2.036936, -- unused currently.
	RotStep = 2.32833, -- step is calculated like the following: Speed Rotation Degree=(GetEntitySpeed(veh)*2.036936)*RotStep

	-- rpm scale, defines how "far" the rpm gauge goes before hitting redline
	rpmScale = 270, -- scale defines how far the needle goes
	rpmScaleDecrease = 30, -- how much we want to decrease the rpm end result, this gives lower idle, make sure to adjust scale accordingly.

}

addSkin(skinData)

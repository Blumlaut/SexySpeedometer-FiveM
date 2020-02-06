fx_version 'adamant'

game 'gta5'

client_scripts {
	"client.lua",

	-- add skins here
	"skins/default.lua",
	"skins/default_middle.lua",
	"skins/id5.lua",
	"skins/id6.lua",
	"skins/id7.lua",
}

exports {
	"getAvailableSkins",
	"changeSkin",
	"addSkin",
	"toggleSpeedo",
	"getCurrentSkin",
	"addSkin",
	"toggleFuelGauge",
	"DoesSkinExist",
	"SetOverriddenTexture",
}

ui_page('skins/initiald.html')
files({
    'skins/initiald.html',
    'skins/initiald.ogg'
})

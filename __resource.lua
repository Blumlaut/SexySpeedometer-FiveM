resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
	"client.lua",

	-- add skins here
	"skins/default.lua",
	"skins/default_middle.lua",
	"skins/id4.lua",
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
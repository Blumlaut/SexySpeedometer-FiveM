resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
	"client.lua",

	-- DONT ADD SKINS HERE, *.lua MEANS ALL .LUA FILES!!!
	"skins/*.lua",


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

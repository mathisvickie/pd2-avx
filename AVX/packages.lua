
if Global.load_level then
	
	local Packages = {
		"levels/narratives/bain/cage/world/world",
		"levels/narratives/vlad/shout/world/world",
		"levels/narratives/vlad/jolly/world/world",
		"levels/narratives/pbr/jerry/world/world",
		"levels/instances/unique/born/born_truck/world/world",
		"levels/narratives/elephant/born/world/world",
		"levels/narratives/butcher/thebomb/stage_3/world/world"
	}
	
	for i=1, #Packages do
		if not PackageManager:loaded(Packages[i]) then PackageManager:load(Packages[i]) end
	end
end

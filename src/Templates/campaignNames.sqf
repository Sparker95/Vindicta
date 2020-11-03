// This gives a better world name, standard worldName is quite technical
private _worldName = getText (configfile >> "CfgWorlds" >> worldName >> "description");

selectRandom
[
	format ["Revolution of %1", _worldName],
	format ["Revolt of %1", _worldName],
	format ["The %1 conflict", _worldName],
	format ["Vindication of %1", _worldName],
	format ["Rebellion of %1", _worldName],
	format ["Riot of %1", _worldName]
]
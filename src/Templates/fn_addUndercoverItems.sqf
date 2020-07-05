private _undercoverItems = _this#T_UC;
if(isNil "_undercoverItems") exitWith {};

private _umArrays = [
	"g_UM_civUniforms",
	"g_UM_civHeadgear",
	"g_UM_civVests",
	"g_UM_civFacewear",
	"g_UM_civBackpacks",
	"g_UM_ghillies",
	"g_UM_civItems",
	"g_UM_civWeapons",
	"g_UM_suspWeapons",
	"g_UM_civVehs"
];

{
	if(!isNil "_x") then {
		private _umName = _umArrays#_forEachIndex;
		private _umItems = missionNamespace getVariable _umName;
		_umItems append _x;
		publicVariable _umName;
	};
} forEach _undercoverItems;

#include "..\common.h"
#include "..\Group\Group.hpp"

// Create some vehicle groups
private _n = 3;
private _i = 0;
private _group = NEW("Group", [WEST ARG GROUP_TYPE_VEH]);
diag_log format ["Created group: %1", _group];
while{(_i < _n)} do {

	private _template = tNATO;
	private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_IFV ARG -1 ARG _group]);
	diag_log format ["Created unit: %1", _newUnit];
	// Create crew for the vehicle
	//CALLM(_newUnit, "createDefaultCrew", [_template]);

	_i = _i + 1;
};

// Spawn the group
_i = 0;
private _posAndDirArray = [];
while {_i < _n} do {
	_posAndDirArray pushBack [getPosATL player, getdir player];
	_i = _i + 1;
};
isNil {
CALLM2(_group, "spawnVehiclesOnRoad", _posAndDirArray, []);

};
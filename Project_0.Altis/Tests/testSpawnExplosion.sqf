#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

// Create some vehicle groups
private _i = 0;
private _groups = [];
while{(_i < 3)} do {
	private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG T_VEH_APC ARG -1]);

	private _newGroup = NEW("Group", [WEST ARG GROUP_TYPE_VEH_NON_STATIC]);
	private _template = tNATO;
	private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_IFV ARG -1 ARG _newGroup]);
	// Create crew for the vehicle
	CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
	_groups pushBack _newGroup;
	_i = _i + 1;
};
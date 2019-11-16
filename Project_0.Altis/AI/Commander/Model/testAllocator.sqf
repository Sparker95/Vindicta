#define pr private
private _effExt = +T_EFF_null;		// "External" requirement we must satisfy during this allocation

// Fill in units which we must destroy
_effExt set [T_EFF_soft, 10];
_effExt set [T_EFF_medium, 3];
_effExt set [T_EFF_armor, 5];
//_effExt set [T_EFF_air, 2];

private _validationFlags = [0, 1, 2, 3];
private _effPayloadWhitelist = [	T_EFF_ground_mask,		// Take any ground units
							T_EFF_infantry_mask];	// Take any infantry units
private _effPayloadBlacklist = [];
private _effTransportWhitelist = [[[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks, // Take any units which are BOTH ground and can provide transport
								T_EFF_infantry_mask];												// Take any infantry to satisfy crew requirements
private _effTransportBlacklist = [];
private _unitBlacklist = [T_static];	// Do not take static weapons
private _comp = [5] call comp_fnc_new;
private _effOur = [_comp] call comp_fnc_getEfficiency;
private _args = ["GarrisonModel", _effExt, _validationFlags, _comp, _effOur,
	_effPayloadWhitelist,_effPayloadBlacklist,
	_effTransportWhitelist, _effTransportBlacklist,
	_unitBlacklist];
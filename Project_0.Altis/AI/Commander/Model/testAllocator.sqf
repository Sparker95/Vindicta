#define pr private
pr _effExt = +T_EFF_null;		// "External" requirement we must satisfy during this allocation

// Fill in units which we must destroy
_effExt set [T_EFF_soft, 10];
_effExt set [T_EFF_medium, 3];
_effExt set [T_EFF_armor, 5];
//_effExt set [T_EFF_air, 2];

pr _validationFnNames = ["eff_fnc_validateAttack", "eff_fnc_validateTransport", "eff_fnc_validateCrew"]; // "eff_fnc_validateDefense"
pr _effPayloadWhitelist = [	T_EFF_ground_mask,		// Take any ground units
							T_EFF_infantry_mask];	// Take any infantry units
pr _effPayloadBlacklist = [];
pr _effTransportWhitelist = [[[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks, // Take any units which are BOTH ground and can provide transport
								T_EFF_infantry_mask];												// Take any infantry to satisfy crew requirements
pr _effTransportBlacklist = [];
pr _unitBlacklist = [T_static];	// Do not take static weapons

["Noclass", _effExt, _validationFnNames, _comp,
	_effPayloadWhitelist,_effPayloadBlacklist,
	_effTransportWhitelist, _effTransportBlacklist,
	_unitBlacklist] call fnc_allocateUnits;
#include "common.hpp"

#define OOP_CLASS_NAME GameModeRandom
CLASS("GameModeRandom", "GameModeBase")

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "Random mode by Sparker");
		T_SETV("spawningEnabled", false);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;
		
	protected override METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		if(_type in [LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST]) then {
			if ((random 10) < 3) then {
				INDEPENDENT
			} else {
				CIVILIAN
			};
		} else {
			if (_type == LOCATION_TYPE_POLICE_STATION) then {
				if ((random 10) < 3) then {
					INDEPENDENT
				} else {
					CIVILIAN
				};
			} else {
				CIVILIAN
			};
		}
	ENDMETHOD;
ENDCLASS;

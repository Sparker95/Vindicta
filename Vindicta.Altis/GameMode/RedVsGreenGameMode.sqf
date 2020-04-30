#include "common.hpp"

#define OOP_CLASS_NAME RedVsGreenGameMode
CLASS("RedVsGreenGameMode", "GameModeBase")
	VARIABLE("linePt");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "expand");
		T_SETV("spawningEnabled", true);
		
		private _linePt = [
			random 30000, random 30000
		];
		T_SETV("linePt", _linePt);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		
		private _type = GETV(_loc, "type");

		if(_type == LOCATION_TYPE_BASE or _type == LOCATION_TYPE_OUTPOST or _type == LOCATION_TYPE_POLICE_STATION) then {
			private _linePt = T_GETV("linePt");
			private _locPos = CALLM0(_loc, "getPos");
			if(((_linePt#0 - 15000) * (_locPos#1 - 15000) - (_linePt#1 - 15000) * (_locPos#0 - 15000)) < 0) then {
				east
			} else {
				independent
			}
		} else {
		 	civilian
		}

		// if(GETV(_loc, "type") == LOCATION_TYPE_BASE) then {
		// 	GETV(_loc, "side") 
		// } else {
		// 	civilian
		// }
	ENDMETHOD;
ENDCLASS;

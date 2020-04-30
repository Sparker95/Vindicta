#include "common.hpp"

#define OOP_CLASS_NAME EmptyGameMode
CLASS("EmptyGameMode", "GameModeBase")

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "empty");
		T_SETV("spawningEnabled", false);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;
		
	/* protected virtual */ METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		CIVILIAN
	ENDMETHOD;
ENDCLASS;

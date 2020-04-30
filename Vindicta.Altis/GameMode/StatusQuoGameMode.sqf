#include "common.hpp"

#define OOP_CLASS_NAME StatusQuoGameMode
CLASS("StatusQuoGameMode", "GameModeBase")

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "status-quo");
		T_SETV("spawningEnabled", true);

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;
ENDCLASS;

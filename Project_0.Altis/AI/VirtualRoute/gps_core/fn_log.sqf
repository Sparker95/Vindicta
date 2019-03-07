#include "macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : 22/10/17
	@Modified : 23/10/17
	@Description : Log function of GPS , diag_log anything to RPT with file name
	@Return : Nothing
**/
params ["_anything"];

diag_log format	["GPS Core (%2): %1",
	_anything,
	if(isNil "_thisFile") then {
		"Unknown file"
	}else{
		_thisFile
	}
];
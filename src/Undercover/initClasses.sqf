#include "..\common.h"

CALL_COMPILE_COMMON("Templates\Undercover\CivObjects.sqf");
fnc_getVisibleSurface = COMPILE_COMMON("Undercover\fn_getVisibleSurface.sqf");
fnc_UM_testCompromise = COMPILE_COMMON("Undercover\fn_UM_testCompromise.sqf");
fnc_UM_setState = COMPILE_COMMON("Undercover\fn_UM_setState.sqf");
fnc_UM_addActionUntieLocal = COMPILE_COMMON("Undercover\fn_UM_addActionUntieLocal.sqf");
CALL_COMPILE_COMMON("Undercover\UndercoverMonitor.sqf");


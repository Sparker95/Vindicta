#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\StimulusTypes.hpp"
#include "Unit.hpp"

/*
Executed in unscheduled when a unit respawns.
*/

params ["_unit", "_corpse"];

// make it possible to ace interact with the unit again
[objNull, _corpse] call ace_common_fnc_claim;

CALLM2(gMessageLoopMainManager, "postMethodAsync", "EH_Respawn", _this);
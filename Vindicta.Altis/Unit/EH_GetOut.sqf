#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"

/*
Executed in unscheduled when someone enters a vehicle.
*/

#define pr private

CALLM2(gMessageLoopMainManager, "postMethodAsync", "EH_GetOut", _this);
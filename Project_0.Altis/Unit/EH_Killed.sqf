#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\StimulusTypes.hpp"
#include "Unit.hpp"

/*
Executed in unscheduled when a unit is destroyed.
*/

#define pr private

CALLM2(gMessageLoopMainManager, "postMethodAsync", "EH_Killed", _this);
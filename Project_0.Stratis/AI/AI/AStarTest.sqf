#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\goalRelevance.hpp"
#include "AI.hpp"
#include "..\Garrison\garrisonWorldStateProperties.hpp"

/*
A script to test how AStar works
Author: Sparker 08.12.2018
*/

#define pr private

pr _actions = ["ActionGarrisonMountCrew",
						"ActionGarrisonMountInfantry",
						"ActionGarrisonMoveMounted",
						"ActionGarrisonMoveDismounted",
						"ActionGarrisonRepairAllVehicles"];

// Fill world states						
pr _wsCurrent = [WSP_GAR_COUNT] call ws_new;
[_wsCurrent, WSP_GAR_ALL_CREW_MOUNTED, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_INFANTRY_MOUNTED, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_POSITION, getPos player] call ws_setPropertyValue;

pr _wsGoal = [WSP_GAR_COUNT] call ws_new;
[_wsGoal, WSP_GAR_POSITION, [6, 6, 6]] call ws_setPropertyValue;

// Run A*
pr _args = [_wsCurrent, _wsGoal, _actions];
CALL_STATIC_METHOD("AI", "AStar", _args);
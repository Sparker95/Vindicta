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
						"ActionGarrisonMoveMountedCargo",
						"ActionGarrisonMoveDismounted",
						"ActionGarrisonRepairAllVehicles",
						"ActionGarrisonLoadCargo",
						"ActionGarrisonUnloadCurrentCargo"];

/*

// Goal: move somewhere

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

*/

// Goal: transport cargo
// Fill world states
pr _wsCurrent = [WSP_GAR_COUNT] call ws_new;
[_wsCurrent, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_INFANTRY_MOUNTED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_POSITION, getPos player] call ws_setPropertyValue;

/*
pr _wsGoal = [WSP_GAR_COUNT] call ws_new;
[_wsGoal, WSP_GAR_CARGO_POSITION, [6, 6, 6]] call ws_setPropertyValue;
[_wsGoal, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;
*/

pr _args = ["", [ ["g_pos", [6, 6, 6]] ]];
pr _wsGoal = CALLSM("GoalGarrisonMove", "getEffects", _args);

// Run A*
//["_thisClass", "", [""]], ["_currentWS", [], [[]]], ["_goalWS", [], [[]]], ["_possibleActions", [], [[]]], ["_goalParameters", [], [[]]], ["_AI", "ASTAR_ERROR_NO_AI"]
pr _args = [_wsCurrent, _wsGoal, _actions, [["cargo", "thisBox"]]];
CALL_STATIC_METHOD("AI", "planActions", _args);
#include "..\goalRelevance.hpp"

//private _s = WSP_GAR_COUNT;

/*
Initializes costs, effects and preconditions of actions, relevance values of goals.
*/



// ---- Goal relevance values and effects ----
// The actual relevance returned by goal can be different from the one which is set below

["GoalUnitGetInVehicle",			10] call AI_misc_fnc_setGoalIntrinsicRelevance;
//["GoalUnitArrest",					15] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMove",			20] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryRegroup", 		25] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitFollowLeaderVehicle", 	30] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitMoveLeaderVehicle", 		31] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitRepairVehicle",			35] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitSurrender",				40] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitDismountCurrentVehicle",	50] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitFlee",					100] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitNothing",					1] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitVehicleUnflip",			10] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---- Goal effects ----
// The actual effects returned by goal can depend on context and differ from those set below





// ---- Predefined actions of goals ----

["GoalUnitGetInVehicle", "ActionUnitGetInVehicle"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitInfantryMove", "ActionUnitInfantryMove"] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitArrest", "ActionUnitArrest"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitFollowLeaderVehicle", "ActionUnitFollowLeaderVehicle"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitMoveLeaderVehicle", "ActionUnitMoveLeaderVehicle"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitDismountCurrentVehicle", "ActionUnitDismountCurrentVehicle"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitVehicleUnflip", "ActionUnitVehicleUnflip"] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitFlee", "ActionUnitFlee"] call AI_misc_fnc_setGoalPredefinedAction;

["GoalUnitNothing", "ActionUnitNothing"] call AI_misc_fnc_setGoalPredefinedAction;



// ---- Action preconditions and effects ----





// ---- Action costs ----

#include "..\goalRelevance.hpp"

//private _s = WSP_GAR_COUNT;

/*
Initializes costs, effects and preconditions of actions, relevance values of goals.
*/



// ---- Goal relevance values and effects ----
// The actual relevance returned by goal can be different from the one which is set below

["GoalUnitGetInVehicle",	10] call AI_misc_fnc_setGoalIntrinsicRelevance;


// ---- Goal effects ----
// The actual effects returned by goal can depend on context and differ from those set below





// ---- Predefined actions of goals ----

["GoalUnitGetInVehicle", "ActionUnitGetInVehicle"] call AI_misc_fnc_setGoalPredefinedAction;




// ---- Action preconditions and effects ----





// ---- Action costs ----

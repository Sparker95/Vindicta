#include "garrisonWorldStateProperties.hpp"

private _s = WSP_GAR_COUNT;

/*
Initializes costs, effects and preconditions of actions, relevance values of goals.
*/

// ---- Goal relevance values and effects ----
// The actual relevance returned by goal can be different from the one which is set below

["GoalGarrisonRelax",				123] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonMove",				123] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonRepairAllVehicles",	123] call AI_misc_fnc_setGoalIntrinsicRelevance;


// ---- Goal effects ----
// The actual effects returned by goal can depend on context and differ from those set below

["GoalGarrisonRelax", _s,				[]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonMove", _s,				[]] call AI_misc_fnc_setGoalEffects; // Move goal returns effects that depend on parameter

["GoalGarrisonRepairAllVehicles", _s, [	[WSP_GAR_ALL_VEHICLES_REPAIRED, true],
										[WSP_GAR_ALL_VEHICLES_CAN_MOVE, true]]] call AI_misc_fnc_setGoalEffects;


// ---- Predefined actions of goals ----

["GoalGarrisonRelax", "ActionGarrisonRelax"] call AI_misc_fnc_setGoalPredefinedAction;


// ---- Action preconditions and effects ----

// Repair all vehicles
["ActionGarrisonRepairAllVehicles",	_s, [	[WSP_GAR_ENGINEER_AVAILABLE,	true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRepairAllVehicles",	_s,	[	[WSP_GAR_ALL_VEHICLES_REPAIRED,	true],
											[WSP_GAR_ALL_VEHICLES_CAN_MOVE,	true]]] call AI_misc_fnc_setActionEffects;
										
// Mount crew
["ActionGarrisonMountCrew",	_s,			[]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountCrew",	_s,			[	[WSP_GAR_ALL_CREW_MOUNTED,		true]]] call AI_misc_fnc_setActionEffects;

// Mount infantry
["ActionGarrisonMountInfantry",	_s,		[]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountInfantry",	_s,		[	[WSP_GAR_ALL_INFANTRY_MOUNTED,	true]]] call AI_misc_fnc_setActionEffects;

// Move mounted
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_POSITION,	0,	true]]] 		call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action

// Move dismounted
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_ALL_CREW_MOUNTED,		false],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	false]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_POSITION,	0,	true]]]			call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action


// ---- Action costs ----
["ActionGarrisonMountCrew",				1] call AI_misc_fnc_setActionCost;
["ActionGarrisonMountInfantry",			1] call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMounted",		2] call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveDismounted",	5] call AI_misc_fnc_setActionCost;
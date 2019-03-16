#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"
#include "..\parameterTags.hpp"

private _s = WSP_GAR_COUNT;

/*
Initializes costs, effects and preconditions of actions, relevance values of goals.
*/

// ---- Goal relevance values and effects ----
// The actual relevance returned by goal can be different from the one which is set below

["GoalGarrisonSurrender",				60] call AI_misc_fnc_setGoalIntrinsicRelevance; // Only runs when not in combat

["GoalGarrisonRepairAllVehicles",		50] call AI_misc_fnc_setGoalIntrinsicRelevance; // Only runs when not in combat

["GoalGarrisonAttackAssignedTargets", 	36] call AI_misc_fnc_setGoalIntrinsicRelevance; // Gets activated when garrison can see any of the assigned targets

["GoalGarrisonDefendPassive",			34] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonClearArea",				32] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonRebalanceVehicleGroups",	25] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonJoinLocation",			12] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonRelax",					1] call AI_misc_fnc_setGoalIntrinsicRelevance;

//["GoalGarrisonJoinLocation",			30] call AI_misc_fnc_setGoalIntrinsicRelevance;




// ---- Goal effects ----
// The actual effects returned by goal can depend on context and differ from those set below

["GoalGarrisonRelax", _s,				[]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonMove", _s,			[	[WSP_GAR_POSITION, TAG_G_POS, true]]] call AI_misc_fnc_setGoalEffects;
//["GoalGarrisonMove", _s,				[[WSP_GAR_ALL_CREW_MOUNTED, true]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonRepairAllVehicles", _s, [	[WSP_GAR_ALL_VEHICLES_REPAIRED, true],
										[WSP_GAR_ALL_VEHICLES_CAN_MOVE, true]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonMoveCargo", _s,			[[WSP_GAR_CARGO_POSITION, TAG_CARGO_POS, true],
										[WSP_GAR_HAS_CARGO, false]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonDefendPassive", _s,		[[WSP_GAR_AWARE_OF_ENEMY, false]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonAttackAssignedTargets", _s, [[]]] call AI_misc_fnc_setGoalEffects; // Effects are procedural

["GoalGarrisonClearArea", _s,			[	[WSP_GAR_CLEARING_AREA, TAG_G_POS, true],
											[WSP_GAR_POSITION, TAG_G_POS, true]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonJoinLocation", _s,		[[WSP_GAR_LOCATION, TAG_LOCATION, true]]] call AI_misc_fnc_setGoalEffects;


// ---- Predefined actions of goals ----

["GoalGarrisonRelax", "ActionGarrisonRelax"] call AI_misc_fnc_setGoalPredefinedAction;

["GoalGarrisonRepairAllVehicles", "ActionGarrisonRepairAllVehicles"] call AI_misc_fnc_setGoalPredefinedAction;

["GoalGarrisonRebalanceVehicleGroups", "ActionGarrisonRebalanceVehicleGroups"] call AI_misc_fnc_setGoalPredefinedAction;

["GoalGarrisonSurrender", "ActionGarrisonSurrender"] call AI_misc_fnc_setGoalPredefinedAction;


// ---- Action preconditions and effects ----

// Repair all vehicles
["ActionGarrisonRepairAllVehicles",	_s, [	]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRepairAllVehicles",	_s,	[	[WSP_GAR_ALL_VEHICLES_REPAIRED,	true],
											[WSP_GAR_ALL_VEHICLES_CAN_MOVE,	true]]] call AI_misc_fnc_setActionEffects;

// Mount crew
["ActionGarrisonMountCrew",	_s,			[	[WSP_GAR_VEHICLE_GROUPS_MERGED, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountCrew",	_s,			[	[WSP_GAR_ALL_CREW_MOUNTED,		TAG_MOUNT, true]]] call AI_misc_fnc_setActionEffects;

// Mount infantry
["ActionGarrisonMountInfantry",	_s,		[]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountInfantry",	_s,		[	[WSP_GAR_ALL_INFANTRY_MOUNTED,	true]]] call AI_misc_fnc_setActionEffects;

// Mount crew and infantry
["ActionGarrisonMountCrewInfantry",	_s,		[ [WSP_GAR_VEHICLE_GROUPS_MERGED, true] ]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountCrewInfantry",	_s,		[	[WSP_GAR_ALL_INFANTRY_MOUNTED,	true],
												[WSP_GAR_ALL_CREW_MOUNTED,		true]]] call AI_misc_fnc_setActionEffects;



// Move mounted to position
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	true],
											[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS,	true],
											[WSP_GAR_VEHICLE_GROUPS_BALANCED, true],
											[WSP_GAR_HAS_VEHICLES, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_POSITION,	TAG_POS,	true],
													[WSP_GAR_VEHICLES_POSITION,	TAG_POS,	true]]] call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action
["ActionGarrisonMoveMounted", 			[TAG_MOVE_RADIUS]] call AI_misc_fnc_setActionParametersFromGoal;

// Move mounted to location
/*
["ActionGarrisonMoveMountedToLocation", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
													[WSP_GAR_ALL_INFANTRY_MOUNTED,	true],
													[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS,	true],
													[WSP_GAR_VEHICLE_GROUPS_BALANCED, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMountedToLocation", _s,		[	[WSP_GAR_POSITION,	TAG_POS,	true],
													[WSP_GAR_VEHICLES_POSITION,	TAG_POS,	true]]] call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action
// ["ActionGarrisonMoveMountedToLocation", 			[TAG_RADIUS]] call AI_misc_fnc_setActionParametersFromGoal; // This one is smart and gets radius from location
*/

// Move mounted cargo
["ActionGarrisonMoveMountedCargo", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
												[WSP_GAR_ALL_INFANTRY_MOUNTED,	true],
												[WSP_GAR_HAS_CARGO,				true]]] 		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMountedCargo", _s,		[	[WSP_GAR_POSITION,	TAG_POS,	true],
												[WSP_GAR_CARGO_POSITION,	TAG_POS,	true],
												[WSP_GAR_VEHICLES_POSITION,	TAG_POS,	true]]] 		call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action


// Move dismounted
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_ALL_CREW_MOUNTED,		false],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	false]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_POSITION,	TAG_POS,	true]]]			call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action

// Load cargo
["ActionGarrisonLoadCargo", _s,			[	[WSP_GAR_HAS_CARGO,	false],
											[WSP_GAR_VEHICLES_POSITION, [1, 1, 1]]]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonLoadCargo", _s,			[	[WSP_GAR_HAS_CARGO, true]]]		call AI_misc_fnc_setActionEffects;
["ActionGarrisonLoadCargo", 			[TAG_CARGO]] call AI_misc_fnc_setActionParametersFromGoal;

// Unload cargo
["ActionGarrisonUnloadCurrentCargo", _s,	[	[WSP_GAR_HAS_CARGO,	true]]]		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonUnloadCurrentCargo", _s,	[	[WSP_GAR_HAS_CARGO,	false]]]	call AI_misc_fnc_setActionEffects;

// Defend passive
["ActionGarrisonDefendPassive", _s,	[	]]		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonDefendPassive", _s,	[	[WSP_GAR_AWARE_OF_ENEMY,	false]]]	call AI_misc_fnc_setActionEffects;

// Merging and splitting vehicle groups
["ActionGarrisonMergeVehicleGroups", _s, [ ]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMergeVehicleGroups", _s, [ [WSP_GAR_VEHICLE_GROUPS_MERGED, TAG_MERGE, true] ]] call AI_misc_fnc_setActionEffects;

// Rebalancing vehicle groups
["ActionGarrisonRebalanceVehicleGroups", _s, [ ]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRebalanceVehicleGroups", _s, [	[WSP_GAR_VEHICLE_GROUPS_BALANCED, true],
												[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] ]] call AI_misc_fnc_setActionEffects;

// Clear Area
["ActionGarrisonClearArea", _s,		[	]]		call AI_misc_fnc_setActionPreconditions; // These are procedural, just must set them anyway
["ActionGarrisonClearArea", _s,		[	[WSP_GAR_CLEARING_AREA,	TAG_POS, true]]]	call AI_misc_fnc_setActionEffects;
["ActionGarrisonClearArea", 			[TAG_CLEAR_RADIUS, TAG_DURATION]] call AI_misc_fnc_setActionParametersFromGoal;

// Join Location
["ActionGarrisonJoinLocation", _s, [ ]] call AI_misc_fnc_setActionPreconditions; // These are procedural
["ActionGarrisonJoinLocation", _s, [ [WSP_GAR_LOCATION, TAG_LOCATION, true] ]] call AI_misc_fnc_setActionEffects;

// ---- Action costs ----
#define C 1.0
["ActionGarrisonMountCrew",					C*0.4]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMountInfantry",				C*0.6]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMountCrewInfantry",			C*0.7]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMounted",				C*2.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMountedCargo",			C*3.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveDismounted",			C*8.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonLoadCargo",					C*2.0] 	call AI_misc_fnc_setActionCost;
["ActionGarrisonUnloadCurrentCargo", 		C*0.3]	call AI_misc_fnc_setActionCost;
["ActionGarrisonDefendPassive", 			C*1.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMergeVehicleGroups", 		C*0.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonRebalanceVehicleGroups", 	C*0.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonRepairAllVehicles", 		C*0.0]	call AI_misc_fnc_setActionCost;
["ActionGarrisonClearArea", 				C*0.1]	call AI_misc_fnc_setActionCost;
["ActionGarrisonJoinLocation", 				C*0.1]	call AI_misc_fnc_setActionCost;

// ---- Action precedence ----
["ActionGarrisonMountCrew",					5]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMountInfantry",				6]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMountCrewInfantry",			6]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveMounted",				20]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveMountedCargo",			20]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveDismounted",			20]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonLoadCargo",					10] call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonUnloadCurrentCargo", 		30]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonDefendPassive", 			20]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMergeVehicleGroups", 		1]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonRebalanceVehicleGroups", 	2]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonRepairAllVehicles", 		1]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonClearArea", 				40]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonJoinLocation", 				43] call AI_misc_fnc_setActionPrecedence;

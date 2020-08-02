#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"
#include "..\parameterTags.hpp"



private _s = WSP_GAR_COUNT;

// Initializes costs, effects and preconditions of actions, relevance values of goals.

// ---------------- Goal relevance values and effects
// The actual relevance returned by goal can be different from the one which is set below
["GoalGarrisonSurrender",					60	] call AI_misc_fnc_setGoalIntrinsicRelevance; // Only runs when not in combat
["GoalGarrisonRepairAllVehicles",			50	] call AI_misc_fnc_setGoalIntrinsicRelevance; // Only runs when not in combat
["GoalGarrisonAttackAssignedTargets", 		36	] call AI_misc_fnc_setGoalIntrinsicRelevance; // Gets activated when garrison can see any of the assigned targets
["GoalGarrisonRebalanceVehicleGroups",		35	] call AI_misc_fnc_setGoalIntrinsicRelevance; // Needs to be higher than defend actions
["GoalGarrisonDefendActive",				34	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonClearArea",					32	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonJoinLocation",				12	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonMove",						11	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonDefendPassive",				 5	] call AI_misc_fnc_setGoalIntrinsicRelevance; // Higher than relax
["GoalGarrisonAirRtB",						 3	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonLand",						 2	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGarrisonRelax",						 1	] call AI_misc_fnc_setGoalIntrinsicRelevance;

//["GoalGarrisonJoinLocation",				30	] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---------------- Goal effects
// The actual effects returned by goal can depend on context and differ from those set below
["GoalGarrisonRelax", _s,					[]]	call AI_misc_fnc_setGoalEffects;
// Parameters: TAG_G_POS, TAG_MOVE_RADIUS
["GoalGarrisonMove", _s,					[
											[WSP_GAR_AT_TARGET_POS, true]
											]]	call AI_misc_fnc_setGoalEffects;
//["GoalGarrisonMove", _s,					[[WSP_GAR_ALL_CREW_MOUNTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalGarrisonRepairAllVehicles", _s,		[
											[WSP_GAR_ALL_VEHICLES_REPAIRED, true],
											[WSP_GAR_ALL_VEHICLES_CAN_MOVE, true]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonDefendActive", _s,			[
											[WSP_GAR_AWARE_OF_ENEMY, false]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonDefendPassive", _s,			[
											[WSP_GAR_AWARE_OF_ENEMY, false]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonClearArea", _s,				[
											[WSP_GAR_HAS_INTERACTED, true]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonAttackAssignedTargets", _s,	[
											[WSP_GAR_HAS_INTERACTED, true]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonJoinLocation", _s,			[
											[WSP_GAR_AT_TARGET_LOCATION, true]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonLand", _s,					[
											[WSP_GAR_ALL_LANDED, true]
											]]	call AI_misc_fnc_setGoalEffects;
["GoalGarrisonAirRtB", _s,					[
											]]	call AI_misc_fnc_setGoalEffects;


// ---------------- Predefined actions of goals
["GoalGarrisonRelax",						"ActionGarrisonRelax"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonDefendPassive",				"ActionGarrisonDefendPassive"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonDefendActive",				"ActionGarrisonDefendActive"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonRepairAllVehicles",			"ActionGarrisonRepairAllVehicles"		] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonRebalanceVehicleGroups",		"ActionGarrisonRebalanceGroups"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonSurrender",					"ActionGarrisonSurrender"				] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGarrisonLand",						"ActionGarrisonLand"					] call AI_misc_fnc_setGoalPredefinedAction;

// ---------------- Action preconditions and effects

// ---------------- ActionGarrisonRepairAllVehicles
["ActionGarrisonRepairAllVehicles",	_s,		[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRepairAllVehicles",	_s,		[
											[WSP_GAR_ALL_VEHICLES_REPAIRED,				true],
											[WSP_GAR_ALL_VEHICLES_CAN_MOVE,				true]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonMountCrew
["ActionGarrisonMountCrew",	_s,				[
											[WSP_GAR_GROUPS_BALANCED,					true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountCrew",	_s,				[
											[WSP_GAR_ALL_CREW_MOUNTED, TAG_MOUNT,		true]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonMountInfantry
["ActionGarrisonMountInfantry",	_s,			[
											[WSP_GAR_GROUPS_BALANCED,					true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountInfantry",	_s,			[
											[WSP_GAR_ALL_INFANTRY_MOUNTED, TAG_MOUNT,	true]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonMoveMounted
["ActionGarrisonMoveMounted", _s,			[
											[WSP_GAR_HAS_VEHICLES, 						true],
											[WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, 	true],
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				true],
											[WSP_GAR_GROUPS_BALANCED,					true],
											[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS,	true],
											[WSP_GAR_ALL_CREW_MOUNTED,					true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,				true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMounted", _s,			[
											[WSP_GAR_AT_TARGET_POS, true],
											[WSP_GAR_VEHICLES_AT_TARGET_POS, true]
											]]	call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action
["ActionGarrisonMoveMounted", 				[
											TAG_POS
											]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
// ---------------- ActionGarrisonMoveCombined
["ActionGarrisonMoveCombined", _s,			[
											[WSP_GAR_HAS_VEHICLES, 						true],
											[WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, 	false],
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				true],
											[WSP_GAR_GROUPS_BALANCED,					true],
											[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS,	true],
											[WSP_GAR_ALL_CREW_MOUNTED,					true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveCombined", _s,			[
											[WSP_GAR_AT_TARGET_POS, true],
											[WSP_GAR_VEHICLES_AT_TARGET_POS, true]
											]]	call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action
["ActionGarrisonMoveCombined", 				[
											TAG_POS
											]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionGarrisonMoveCombined", 				[TAG_MOVE_RADIUS]] call AI_misc_fnc_setActionParametersFromGoalOptional;
// ---------------- ActionGarrisonMoveDismounted
["ActionGarrisonMoveDismounted", _s,		[
											[WSP_GAR_GROUPS_BALANCED,					true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveDismounted", _s,		[
											[WSP_GAR_AT_TARGET_POS,						true]
											]]	call AI_misc_fnc_setActionEffects;
["ActionGarrisonMoveDismounted",			[
											TAG_POS
											]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionGarrisonMoveDismounted", 			[TAG_MOVE_RADIUS]] call AI_misc_fnc_setActionParametersFromGoalOptional;

// ---------------- ActionGarrisonMoveAir
["ActionGarrisonMoveAir", _s,				[
											[WSP_GAR_HAS_VEHICLES, 						true],
											[WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, 	true],
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				true],
											[WSP_GAR_GROUPS_BALANCED,					true],
											[WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS,	true],
											[WSP_GAR_ALL_CREW_MOUNTED,					true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,				true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveAir", _s,				[
											[WSP_GAR_AT_TARGET_POS, true],
											[WSP_GAR_VEHICLES_AT_TARGET_POS, true]
											]]	call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action
["ActionGarrisonMoveAir", 					[
											TAG_POS,
											TAG_MOVE_RADIUS
											]]	call AI_misc_fnc_setActionParametersFromGoalOptional;

// ---------------- ActionGarrisonDefend
["ActionGarrisonDefend", _s,				[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonDefend", _s, 				[
											[WSP_GAR_AWARE_OF_ENEMY,					false]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonMergeVehicleGroups
["ActionGarrisonMergeVehicleGroups", _s, 	[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMergeVehicleGroups", _s, 	[
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				true],
											[WSP_GAR_GROUPS_BALANCED,					false]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonSplitVehicleGroups
["ActionGarrisonSplitVehicleGroups", _s, 	[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonSplitVehicleGroups", _s, 	[
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				false],
											[WSP_GAR_GROUPS_BALANCED,					false]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonRebalanceGroups
["ActionGarrisonRebalanceGroups", _s,		[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRebalanceGroups", _s,		[
											[WSP_GAR_GROUPS_BALANCED,					true]
											]]	call AI_misc_fnc_setActionEffects;
// ---------------- ActionGarrisonClearArea
["ActionGarrisonClearArea", _s,				[
											[WSP_GAR_VEHICLE_GROUPS_MERGED,				false],
											// NOT required as clear area balances the groups itself
											// Also it will currently unbalance them to assign inf escort to vehicles which would 
											// cause replaning if this WSP was required.
											// TODO: introduce more refined group composition WSPs
											// [WSP_GAR_GROUPS_BALANCED, true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,				false],
											[WSP_GAR_ALL_CREW_MOUNTED,					true],
											[WSP_GAR_AT_TARGET_POS,						true]
											]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonClearArea", _s,				[
											[WSP_GAR_HAS_INTERACTED, 					true]
											]]	call AI_misc_fnc_setActionEffects;
["ActionGarrisonClearArea",					[
											TAG_POS_CLEAR_AREA
											]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionGarrisonClearArea",					[
											TAG_CLEAR_RADIUS,
											TAG_DURATION_SECONDS
											]]	call AI_misc_fnc_setActionParametersFromGoalOptional;										
// ---------------- ActionGarrisonJoinLocation
["ActionGarrisonJoinLocation", _s,			[[WSP_GAR_AT_TARGET_POS, 					true]]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonJoinLocation", _s,			[
											[WSP_GAR_AT_TARGET_LOCATION, 				true]
											]]	call AI_misc_fnc_setActionEffects;
["ActionGarrisonJoinLocation",				[TAG_LOCATION]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

// ---------------- ActionGarrisonLand
["ActionGarrisonLand", _s,					[]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonLand", _s,					[
											[WSP_GAR_ALL_LANDED, true]
											]]	call AI_misc_fnc_setActionEffects;

// ---------------- Action costs
#define C 1.0
["ActionGarrisonMountCrew",					C*0.4	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMountInfantry",				C*0.6	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveAir",					C*1.0	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMounted",				C*2.0	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveCombined",				C*4.5	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveDismounted",			C*6.0	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonDefendActive", 				C*1.0	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMergeVehicleGroups", 		C*0.4	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonSplitVehicleGroups", 		C*0.4	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonRebalanceGroups", 			C*0.4	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonRepairAllVehicles", 		C*0.4	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonClearArea", 				C*0.1	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonJoinLocation", 				C*0.1	]	call AI_misc_fnc_setActionCost;
["ActionGarrisonLand", 						C*1.0	]	call AI_misc_fnc_setActionCost;

// ---------------- Action precedence
// This is legacy, precedence is not used any more!
["ActionGarrisonMergeVehicleGroups", 		1		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonSplitVehicleGroups", 		1		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonRepairAllVehicles", 		1		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonRebalanceGroups", 			2		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMountCrew",					5		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMountInfantry",				6		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonLand", 						10		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveAir",					20		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveMounted",				20		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveCombined",				20		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonMoveDismounted",			20		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonDefend", 					20		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonClearArea", 				40		]	call AI_misc_fnc_setActionPrecedence;
["ActionGarrisonJoinLocation", 				43		]	call AI_misc_fnc_setActionPrecedence;

// ---------------- Action non-instant
["ActionGarrisonMoveAir"							]	call AI_misc_fnc_setActionNonInstant;
["ActionGarrisonMoveMounted"						]	call AI_misc_fnc_setActionNonInstant;
["ActionGarrisonMoveCombined"						]	call AI_misc_fnc_setActionNonInstant;
["ActionGarrisonMoveDismounted"						]	call AI_misc_fnc_setActionNonInstant;

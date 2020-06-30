#include "..\goalRelevance.hpp"

// Initializes costs, effects and preconditions of actions, relevance values of goals.

// ---------------- Goal relevance values and effects
// The actual relevance returned by goal can be different from the one which is set below
["GoalGroupFlee", 							200	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupSurrender",						150	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupAirMaintain",					100	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupClearArea",						80	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupOverwatchArea",					81	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupUnflipVehicles",					70	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupFollow",							62	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupMove",							60	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupOccupySentryPositions",			50	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupStayInVehicles",					40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupGetInGarrisonVehiclesAsCargo",	40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupGetInVehiclesAsCrew",			40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupGetInBuilding",					36	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupRegroup",						35	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupArrest",							32	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupEscort",							19	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupInvestigatePointOfInterest",		18	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupPatrol",							15	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupAirLand",						3	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupNothing",						2	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalGroupRelax",							1	] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---------------- Goal effects
// The actual effects returned by goal can depend on context and differ from those set below

// ---------------- Predefined actions of goals
["GoalGroupRelax",							"ActionGroupRelax"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupPatrol",							"ActionGroupPatrol"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupAirLand",						"ActionGroupAirLand"						] call AI_misc_fnc_setGoalPredefinedAction;
// For now maintainance just requires landing...
["GoalGroupAirMaintain",					"ActionGroupAirLand"						] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupArrest",							"ActionGroupArrest"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupRegroup",						"ActionGroupRegroup"						] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupStayInVehicles",					"ActionGroupStayInVehicles"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupGetInVehiclesAsCrew",			"ActionGroupGetInVehiclesAsCrew"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupGetInGarrisonVehiclesAsCargo",	"ActionGroupGetInGarrisonVehiclesAsCargo"	] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupOccupySentryPositions",			"ActionGroupOccupySentryPositions"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupGetInBuilding",					"ActionGroupGetInBuilding"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupUnflipVehicles",					"ActionGroupUnflipVehicles"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupMove",							"ActionGroupMove"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupFollow",							"ActionGroupFollow"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupSurrender",						"ActionGroupSurrender"						] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupflee",							"ActionGroupFlee"							] call AI_misc_fnc_setGoalPredefinedAction;
["GoalGroupNothing",						"ActionGroupNothing"						] call AI_misc_fnc_setGoalPredefinedAction;

// ---------------- Action preconditions and effects
// ["ActionGroupRelax",	_s,					[
// 											[WSP_GROUP_ALL_LANDED,						true]
// 											]]	call AI_misc_fnc_setActionPreconditions;
// ["ActionGroupAirLand",	_s,					[
// 											[WSP_GROUP_ALL_LANDED, 						false]
// 											]]	call AI_misc_fnc_setActionEffects;
// ---------------- Action costs

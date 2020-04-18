#include "..\goalRelevance.hpp"

//private _s = WSP_GAR_COUNT;

// Initializes costs, effects and preconditions of actions, relevance values of goals.

// ---------------- Goal relevance values and effects
// The actual relevance returned by goal can be different from the one which is set below
["GoalUnitFlee",							100	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitDismountCurrentVehicle",			50	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitSurrender",						40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitShootLegTarget",					40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitRepairVehicle",					35	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitMove",							31	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitFollow",							30	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryRegroup",					25	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMoveBuilding",			21	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMove",					20	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitGetInVehicle",					10	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitVehicleUnflip",					10	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitArrest",							5	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitShootAtTargetRange",				4	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitAmbientAnim",						3	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitIdle",							2	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitNothing",							1	] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---------------- Goal effects

// The actual effects returned by goal can depend on context and differ from those set below
// ---------------- Predefined actions of goals
["GoalUnitArrest",							"ActionUnitArrest"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitDismountCurrentVehicle",			"ActionUnitDismountCurrentVehicle"	] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitFlee",							"ActionUnitFlee"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitFollow",							"ActionUnitFollow"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitGetInVehicle",					"ActionUnitGetInVehicle"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitInfantryMove",					"ActionUnitInfantryMove"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitInfantryMoveBuilding",			"ActionUnitInfantryMoveBuilding"	] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitMove",							"ActionUnitMove"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitNothing",							"ActionUnitNothing"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitIdle",							"ActionUnitIdle"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitShootAtTargetRange",				"ActionUnitShootAtTargetRange"		] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitShootLegTarget",					"ActionUnitShootLegTarget"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitAmbientAnim",						"ActionUnitAmbientAnim"				] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitVehicleUnflip",					"ActionUnitVehicleUnflip"			] call AI_misc_fnc_setGoalPredefinedAction;

// ---------------- Action preconditions and effects
// ---------------- Action costs

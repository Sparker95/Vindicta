#include "..\goalRelevance.hpp"
#include "..\parameterTags.hpp"
#include "unitHumanWorldStateProperties.hpp"

private _s = WSP_UNIT_HUMAN_COUNT;

// Initializes costs, effects and preconditions of actions, relevance values of goals.

// ---------------- Goal relevance values and effects
// The actual relevance returned by goal can be different from the one which is set below
["GoalUnitFlee",							100	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianPanicAway",					65	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianPanicNearest",				60	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitDismountCurrentVehicle",			50	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitSurrender",						40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitShootLegTarget",					40	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitRepairVehicle",					35	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitMove",							31	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitFollow",							30	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryRegroup",					25	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMoveBuilding",			21	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMove",					20	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitScareWay",						19  ] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitGetInVehicle",					10	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitVehicleUnflip",					10	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitArrest",							5	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitShootAtTargetRange",				4	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitDialogue",						3.5 ] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitAmbientAnim",						3	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianWander",						2.5	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitIdle",							2	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitNothing",							1	] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---------------- Goal effects



// ---------------- Actions

// ------------------- ActionUnitDismountCurrentVehicle
["ActionUnitDismountCurrentVehicle", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitDismountCurrentVehicle", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
										[WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, false],
										[WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, false]]] call AI_misc_fnc_setActionEffects;

// ------------------- ActionUnitGetInVehicle
["ActionUnitGetInVehicle",_s,  [[WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true],
								[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitGetInVehicle",_s,  [
							[WSP_UNIT_HUMAN_AT_VEHICLE, true],
							[WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, true],
							[WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, true]
							]] call AI_misc_fnc_setActionEffects;
["ActionUnitGetInVehicle", [TAG_TARGET_UNIT, TAG_VEHICLE_ROLE]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitFlee
["ActionUnitFlee",_s,  [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
					[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitFlee",_s,  [[WSP_UNIT_HUMAN_IN_DANGER, false]]] call AI_misc_fnc_setActionEffects;
["ActionUnitFlee", [TAG_G_POS]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitFollow
["ActionUnitFollow",_s,  [
						[WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false],
						[WSP_UNIT_HUMAN_AT_VEHICLE, true]
						]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitFollow",_s,  [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionEffects;
["ActionunitFollow", [TAG_TARGET_OBJECT]] call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitIdle
["ActionUnitIdle", _s, []] call AI_misc_fnc_setActionPreconditions;
["ActionUnitIdle", _s, []] call AI_misc_fnc_setActionEffects;

// ------------------- ActionUnitInfantryLeaveFormation
["ActionUnitInfantryLeaveFormation", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryLeaveFormation", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionEffects;

// ------------------- ActionUnitInfantryRegroup
["ActionUnitInfantryRegroup", _s, [
								[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false],
								[WSP_UNIT_HUMAN_AT_VEHICLE, false]
								]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryRegroup", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionEffects;


// MOVEMENT

// ------------------- ActionUnitMoveMounted
["ActionUnitMoveMounted", _s, [	[WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true],
							[WSP_UNIT_HUMAN_AT_VEHICLE, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitMoveMounted", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitMoveMounted", [TAG_POS, TAG_MOVE_RADIUS, TAG_ROUTE]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitInfantryMove
["ActionUnitInfantryMove", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryMove", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryMove", [TAG_POS, TAG_MOVE_RADIUS]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitInfantryMoveBuilding
["ActionUnitInfantryMoveBuilding", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryMoveBuilding", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryMoveBuilding", [TAG_TARGET_OBJECT, TAG_BUILDING_POS_ID]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitInfantryMoveToUnit
["ActionUnitInfantryMoveToUnit", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryMoveToUnit", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryMoveToUnit", [TAG_TARGET_UNIT]]	call AI_misc_fnc_setActionParametersFromGoal;

// ------------------- ActionUnitInfantryMoveToObject
["ActionUnitInfantryMoveToObject", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryMoveToObject", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryMoveToObject", [TAG_TARGET_OBJECT]]	call AI_misc_fnc_setActionParametersFromGoal;



// ------------------- ActionUnitNothing
["ActionUnitNothing", _s, []] call AI_misc_fnc_setActionPreconditions;
["ActionUnitNothing", _s, []] call AI_misc_fnc_setActionEffects;


// Interaction actions are arbitrated by parameter passed to them
["ActionUnitRepairVehicle", _s, [	[WSP_UNIT_HUMAN_AT_VEHICLE, false],
								[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
								[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitRepairVehicle", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitRepairVehicle", [TAG_TARGET_REPAIR]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitArrest", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
						[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitArrest", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitArrest", [TAG_TARGET_ARREST]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitSalute", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
						[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitSalute", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitSalute", [TAG_TARGET_SALUTE]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitScareAway", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
							[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
							[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitScareAway", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitScareAway", [TAG_TARGET_SCARE_AWAY]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitAmbientAnim", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
							[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
							[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitAmbientAnim", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitAmbientAnim", [TAG_TARGET_AMBIENT_ANIM, TAG_ANIM]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitShootAtTargetRange", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
									[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
									[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitShootAtTargetRange", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitShootAtTargetRange", [TAG_TARGET_SHOOT_RANGE]]	call AI_misc_fnc_setActionParametersFromGoal;

["ActionUnitShootLegTarget", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitShootLegTarget", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitShootAtTargetRange", [TAG_TARGET_SHOOT_LEG_TARGET]]	call AI_misc_fnc_setActionParametersFromGoal;

//["ActionUnitShootLegTarget", []] call AI_misc_fnc_setActionEffects;

//["ActionUnitSurrender", []] call AI_misc_fnc_setActionEffects;
//["ActionUnitVehicleUnflip", []] call AI_misc_fnc_setActionEffects;


// The actual effects returned by goal can depend on context and differ from those set below
// ---------------- Predefined actions of goals
//["GoalUnitArrest",							"ActionUnitArrest"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitDismountCurrentVehicle",			"ActionUnitDismountCurrentVehicle"	] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitFlee",							"ActionUnitFlee"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitFollow",							"ActionUnitFollow"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitGetInVehicle",					"ActionUnitGetInVehicle"			] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitInfantryMove",					"ActionUnitInfantryMove"			] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitInfantryMoveBuilding",			"ActionUnitInfantryMoveBuilding"	] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitMove",							"ActionUnitMove"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitNothing",							"ActionUnitNothing"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitIdle",							"ActionUnitIdle"					] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitShootAtTargetRange",				"ActionUnitShootAtTargetRange"		] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitShootLegTarget",					"ActionUnitShootLegTarget"			] call AI_misc_fnc_setGoalPredefinedAction;
//["GoalUnitAmbientAnim",						"ActionUnitAmbientAnim"				] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitVehicleUnflip",					"ActionUnitVehicleUnflip"			] call AI_misc_fnc_setGoalPredefinedAction;


// ---------------- Action costs


//["_ActionUnit", 0] call AI_misc_fnc_setActionCost;
//["_ActionUnitInfantryMoveBase", 		0] call AI_misc_fnc_setActionCost;
["ActionUnitArrest", 					0.1] call AI_misc_fnc_setActionCost;
["ActionUnitDismountCurrentVehicle", 	1] call AI_misc_fnc_setActionCost;
["ActionUnitFlee", 						1] call AI_misc_fnc_setActionCost;
["ActionUnitFollow", 					1] call AI_misc_fnc_setActionCost;
["ActionUnitGetInVehicle", 				0.1] call AI_misc_fnc_setActionCost;
["ActionUnitIdle", 						0.1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryMove", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryMoveBuilding", 		1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryMoveToUnit", 		1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryRegroup", 			0.1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryLeaveFormation",	0.1] call AI_misc_fnc_setActionCost;
["ActionUnitMove", 						1] call AI_misc_fnc_setActionCost;
["ActionUnitMoveMounted", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitNothing", 					1] call AI_misc_fnc_setActionCost;
["ActionUnitRepairVehicle", 			1] call AI_misc_fnc_setActionCost;
["ActionUnitSalute", 					1] call AI_misc_fnc_setActionCost;
["ActionUnitScareAway", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitAmbientAnim", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitShootAtTargetRange", 		1] call AI_misc_fnc_setActionCost;
["ActionUnitShootLegTarget", 			1] call AI_misc_fnc_setActionCost;
["ActionUnitSurrender", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitVehicleUnflip", 			0.1] call AI_misc_fnc_setActionCost;
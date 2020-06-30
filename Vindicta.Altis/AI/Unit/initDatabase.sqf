#include "..\goalRelevance.hpp"
#include "..\parameterTags.hpp"
#include "unitHumanWorldStateProperties.hpp"

private _s = WSP_UNIT_HUMAN_COUNT;

// Initializes costs, effects and preconditions of actions, relevance values of goals.

// ---------------- Goal relevance values and effects
// The actual relevance returned by goal can be different from the one which is set below
["GoalUnitArrested",						9000] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitFlee",							100	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryEscapeDangerSource",		70	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianPanicAway",					65	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianPanicNearest",				60	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitDismountCurrentVehicle",			50	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitGetInVehicle",					45	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitSurrender",						41	] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitDialogue",						40 ] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitShootLegTarget",					36	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitRepairVehicle",					35	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitMove",							31	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryMove",					30	] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitFollow",							30	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryRegroup",					25	] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitScareAway",						19  ] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitVehicleUnflip",					10	] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalUnitArrest",							5	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitShootAtTargetRange",				4	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitAmbientAnim",						3	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalCivilianWander",						2.5	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitInfantryStandIdle",				2.1	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitIdle",							2	] call AI_misc_fnc_setGoalIntrinsicRelevance;
["GoalUnitNothing",							1	] call AI_misc_fnc_setGoalIntrinsicRelevance;

// ---------------- Goal effects
["GoalUnitArrest", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitDismountCurrentVehicle", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitFlee", _s, [[WSP_UNIT_HUMAN_IN_DANGER, false]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitFollow", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitGetInVehicle", _s, [
	[WSP_UNIT_HUMAN_AT_VEHICLE, true],
	[WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitIdle", _s, []] call AI_misc_fnc_setGoalEffects;
["GoalUnitInfantryMove", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitInfantryRegroup", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true], [WSP_UNIT_HUMAN_AT_TARGET_POS, true] ]] call AI_misc_fnc_setGoalEffects;
["GoalUnitMove", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setGoalEffects;
//["GoalUnitNothing", _s, []] call AI_misc_fnc_setGoalEffects;
["GoalUnitRepairVehicle", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitSalute", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitScareAway", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitAmbientAnim", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitShootAtTargetRange", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitShootLegTarget", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
//["GoalUnitSurrender", _s, []] call AI_misc_fnc_setGoalEffects;
//["GoalUnitVehicleUnflip", _s, []] call AI_misc_fnc_setGoalEffects;
["GoalUnitInfantryStandIdle", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitDialogue", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setGoalEffects;

["GoalCivilianWander", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setGoalEffects;
["GoalCivilianPanicNearest", _s, [[WSP_UNIT_HUMAN_IN_DANGER, false]]] call AI_misc_fnc_setGoalEffects;
["GoalCivilianPanicAway", _s, [[WSP_UNIT_HUMAN_IN_DANGER, false]]] call AI_misc_fnc_setGoalEffects;
["GoalUnitInfantryEscapeDangerSource", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setGoalEffects;


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
["ActionUnitGetInVehicle", [TAG_TARGET_VEHICLE_UNIT, TAG_VEHICLE_ROLE]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitGetInVehicle", [TAG_TURRET_PATH]]	call AI_misc_fnc_setActionParametersFromGoalOptional;

// ------------------- ActionUnitFlee
["ActionUnitFlee",_s,  [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitFlee",_s,  [[WSP_UNIT_HUMAN_IN_DANGER, false]]] call AI_misc_fnc_setActionEffects;
["ActionUnitFlee", [TAG_MOVE_TARGET]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitFlee", [TAG_MOVE_RADIUS]]	call AI_misc_fnc_setActionParametersFromGoalOptional;

// ------------------- ActionUnitFollow
// Used only when in vehicle!
["ActionUnitFollow",_s,  [
						[WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false],
						[WSP_UNIT_HUMAN_AT_VEHICLE, true]
						]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitFollow", _s,  [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionEffects;
["ActionunitFollow", [TAG_TARGET_OBJECT]] call AI_misc_fnc_setActionParametersFromGoalOptional; // Optional!

// ------------------- ActionUnitIdle
["ActionUnitIdle", _s, []] call AI_misc_fnc_setActionPreconditions;
["ActionUnitIdle", _s, []] call AI_misc_fnc_setActionEffects;

// ------------------- ActionUnitInfantryLeaveFormation
["ActionUnitInfantryLeaveFormation", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryLeaveFormation", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionEffects;

// ------------------- ActionUnitInfantryRegroup
["ActionUnitInfantryRegroup", _s, [
								[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false],
								[WSP_UNIT_HUMAN_AT_VEHICLE, false],
								[WSP_UNIT_HUMAN_AT_TARGET_POS, true]
								]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryRegroup", _s, [[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true]]] call AI_misc_fnc_setActionEffects;


// MOVEMENT

// ------------------- ActionUnitMoveMounted
["ActionUnitMoveMounted", _s, [	[WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true],
							[WSP_UNIT_HUMAN_AT_VEHICLE, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitMoveMounted", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitMoveMounted", [TAG_POS, TAG_MOVE_RADIUS, TAG_ROUTE]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitMoveMounted", [TAG_MOVE_RADIUS]]	call AI_misc_fnc_setActionParametersFromGoalOptional;


// ------------------- ActionUnitInfantryMove
["ActionUnitInfantryMove", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryMove", _s, [[WSP_UNIT_HUMAN_AT_TARGET_POS, true], [WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryMove", [TAG_MOVE_TARGET]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitInfantryMove", [TAG_MOVE_RADIUS, TAG_BUILDING_POS_ID]]	call AI_misc_fnc_setActionParametersFromGoalOptional;

// ------------------- ActionUnitNothing
["ActionUnitNothing", _s, []] call AI_misc_fnc_setActionPreconditions;
["ActionUnitNothing", _s, []] call AI_misc_fnc_setActionEffects;


// Interaction actions are arbitrated by parameter passed to them
["ActionUnitRepairVehicle", _s, [	[WSP_UNIT_HUMAN_AT_VEHICLE, false],
								[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
								[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitRepairVehicle", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitRepairVehicle", [TAG_TARGET_REPAIR]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitArrest", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
						//[WSP_UNIT_HUMAN_AT_TARGET_POS, true], // For now it performs movement itself
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitArrest", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitArrest", [TAG_TARGET_ARREST]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitSalute", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
						[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
						[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitSalute", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitSalute", [TAG_TARGET_SALUTE]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitScareAway", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
							[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
							[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitScareAway", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitScareAway", [TAG_TARGET_SCARE_AWAY]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitAmbientAnim", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
							[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
							[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitAmbientAnim", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitAmbientAnim", [TAG_TARGET_AMBIENT_ANIM]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitAmbientAnim", [TAG_ANIM]]	call AI_misc_fnc_setActionParametersFromGoalOptional;

["ActionUnitShootAtTargetRange", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
									[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
									[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitShootAtTargetRange", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitShootAtTargetRange", [TAG_TARGET_SHOOT_RANGE]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitShootLegTarget", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitShootLegTarget", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitShootLegTarget", 	[TAG_TARGET_SHOOT_LEG]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitInfantryStandIdle", _s, [	[WSP_UNIT_HUMAN_AT_VEHICLE, false],
										[WSP_UNIT_HUMAN_AT_TARGET_POS, true]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitInfantryStandIdle", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitInfantryStandIdle", [TAG_TARGET_STAND_IDLE, TAG_DURATION_SECONDS]]	call AI_misc_fnc_setActionParametersFromGoalRequired;

["ActionUnitDialogue", _s, [[WSP_UNIT_HUMAN_AT_VEHICLE, false],
							[WSP_UNIT_HUMAN_AT_TARGET_POS, true],
							[WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false]]] call AI_misc_fnc_setActionPreconditions;
["ActionUnitDialogue", _s, [[WSP_UNIT_HUMAN_HAS_INTERACTED, true]]] call AI_misc_fnc_setActionEffects;
["ActionUnitDialogue", [TAG_TARGET_DIALOGUE]]	call AI_misc_fnc_setActionParametersFromGoalRequired;
["ActionUnitDialogue", []]	call AI_misc_fnc_setActionParametersFromGoalOptional;


//["ActionUnitShootLegTarget", []] call AI_misc_fnc_setActionEffects;

//["ActionUnitSurrender", []] call AI_misc_fnc_setActionEffects;
//["ActionUnitVehicleUnflip", []] call AI_misc_fnc_setActionEffects;


// The actual effects returned by goal can depend on context and differ from those set below
// ---------------- Predefined actions of goals
["GoalUnitNothing",							"ActionUnitNothing"					] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitVehicleUnflip",					"ActionUnitVehicleUnflip"			] call AI_misc_fnc_setGoalPredefinedAction;
["GoalUnitArrested",						"ActionUnitArrested"				] call AI_misc_fnc_setGoalPredefinedAction;


// ---------------- Action costs


//["_ActionUnit", 0] call AI_misc_fnc_setActionCost;
//["_ActionUnitInfantryMoveBase", 		0] call AI_misc_fnc_setActionCost;
["ActionUnitArrest", 					0.1] call AI_misc_fnc_setActionCost;
["ActionUnitDismountCurrentVehicle", 	1] call AI_misc_fnc_setActionCost;
["ActionUnitFlee", 						1] call AI_misc_fnc_setActionCost;
["ActionUnitFollow", 					0.1] call AI_misc_fnc_setActionCost; // Must cost less than dismounting and following on foot
["ActionUnitGetInVehicle", 				0.1] call AI_misc_fnc_setActionCost;
["ActionUnitIdle", 						0.1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryMove", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryRegroup", 			0.6] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryLeaveFormation",	0.1] call AI_misc_fnc_setActionCost;
//["ActionUnitMove", 						1] call AI_misc_fnc_setActionCost; // It's abstract!
["ActionUnitMoveMounted", 				0.3] call AI_misc_fnc_setActionCost;
["ActionUnitNothing", 					1] call AI_misc_fnc_setActionCost;
["ActionUnitRepairVehicle", 			1] call AI_misc_fnc_setActionCost;
["ActionUnitSalute", 					1] call AI_misc_fnc_setActionCost;
["ActionUnitScareAway", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitAmbientAnim", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitShootAtTargetRange", 		1] call AI_misc_fnc_setActionCost;
["ActionUnitShootLegTarget", 			1] call AI_misc_fnc_setActionCost;
["ActionUnitSurrender", 				1] call AI_misc_fnc_setActionCost;
["ActionUnitDialogue",	 				1] call AI_misc_fnc_setActionCost;
["ActionUnitVehicleUnflip", 			0.1] call AI_misc_fnc_setActionCost;
["ActionUnitInfantryStandIdle",			1] call AI_misc_fnc_setActionCost;
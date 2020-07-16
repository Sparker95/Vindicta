#include "common.hpp"

/*
Class: AI.AIUnitCivilian

AI for wandering civilians

Author: Sparker 12.11.2018
*/

#define pr private

// Danger duration in seconds
// If bot has no danger for more than this amount of time, he considers himself safe again
#define DANGER_DURATION 60.0

#define OOP_CLASS_NAME AIUnitCivilian
CLASS("AIUnitCivilian", "AIUnitHuman")

	// This guy feels in danger
	VARIABLE("lastDangerTime");

	// Civilian presence module
	VARIABLE("civPresence");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent"), P_OOP_OBJECT("_civPresence")];

		ASSERT_OBJECT_CLASS(_civPresence, "CivPresence");
		
		T_SETV("civPresence", _civPresence);
		T_SETV("lastDangerTime", 0);

		pr _hO = CALLM0(_agent, "getObjectHandle");

		// Add event handlers
		_ho addEventHandler ["hit", {
			CALLSM1("AIUnitCivilian", "dangerEventHandler", _this select 0);
		}];

		_ho addEventHandler ["firedNear", {
			CALLSM1("AIUnitCivilian", "dangerEventHandler", _this select 0);
		}];
	ENDMETHOD;

	// Event Handler attached to arma object handle
	STATIC_METHOD(dangerEventHandler)
		params ["_thisClass", "_hO"];
		pr _civ = CALLSM1("Civilian", "getCivilianFromObjectHandle", _hO);
		pr _ai = CALLM0(_civ, "getAI");

		// Bail of no AI
		if (IS_NULL_OBJECT(_ai)) exitWith { nil };

		pr _ws = GETV(_ai, "worldState");
		pr _dangerCurrent = WS_GET(_ws, WSP_UNIT_HUMAN_IN_DANGER);

		// Say something if we were not in danger but switched to danger
		if (!_dangerCurrent) then {
			pr _text = selectRandom g_phasesCivilianPanic;
			CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _hO, _text);
		};

		WS_SET(_ws, WSP_UNIT_HUMAN_IN_DANGER, true);
		SETV(_ai, "lastDangerTime", time);
		CALLM0(_ai, "setUrgentPriority");

		// Return nothing if this EH is stacked, we don't override anything
		nil
	ENDMETHOD;

	// Sets WSP_UNIT_HUMAN_IN_DANGER
	// Default value is true!
	public override METHOD(setInDangerWSP)
		params [P_THISOBJECT, ["_value", true, [true]]];
		CALLCM("AIUnitHuman", _thisObject, "setInDangerWSP", [_value]);
		T_SETV("lastDangerTime", time);
	ENDMETHOD;

	public override METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "MiscLowPriority");
	ENDMETHOD;

	public override METHOD(process)
		params [P_THISOBJECT];

		// Handle DANGER world state property
		// Reset danger after we've been in danger for too long
		pr _ws = T_GETV("worldState");
		if (WS_GET(_ws, WSP_UNIT_HUMAN_IN_DANGER)) then {
			if (time - T_GETV("lastDangerTime") > DANGER_DURATION) then {
				WS_SET(_ws, WSP_UNIT_HUMAN_IN_DANGER, false);
			};
		};

		CALLCM("AIUnitHuman", _thisObject, "process", [_spawning]);
	ENDMETHOD;

	protected override METHOD(getDialogueClassName)
		params [P_THISOBJECT];
		"DialogueCivilian";
	ENDMETHOD;

	// Custom dialogue handling
	protected override METHOD(handleStartNewDialogue)
		params [P_THISOBJECT, P_OBJECT("_unitTalkTo"), P_NUMBER("_remoteClientID"), P_STRING("_dlgClassName")];

		// Check if civilian is arrested
		if (T_GETV("arrested")) exitWith {
			pr _text = selectRandom g_phrasesCivilianCantTalkArrested;
			CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _hO, _text);
			false;
		};

		// Check if civilian is very scared
		pr _worldState = T_GETV("worldState");
		pr _danger = WS_GET(_worldState, WSP_UNIT_HUMAN_IN_DANGER);

		if (_danger) exitWith {
			pr _text = selectRandom g_phrasesCivilianCantTalkScared;
			CALLSM3("Dialogue", "objectSaySentence", NULL_OBJECT, _hO, _text);
			false;
		};

		true;
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	public override METHOD(getPossibleGoals)
		[
			"GoalUnitArrested",
			"GoalCivilianPanicNearest",
			"GoalCivilianPanicAway",
			"GoalUnitDialogue",
			"GoalUnitInfantryEscapeDangerSource"
		]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	public override METHOD(getPossibleActions)
		[
			"ActionUnitInfantryMove",
			"ActionUnitFlee",
			"ActionUnitDismountCurrentVehicle",
			"ActionUnitAmbientAnim",
			"ActionUnitInfantryStandIdle",
			"ActionUnitDialogue"
		]
	ENDMETHOD;

	// Returns array of class-specific additional variable names to be transmitted to debug UI
	public override METHOD(getDebugUIVariableNames)
		[
			"hO",
			"dangerSource",
			"dangerTimeEnd",
			"dangerLevel",
			"dangerRadius",
			"assignedVehicle",
			"assignedVehicleRole",
			"assignedCargoIndex",
			"assignedTurretPath",
			"moveTarget",
			"moveBuildingPosID",
			"moveRadius",	// Radius for movement completion
			"orderedToMove",
			"prevPos",
			"stuckDuration",
			"timeLastProcess",
			"civPresence"
		]
	ENDMETHOD;

ENDCLASS;
#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Class: AI.AIUnitInfantry

AI for military bots.

Author: Sparker 12.11.2018
*/

#define pr private

#define MRK_GOAL	"_goal"
#define MRK_ARROW	"_arrow"

#define OOP_CLASS_NAME AIUnitInfantry
CLASS("AIUnitInfantry", "AIUnitHuman")

	// Sentry position
	VARIABLE("sentryPos");

	#ifdef DEBUG_GOAL_MARKERS
	VARIABLE("markersEnabled");
	#endif

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];

		// Initialize sensors
		pr _sensorSalute = NEW("SensorUnitSalute", [_thisObject]);
		T_CALLM("addSensor", [_sensorSalute]);

		pr _sensorCivNear = NEW("SensorUnitCivNear", [_thisObject]);
		T_CALLM("addSensor", [_sensorCivNear]);

	ENDMETHOD;

	public override METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "AIInfantry");
	ENDMETHOD;

	/*
	Method: setSentryPos
	Sets the sentry position, which may be later retrieved by actions.
	
	Parameters: _pos
	
	_pos - position
	
	Returns: nil
	*/
	
	public METHOD(setSentryPos)
		params [P_THISOBJECT, P_POSITION("_pos")];
		T_SETV("sentryPos", _pos);
	ENDMETHOD;
	
	/*
	Method: getSentryPos
	Getter for setSentryPos
	
	Returns: position or [] if no position was assigned
	*/
	
	public METHOD(getSentryPos)
		params [P_THISOBJECT];
		pr _pos = T_GETV("sentryPos");
		if (isNil "_pos") then {
			[]
		} else {
			_pos
		};
	ENDMETHOD;

	protected override METHOD(getDialogueClassName)
		params [P_THISOBJECT];
		pr _unit = T_GETV("agent");
		pr _gar = CALLM0(_unit, "getGarrison");
		pr _faction = CALLM0(_gar, "getFaction");
		if (_faction == "police") then {
			"DialoguePolice";
		} else {
			"DialogueMilitary";
		};
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	public override METHOD(getPossibleGoals)
		//["GoalUnitSalute","GoalUnitScareAway"]
		[
			//"GoalUnitScareAway",
			"GoalUnitDialogue",
			"GoalUnitInfantryEscapeDangerSource"
		]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	public override METHOD(getPossibleActions)
		[
		"ActionUnitArrest", 				
		"ActionUnitDismountCurrentVehicle",
		"ActionUnitFlee", 			
		"ActionUnitFollow", 		
		"ActionUnitGetInVehicle", 			
		"ActionUnitIdle", 					
		"ActionUnitInfantryMove",
		"ActionUnitInfantryRegroup", 		
		"ActionUnitInfantryLeaveFormation",
		//"ActionUnitMove", // this is abstract!
		"ActionUnitMoveMounted", 	
		"ActionUnitNothing", 		
		"ActionUnitRepairVehicle", 
		"ActionUnitSalute", 		
		"ActionUnitScareAway", 	
		"ActionUnitAmbientAnim", 	
		"ActionUnitShootAtTargetRange",
		"ActionUnitInfantryStandIdle",
		//"ActionUnitShootLegTarget", 
		//"ActionUnitSurrender",
		"ActionUnitDialogue"
		//"ActionUnitVehicleUnflip"
		]
	ENDMETHOD;

	public override METHOD(setUrgentPriorityOnAddGoal)
		true
	ENDMETHOD;

ENDCLASS;
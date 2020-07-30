#include "common.h"

/*
OOP class for one civilian.
First create a civilian unit/agent, then create this object and attach it to this unit.
*/

#define pr private

#define CIV_VAR_NAME "__civ"

#define OOP_CLASS_NAME Civilian
CLASS("Civilian", "GOAP_Agent")

	VARIABLE("hO");
	VARIABLE("AI");
	VARIABLE("loc"); // Location this civilian is spawned at

	// Civilian supports resistence and will give intel and help
	/* public */ VARIABLE("supportsResistance");

	// True when this civilian has helped already (gave resources, etc)
	/* public */ VARIABLE("hasContributed");

	// True if civilian will give intel
	/* public */ VARIABLE("knowsIntel");

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_civObjectHandle"), P_OOP_OBJECT("_civPresence")];

		OOP_INFO_1("NEW: %1", _civObjectHandle);

		if (isNull _civObjectHandle) then {
			OOP_ERROR_0("Passed object handle is null!");
		};

		T_SETV("hO", _civObjectHandle);

		// Mark object
		_hO setVariable [CIV_VAR_NAME, _thisObject];

		// Create AI
		pr _AI = NEW("AIUnitCivilian", [_thisObject ARG _civPresence]);
		T_SETV("AI", _AI);
		
		// Handle death of unit
		// When killed, delete AI
		_civObjectHandle addEventHandler ["killed", {
			pr _hO = _this select 0;

			// For some reason this gets called twice
			// First time is correct, second time with null-object, 
			if (isNull _hO) exitWith {};

			OOP_INFO_2("Civilian killed: %1, position: %2", _hO, getPosWorld _hO);

			// Notify game mode
			CALLM2(gGameMode, "postMethodAsync", "civilianKilled", [getPosWorld _hO]);

			pr _thisObject = CALLSM1("Civilian", "getCivilianFromObjectHandle", _hO);
			if (!IS_NULL_OBJECT(_thisObject)) then {
				pr _ai = CALLM0(_thisObject, "getAI");
				if (!IS_NULL_OBJECT(_ai)) then {
					DELETE(_ai);
					T_SETV("AI", NULL_OBJECT);
				};
			};

			// Add to arma's remains collector
			addToRemainsCollector [_hO];
		}];
		
		// Start AI
		CALLM0(_AI, "start");

		// Check if civilian supports resistance
		pr _loc = CALLM0(_civPresence, "getLocation");
		OOP_INFO_1("NEW CIVILIAN: location: %1", _loc);
		T_SETV("loc", _loc);
		pr _support = false;
		pr _knowsIntel = false;
		if (!IS_NULL_OBJECT(_loc)) then {
			pr _type = CALLM0(_loc, "getType");
			OOP_INFO_0("Location is not null!");
			if (_type == LOCATION_TYPE_CITY) then {
				OOP_INFO_0("Location is city!");
				pr _gmdata = CALLM0(_loc, "getGameModeData");
				pr _influence = CALLM0(_gmData, "getInfluence");
				pr _chanceSupport = linearConversion [0, 1, _influence, 0.05, 0.55, true];
				pr _chanceIntel = linearConversion [0, 1, _influence, 0.5, 1.0, true];
				OOP_INFO_3("Influence: %1, support chance: %2, intel knowledge chance: %3", _influence, _chanceSupport, _chanceIntel);
				_support = (random 1) < _chanceSupport;
				_knowsIntel = (random 1) < _chanceIntel;
				OOP_INFO_2("Support: %1, knows intel: %2", _support, _knowsIntel);
			} else {
				OOP_ERROR_0("Location is not a city");
			};
		} else {
			OOP_ERROR_0("Location is null!");
		};
		T_SETV("supportsResistance", _support);
		T_SETV("knowsIntel", _knowsIntel);

		T_SETV("hasContributed", false);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		// Delete AI if not deleted yet
		pr _ai = T_GETV("AI");
		if (!IS_NULL_OBJECT(_ai)) then {
			DELETE(_ai);
		};

		pr _hO = T_GETV("hO");
		deleteVehicle _hO;
	ENDMETHOD;

	public override METHOD(getAI)
		params [P_THISOBJECT];
		T_GETV("AI")
	ENDMETHOD;

	public override METHOD(getSubagents)
		params [P_THISOBJECT];
		[]
	ENDMETHOD;

	METHOD(getObjectHandle)
		params [P_THISOBJECT];
		T_GETV("hO")
	ENDMETHOD;

	public METHOD(getGroup)
		NULL_OBJECT;
	ENDMETHOD;

	STATIC_METHOD(getCivilianFromObjectHandle)
		params [P_THISOBJECT, P_OBJECT("_hO")];

		_hO getVariable [CIV_VAR_NAME, NULL_OBJECT];
	ENDMETHOD;

ENDCLASS;
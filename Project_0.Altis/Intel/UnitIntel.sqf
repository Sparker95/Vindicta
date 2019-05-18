#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Location\Location.hpp"

/*
A class with static functions that initialized variables on objects that can have intel.
Author: Sparker 18.05.2019
*/

#define pr private

#define HAS_INTEL_VAR_NAME "__int"

CLASS("UnitIntel", "")

	/*
	Method: (static)initObject
	Call it on server.
	It initializes intel on some object (arma object, not OOP object!)

	Parameters: _hO, _number

	_hO - object handle
	_number - amount of intel items

	Returns: nil
	*/
	STATIC_METHOD("initObject") {
		params [P_THISCLASS, P_OBJECT("_hO"), P_NUMBER("_number")];
		_hO setVariable [HAS_INTEL_VAR_NAME, _number, true];
	} ENDMETHOD;

	/*
	Method: (static)initPlayer
	Call it on player's computer when he respawns to to add actions to player to take intel items

	Parameters: _hO

	_hO - player's object

	Returns: nil
	*/
	STATIC_METHOD("initPlayer") {
		params [P_THISCLASS, P_OBJECT("_hO")];

		player addAction ["Take intel", // title
                 {CALLSM1("UnitIntel", "takeIntel", cursorObject)}, // Script
                 0, // Arguments
                 9000, // Priority
                 true, // ShowWindow
                 false, //hideOnUse
                 "", //shortcut
                 "call UnitIntel_fnc_actionCondition", //condition
                 2, //radius
                 false, //unconscious
                 "", //selection
                 ""]; //memoryPoint
	} ENDMETHOD;

	
	// A condition function for Intel
	// We create it directly because we don't want to have it wrapped by OOP
	UnitIntel_fnc_actionCondition = {
		private _co = cursorObject;
    	(!isNil {_co getVariable HAS_INTEL_VAR_NAME}) && ((_target distance _co) < 3) 
	};

	/*
	Method: (static)takeIntel
	It is called on player's computer when he takes an intel item

	Parameters: _hO

	_hO - object where player took intel from

	Returns: nil
	*/
	STATIC_METHOD("takeIntel") {
		params ["_thisObject", P_OBJECT("_hO")];

		pr _number = _hO getVariable HAS_INTEL_VAR_NAME;
		if (isNil "_number") then {
			systemChat "You have found no intel there!";
			OOP_ERROR_1("No intel found on object %1", _hO);
		} else {
			systemChat "You have found some intel!";

			// Do processing
			pr _playerCommander = CALLSM1("AICommander", "getCommanderAIOfSide", playerSide);
			CALLM2(_playerCommander, "postMethodAsync", "getRandomIntelFromEnemy", []);


			// Decrease the counter or delete it completely
			_number = _number - 1;
			if (_number <= 0) then {
				_hO setVariable [HAS_INTEL_VAR_NAME, nil, true];
			} else {
				_hO setVariable [HAS_INTEL_VAR_NAME, _number, true];
			};
		};

	} ENDMETHOD;

ENDCLASS;
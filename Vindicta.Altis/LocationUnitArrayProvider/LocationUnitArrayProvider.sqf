#include "..\common.h"
#include "..\Message\Message.hpp"

/*
Class: LocationUnitArrayProvider
This object calculates arrays with units which can spawn locations of different sides.
Calculating these arrays is a resource-consuming and it must not be performed very often, that's why we need a separate object for this.
*/

#define OOP_CLASS_NAME LocationUnitArrayProvider
CLASS("LocationUnitArrayProvider", "MessageReceiver");

	VARIABLE("spawnWest"); // These units can spawn West locations
	VARIABLE("spawnEast"); // These units can spawn East locations
	VARIABLE("spawnInd"); // These units can spawn Independant locations
	VARIABLE("timer");

	// |                              N E W
	/*
	Method: New
	*/
	METHOD(new)
		params [P_THISOBJECT];

		if (isNil "gMessageLoopMain") exitWith {"[LocationUnitArrayProvider] Error: global location message loop doesn't exist!";};

		T_SETV("spawnWest", []);
		T_SETV("spawnEast", []);
		T_SETV("spawnInd", []);
		
		// Create a timer for gLUAP
		private _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		private _args = [_thisObject, 3.5, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);
	ENDMETHOD;


	// |                            D E L E T E
	/*
	Method: Delete
	*/
	METHOD(delete)
		params [P_THISOBJECT];
		
		DELETE(T_GETV("timer"));
	ENDMETHOD;


	// |                  G E T   M E S S A G E   L O O P
	public override METHOD(getMessageLoop) //Derived classes must implement this method
		gMessageLoopMain
	ENDMETHOD;


	// |                     H A N D L E   M E S S A G E

	public override METHOD(handleMessage) //Derived classes must implement this method
		params [P_THISOBJECT, P_ARRAY("_msg") ];
		//diag_log "[LocationunitArrayProvider] Info: calculating arrays...";
		// It supports only one kind of messages now
		// Calculate the arrays
		private _unitsWest = allUnits select {side _x == WEST};
		private _unitsEast = allUnits select {side _x == EAST};
		private _unitsInd = allUnits select {side _x == INDEPENDENT};
		private _allPlayers = allPlayers;
		private _spawnWest = _unitsEast + _unitsInd + _allPlayers;
		private _spawnEast = _unitsWest + _unitsInd + _allPlayers;
		private _spawnInd = _unitsWest + _unitsEast + _allPlayers;
		T_SETV("spawnWest", _spawnWest);
		T_SETV("spawnEast", _spawnEast);
		T_SETV("spawnInd", _spawnInd);
	ENDMETHOD;


	// |                    G E T   U N I T   A R R A Y
	/*
	Method: getUnitArray
	Returns array of units that can spawn locations of given _side

	Parameters: _side

	_side - side

	Returns: Array with object handles of objects that can spawn locations of given side
	*/
	public METHOD(getUnitArray)
		params [P_THISOBJECT, ["_side", WEST, [WEST]] ];
		switch (_side) do {
			case WEST: {T_GETV("spawnWest")};
			case EAST: {T_GETV("spawnEast")};
			case INDEPENDENT: {T_GETV("spawnInd")};
			case CIVILIAN: {allPlayers - entities "HeadlessClient_F";};//returns just players
			default {[]};
		};
	ENDMETHOD;

ENDCLASS;

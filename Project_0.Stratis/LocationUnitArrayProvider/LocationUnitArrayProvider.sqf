/*
This object calculates arrays with units which can spawn locations of different sides.
Calculating these arrays is a resource-consuming and it must not be performed very often, that's why we need a separate object for this.
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("LocationUnitArrayProvider", "MessageReceiver")

	VARIABLE("spawnWest"); //These units can spawn West locations
	VARIABLE("spawnEast"); // These units can spawn East locations
	VARIABLE("spawnInd"); // These units can spawn Independant locations
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		if (isNil "gMessageLoopLocation") exitWith {"[LocationUnitArrayProvider] Error: global location message loop doesn't exist!";};
		
		SET_VAR(_thisObject, "spawnWest", []);
		SET_VAR(_thisObject, "spawnEast", []);
		SET_VAR(_thisObject, "spawnInd", []);		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                  G E T   M E S S A G E   L O O P                   |
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") { //Derived classes must implement this method
		gMessageLoopLocation
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                     H A N D L E   M E S S A G E                    |
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
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
		SET_VAR(_thisObject, "spawnWest", _spawnWest);
		SET_VAR(_thisObject, "spawnEast", _spawnEast);
		SET_VAR(_thisObject, "spawnInd", _spawnInd);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   U N I T   A R R A Y                     |
	// ----------------------------------------------------------------------
	// Returns array of units that can spawn locations of given _side
	METHOD("getUnitArray") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]] ];
		switch (_side) do {
			case WEST: {GET_VAR(_thisObject, "spawnWest")};
			case EAST: {GET_VAR(_thisObject, "spawnEast")};
			case INDEPENDENT: {GET_VAR(_thisObject, "spawnInd")}
		};
	} ENDMETHOD;

ENDCLASS;
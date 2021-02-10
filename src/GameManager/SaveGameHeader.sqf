#include "common.hpp"

/*
Class: SaveGameHeader

Class which stores crucial data about each save game record.
*/

#define OOP_CLASS_NAME SaveGameHeader
CLASS("SaveGameHeader", "Storable")
	VARIABLE_ATTR("saveVersion", ATTR_SAVE_VER(30));		// Save record version. Used for checking if saved game is compatible.
	VARIABLE_ATTR("missionVersion", ATTR_SAVE_VER(30));		// User-friendly mission version when this save was made 
	VARIABLE_ATTR("campaignName", ATTR_SAVE_VER(30));		// String, campaign name
	VARIABLE_ATTR("saveID", ATTR_SAVE_VER(30));				// Number, ID of the save game in this campaign
	VARIABLE_ATTR("worldName", ATTR_SAVE_VER(30));			// String, worldName
	VARIABLE_ATTR("gameModeClassName", ATTR_SAVE_VER(30));	// String, name of the GameMode class
	VARIABLE_ATTR("OOPSessionCounter", ATTR_SAVE_VER(30));	// Number, value of the OOP session counter. Increased every time game is saved.
	VARIABLE_ATTR("date", ATTR_SAVE_VER(30));				// In-game date in format of date command
	VARIABLE_ATTR("campaignStartDate", ATTR_SAVE_VER(30));	// In-game date when campaign was started
	VARIABLE_ATTR("templates", ATTR_SAVE_VER(30));			// Array with selected template names (strings)
	VARIABLE_ATTR("systemTimeUTC", ATTR_SAVE_VER(31));		// Date-time in format of the systemTimeUTC command, representing time at which the game was saved, in UTC to ignore daylight savings
	
	/*
	todo:
	weather
	other things?
	*/

	// Initializes data fields for a new save
	public METHOD(initNew)
		params [P_THISOBJECT];
		T_SETV("saveVersion", call misc_fnc_getSaveVersion);
		T_SETV("missionVersion", call misc_fnc_getVersion);
		T_SETV("campaignName", "_noname_");		// Must be set externally
		T_SETV("saveID", 0);					// Must be set externally
		T_SETV("worldName", worldName);
		T_SETV("gameModeClassName", "_noname_");// Must be set externally
		T_SETV("OOPSessionCounter", call OOP_getSessionCounter);
		T_SETV("date", date);
		T_SETV("campaignStartDate", date);		// Must be set externally
		T_SETV("templates", []);				// Must be set externally
		T_SETV("systemTimeUTC", systemTimeUTC);
	ENDMETHOD;

	// STORAGE
	
	// NOTE that we can't use versioning attributes for save game headers because
	// at this point the save game version is not available, since we read it from header itself
	// thus we must serialize and deserialize all variables and resolve problems
	// manually
	
	public override METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	public override METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);

		private _saveVersion = parseNumber T_GETV("saveVersion");

		// SAVEBREAK patch system time for old headers
		if (_saveVersion < 31) then {
					private _timeZero = [0,0,0,0,0,0,0];
			T_SETV("systemTimeUTC", _timeZero);
		};
		true
	ENDMETHOD;

ENDCLASS;
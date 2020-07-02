#include "common.hpp"

/*
Class: SaveGameHeader

Class which stores crucial data about each save game record.
*/

#define OOP_CLASS_NAME SaveGameHeader
CLASS("SaveGameHeader", "Storable")

	VARIABLE("saveVersion");		// Save record version. Used for checking if saved game is compatible.
	VARIABLE("missionVersion");		// User-friendly mission version when this save was made 
	VARIABLE("campaignName");		// String, campaign name
	VARIABLE("saveID");				// Number, ID of the save game in this campaign
	VARIABLE("worldName");			// String, worldName
	VARIABLE("gameModeClassName");	// String, name of the GameMode class
	VARIABLE("OOPSessionCounter");	// Number, value of the OOP session counter. Increased every time game is saved.
	VARIABLE("date");				// In-game date in format of date command
	VARIABLE("campaignStartDate");	// In-game date when campaign was started
	VARIABLE("templates");			// Array with selected template names (strings)
	
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
	ENDMETHOD;

	// STORAGE
	
	// Save all varaibles
	public override METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	public override METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);
		true
	ENDMETHOD;

ENDCLASS;
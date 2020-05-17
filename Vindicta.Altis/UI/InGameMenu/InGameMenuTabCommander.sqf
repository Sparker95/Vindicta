#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\Location\Location.hpp"

#define pr private

#define CREATE_LOCATION_COST 30

#define OOP_CLASS_NAME InGameMenuTabCommander
CLASS("InGameMenuTabCommander", "DialogTabBase")

	// How many build res required to build/claim this place
	VARIABLE("buildResourcesCost");
	VARIABLE("currentLocation");

	METHOD(new)
		params [P_THISOBJECT];

		gTabCommander = _thisObject;



		// Create the controls
		pr _displayParent = T_CALLM0("getDisplay");

		// Create the tab
		pr _group = _displayParent ctrlCreate ["TAB_CMDR", -1];
		T_CALLM1("setControl", _group);

		// Initialize variables
		pr _pos = getPos player;
		pr _currentLoc = CALLSM1("Location", "getLocationAtPos", _pos);
		T_SETV("currentLocation", _currentLoc);

		OOP_INFO_1("Current location: %1", _currentLoc);
		if (IS_NULL_OBJECT(_currentLoc)) then {
			OOP_INFO_0("  Current location is null");
			// We are potentially creating a location here
			// Button
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_BUTTON_CREATE_LOC");
			_ctrl ctrlSetText "CREATE";
			// Tab headline
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_STATIC_CREATE_A_LOCATION");
			_ctrl ctrlSetText "Create a location";

			// Build resource cost
			pr _buildResCost = CREATE_LOCATION_COST;
			pr _progress = CALLM0(gGameMode, "getCampaignProgress"); // 0..1
			//_buildResCost = 80 * (exp (1 + _progress));
			//if (_progress < 0.03) then { _buildResCost = CREATE_LOCATION_COST; };
			//_buildResCost = 10 * (ceil (_buildResCost / 10) ); // Round it to nearest 10 up

			T_SETV("buildResourcesCost", _buildResCost);
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_STATIC_BUILD_RESOURCES");
			_ctrl ctrlSetText (format ["%1 construction resources", _buildResCost]);

			// Fill the combo box
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
			OOP_INFO_1("COMBO CTRL: %1", ctrlClassName _ctrl);
			_ctrl lbAdd "Camp";
			_ctrl lbAdd "Roadblock";
			_ctrl lbSetData [0, LOCATION_TYPE_CAMP];
			_ctrl lbSetData [1, LOCATION_TYPE_ROADBLOCK];
			//_ctrl lbAdd "Outpost";
			//_ctrl lbSetData [1, LOCATION_TYPE_OUTPOST];

			// set default selection to camp
			_ctrl lbSetCurSel 0;

			// randomize name
			_ctrl = T_CALLM1("findControl", "TAB_CMDR_EDIT_LOC_NAME");
			pr _newLocName = selectRandom [
				"Camp Bravo",
				"Camp Charlie",
				"Camp Delta",
				"Camp Echo",
				"Camp Foxtrot",
				"Camp Juliet",
				"Camp Eskimo",
				"Camp Sierra",
				"Camp India",
				"Camp X-Ray",
				"Camp Lima",
				"Camp Romeo",
				"Camp Victory",
				"Camp Victor",
				"Camp Zulu",
				"Camp William",
				"Camp Sparklight",
				"Camp Redstone",
				"Camp Blackstone",
				"Camp Alpha",
				"Camp Jupiter",
				"Camp Neptune",
				"Camp Pluto",
				"Camp Mars",
				"Camp Juno",
				"Camp Ceres",
				"Camp Saturn",
				"Camp Mercury",
				"Camp Apollo",
				"Camp Sol",
				"Camp Luna",
				"Camp Vesta",
				"Camp Zeus",
				"Camp Poseidon",
				"Camp Ares",
				"Camp Athena",
				"Camp Apollo",
				"Camp Artemis",
				"Camp Hermes",
				"Camp Nemesis", // Goddess of Revenge
				"Camp Dionysus", // God of Wine
				"Camp Hades" // God of Underworld
			];
			_ctrl ctrlSetText _newLocName;

			T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_CREATE_LOC", "buttonClick", "onButtonCreateLocation");
		} else {
			OOP_INFO_0("  Current location is not null");
			// We are potentially claiming this location
			// Button
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_BUTTON_CREATE_LOC");
			_ctrl ctrlSetText "CLAIM";

			// Check if we are trying to claim a city
			if (CALLM0(_currentLoc, "getType") == LOCATION_TYPE_CITY) then {
				_ctrl ctrlSetTooltip "We can't claim a city!";
				_ctrl ctrlEnable false;
			};

			// Check if we already own this place
			pr _result0 = CALLM2(gIntelDatabaseClient, "getFromIndex", "location", _currentLoc);
			pr _result1 = CALLM2(gIntelDatabaseClient, "getFromIndex", OOP_PARENT_STR, "IntelLocation");
			//OOP_INFO_2("Intel result: %1 %2", _result0, _result1);
			pr _intelResult = (_result0 arrayIntersect _result1) select 0;
			if (!isNil "_intelResult") then {
				if (GETV(_intelResult, "side") == playerSide) then {
					_ctrl ctrlSetTooltip "We already own this place!";
					_ctrl ctrlEnable false;
				};
			};

			// Tab headline
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_STATIC_CREATE_A_LOCATION");
			_ctrl ctrlSetText "Claim a location";

			// Set cost text
			pr _buildResCost = 0;
			// If location was never occupied, we require some build resources to occupy it
			// If it was occupied before, it's free \o/
			// You just need to let potential enemies go away or kill them
			if (!CALLM0(_currentLoc, "wasOccupied")) then {
				// This place was never occupied, calculate the cost
				pr _locBorder = CALLM0(_currentLoc, "getBorder");
				_locBorder params ["_borderPos", "_a", "_b", "_angle", "_isRectangle"];
				pr _borderArea = if (_isRectangle) then {
					_a*_b*4
				} else {
					3.14*_a*_b
				};
				pr _borderLinearSize = sqrt _borderArea;
				pr _buildResPerSize = CREATE_LOCATION_COST / (sqrt (3.14*50*50)); // We require CREATE_LOCATION_COST build res for a circle with 50 meter radius
				_buildResCost = _borderLinearSize * _buildResPerSize;
				pr _progress = CALLM0(gGameMode, "getCampaignProgress"); // 0..1
				_buildResCost = 10 * (ceil (_buildResCost / 10) ); // Round it to nearest 10 up
			};

			// Set cost text
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_STATIC_BUILD_RESOURCES");
			_ctrl ctrlSetText (format ["%1 construction resources", _buildResCost]);
			T_SETV("buildResourcesCost", _buildResCost); // Store the cost, we will check it later when button is pushed

			// Set name text
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_EDIT_LOC_NAME");
			_ctrl ctrlSetText (CALLM0(_currentLoc, "getDisplayName"));
			//_ctrl ctrlEnable false;

			// Disable combo box
			pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
			_ctrl ctrlEnable false;

			T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_CREATE_LOC", "buttonClick", "onButtonClaimLocation");
		};

		// Skip Time
		T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_SKIP_TO_DUSK", "buttonClick", "onButtonSkipDusk");
		T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_SKIP_TO_PREDAWN", "buttonClick", "onButtonSkipPredawn");
		T_CALLM3("controlAddEventHandler", "TAB_CMDR_BUTTON_SKIP_TO_DAWN", "buttonClick", "onButtonSkipDawn");

		T_CALLM0("_updateTimeSkipTooltips");
	ENDMETHOD;

	METHOD(_updateTimeSkipTooltips)
		params [P_THISOBJECT];
		private _hoursUntilNextDusk = round call pr0_fnc_getHoursUntilNextDusk;
		private _hoursUntilNextDawn = round call pr0_fnc_getHoursUntilNextDawn;
		T_CALLM1("findControl", "TAB_CMDR_BUTTON_SKIP_TO_DUSK")
			ctrlSetTooltip format["Will skip time until dusk (dusk is in about %1 hours)", _hoursUntilNextDusk];
		T_CALLM1("findControl", "TAB_CMDR_BUTTON_SKIP_TO_PREDAWN")
			ctrlSetTooltip format["Will skip time until 30 minutes before dawn (dawn is in about %1 hours)", round _hoursUntilNextDawn];
		T_CALLM1("findControl", "TAB_CMDR_BUTTON_SKIP_TO_DAWN")
			ctrlSetTooltip format["Will skip time until dawn (dawn is in about %1 hours)", _hoursUntilNextDawn];
	ENDMETHOD;
	

	METHOD(delete)
		params [P_THISOBJECT];
		gTabCommander = nil;
	ENDMETHOD;

	METHOD(onButtonCreateLocation)
		params [P_THISOBJECT];

		OOP_INFO_0("ON BUTTON CREATE LOCATION");

		pr _ctrlLocName = T_CALLM1("findControl", "TAB_CMDR_EDIT_LOC_NAME");
		pr _locName = ctrlText _ctrlLocName;

		pr _ctrlLocType = T_CALLM1("findControl", "TAB_CMDR_COMBO_LOC_TYPE");
		pr _row = lbCurSel _ctrlLocType;
		
		pr _dialogObj = T_CALLM0("getDialogObject");

		pr _cursorObject = if ((player distance cursorObject) < 10) then {cursorObject} else {objNull};
		pr _coBuildRes = CALLSM1("Unit", "getVehicleBuildResources", _cursorObject);

		// Ensure that player or cursorObject has enough resources
		pr _playerBuildRes = CALLSM1("Unit", "getInfantryBuildResources", player);
		OOP_INFO_1("Player's build resources: %1", _playerBuildRes);
		pr _buildResCost = T_GETV("buildResourcesCost");
		if (_playerBuildRes < _buildResCost && _coBuildRes < _buildResCost) exitWith {
			pr _text = format ["You must have at least %1 build resources!", _buildResCost];
			CALLM1(_dialogObj, "setHintText", _text);
		};

		// Ensure proper input
		if (count _locName == 0) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must specify a proper name.");
		};

		if (_row < 0) exitWith {
			CALLM1(_dialogObj, "setHintText", "You must select a location type.");
		};

		// Disable button before sending message to server to avoid race condition
		pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_BUTTON_CREATE_LOC");
		_ctrl ctrlEnable false;

		// Send data to cmdr at the server
		// Server might run extra checks
		pr _locType = _ctrlLocType lbData _row;

		// Source object where build resources will be deleted from, player or vehicle he's looking at
		pr _hBuildResSrc = if (_playerBuildRes >= _buildResCost) then {player} else {_cursorObject};
		pr _AI = CALLSM1("AICommander", "getAICommander", playerSide);
		pr _args = [clientOwner, getPosWorld player, _locType, _locName, _hBuildResSrc, _buildResCost];
		CALLM2(_AI, "postMethodAsync", "clientCreateLocation", _args);

		CALLM1(_dialogObj, "setHintText", "Creating new location ...");
	ENDMETHOD;

	METHOD(onButtonClaimLocation)
		params [P_THISOBJECT];

		pr _currentLoc = T_GETV("currentLocation");

		// Sanity check
		if (IS_NULL_OBJECT(_currentLoc)) exitWith {
			OOP_ERROR_0("CLAIM LOCATION: location is null!");
		};

		// Bail if there is nothing
		if (IS_NULL_OBJECT(_currentLoc)) exitWith {
			T_CALLM1("setHintText", "There is nothing to claim here!");
		};

		// Bail if we already own this place, check it through the intel database to make it more reliable
		pr _result0 = CALLM2(gIntelDatabaseClient, "getFromIndex", "location", _currentLoc);
		pr _result1 = CALLM2(gIntelDatabaseClient, "getFromIndex", OOP_PARENT_STR, "IntelLocation");
		//OOP_INFO_2("Intel result: %1 %2", _result0, _result1);
		pr _intelResult = (_result0 arrayIntersect _result1) select 0;
		if (!isNil "_intelResult" && {(GETV(_intelResult, "side") == playerSide)}) exitWith {
			T_CALLM1("setHintText", "We already own this place!");
		};

		// Check if player has enough build resources
		pr _cursorObject = if ((player distance cursorObject) < 10) then {cursorObject} else {objNull};
		pr _coBuildRes = CALLSM1("Unit", "getVehicleBuildResources", _cursorObject);

		// Ensure that player or cursorObject has enough resources
		pr _playerBuildRes = CALLSM1("Unit", "getInfantryBuildResources", player);
		OOP_INFO_1("Player's build resources: %1", _playerBuildRes);
		pr _buildResCost = T_GETV("buildResourcesCost");
		if (_playerBuildRes < _buildResCost && _coBuildRes < _buildResCost) exitWith {
			pr _text = format ["You must have at least %1 build resources!", _buildResCost];
			T_CALLM1("setHintText", _text);
		};

		// Disable button before sending message to server to avoid race condition
		pr _ctrl = T_CALLM1("findControl", "TAB_CMDR_BUTTON_CREATE_LOC");
		_ctrl ctrlEnable false;

		// Send data to cmdr at the server
		// Server might run extra checks
		// Source object where build resources will be deleted from, player or vehicle he's looking at
		pr _hBuildResSrc = if (_playerBuildRes >= _buildResCost) then {player} else {_cursorObject};
		pr _AI = CALLSM1("AICommander", "getAICommander", playerSide);
		pr _args = [clientOwner, _currentLoc, _hBuildResSrc, _buildResCost];
		CALLM2(_AI, "postMethodAsync", "clientClaimLocation", _args);
	ENDMETHOD;

	METHOD(onButtonSkipDusk)
		params [P_THISOBJECT];
		T_CALLM1("_skipTimeDusk", 0);
	ENDMETHOD;

	METHOD(onButtonSkipPredawn)
		params [P_THISOBJECT];
		T_CALLM1("_skipTimeDawn", -0.5);
	ENDMETHOD;
	
	METHOD(onButtonSkipDawn)
		params [P_THISOBJECT];
		T_CALLM1("_skipTimeDawn", 0);
	ENDMETHOD;

	METHOD(_skipTimeDusk)
		params [P_THISOBJECT, P_NUMBER("_offsetFromDusk")];
		private _hoursUntilNextDusk = call pr0_fnc_getHoursUntilNextDusk;
		(_hoursUntilNextDusk + _offsetFromDusk) remoteExecCall ["skipTime", ON_ALL];
		T_CALLM0("_updateTimeSkipTooltips");
	ENDMETHOD;

	METHOD(_skipTimeDawn)
		params [P_THISOBJECT, P_NUMBER("_offsetFromDawn")];
		private _hoursUntilNextDawn = call pr0_fnc_getHoursUntilNextDawn;
		(_hoursUntilNextDawn + _offsetFromDawn) remoteExecCall ["skipTime", ON_ALL];
		T_CALLM0("_updateTimeSkipTooltips");
	ENDMETHOD;

	STATIC_METHOD(showServerResponse)
		params [P_THISCLASS, P_STRING("_text")];

		// If this tab is already closed, just throw text into system chat
		if (isNil "gTabCommander") then {
			systemChat _text;
		} else {
			pr _thisObject = gTabCommander;
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", _text);
		};
	ENDMETHOD;

	METHOD(setHintText)
		params [P_THISOBJECT, P_STRING("_text")];

		pr _dialogObj = T_CALLM0("getDialogObject");
		CALLM1(_dialogObj, "setHintText", _text);
	ENDMETHOD;

ENDCLASS;
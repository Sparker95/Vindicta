#include "common.hpp"

/*
Class for client-side dialogue representation, manages UI and connection with server.

It's a singleton class, must be created once for player for whole mission length.

Authors: Sparker and Jeroen.
*/

#define OOP_CLASS_NAME DialogueClient
CLASS("DialogueClient", "")

	STATIC_VARIABLE("instance");

	// Connection state
	// Client can be connecte to a server-hosted dialogue object
	VARIABLE("connected");
	// Ref to server-hosted dialogue
	VARIABLE("remoteDialogueRef");
	// Arma object handle, object player is currently talking to, if connected
	VARIABLE("objectTalkTo");

	// True when client is shown options
	VARIABLE("optionsShown");
	// Array with shown options
	VARIABLE("options");

	// Array with lines (controls)
	VARIABLE("lineControls");

	// Array with pointers (controls)
	VARIABLE("pointerControls");

	// Group control with sentences
	VARIABLE("ctrlGroup");

	// Mission event handler ID
	VARIABLE("ehID");

	// Event handler for keyboard
	VARIABLE("keyboardEHID");

	METHOD(new)
		params [P_THISOBJECT];

		disableSerialization;

		if (!hasInterface) exitWith {
			OOP_ERROR_0("DialogueClient must be created on client");
		};

		T_SETV("remoteDialogueRef", NULL_OBJECT);
		T_SETV("objectTalkTo", objNull);
		T_SETV("connected", false);
		T_SETV("optionsShown", false);
		T_SETV("options", []);
		T_SETV("lineControls", []);
		T_SETV("pointerControls", []);

		// Create the group control
		pr _ctrlGroup = (finddisplay 46) ctrlCreate ["RscControlsGroup", -1];
		T_SETV("ctrlGroup", [_ctrlGroup]); // Put it into array so arma doesn't complain
		_ctrlGroup ctrlSetPosition [
			DIALOGUE_BOX_X,
			DIALOGUE_BOX_Y,
			DIALOGUE_BOX_WIDTH,
			DIALOGUE_BOX_HEIGHT
		];
		_ctrlGroup ctrlCommit 0;

		// Test group background
		pr _ctrlBackground = (findDIsplay 46) ctrlCreate ["RscText", 123123, _ctrlGroup];
		_ctrlBackground ctrlSetPosition [0, 0, DIALOGUE_BOX_WIDTH-0.001, DIALOGUE_BOX_HEIGHT-0.001];
		#ifdef DIALOGUE_LAYOUT_DEBUG
		_ctrlBackground ctrlSetBackgroundColor [0.2, 0, 0, 0.3];
		#else
		_ctrlBackground ctrlSetBackgroundColor [0, 0, 0, 0];
		#endif
		_ctrlBackground ctrlCommit 0;
		// Create the compass

		// Create the per frame handler
		pr _id = addMissionEventHandler ["EachFrame", {
			pr _instance = CALLSM0("DialogueClient", "getInstance");
			//OOP_INFO_1("draw3d, instance: %1", _instance);
			CALLM0(_instance, "onEachFrame");
		}];
		T_SETV("ehID", _id);

		// Add keyboard event handler
		private _keyDownEvent = (finddisplay 46) displayAddEventHandler ["KeyDown", { 
			params ["_display", "_key", "_shift", "_ctrl", "_alt"];

			pr _thisObject = CALLSM0("DialogueClient", "getInstance");
			if (T_GETV("optionsShown")) then {
				pr _optionID = _key - 2; // key '1' has code 2
				if (_optionID >= 0 && _optionID <= 9) then {
					T_CALLM1("_selectOption", _optionID);
					true;	//disable default key events (commanding menu)
				} else {
					false;
				};
			} else {
				false;
			};
		}];
		T_SETV("keyboardEHID", _keyDownEvent);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		// Normally we don't need to delete it
		// But we can do so for debug purposes

		// Delete all controls
		{
			ctrlDelete _x;
		} forEach (T_GETV("lineControls") + T_GETV("pointerControls"));
		pr _ctrlGroup = T_GETV("ctrlGroup") select 0;
		ctrlDelete _ctrlGroup;

		// Remove mission event handler
		removeMissionEventHandler ["eachFrame", T_GETV("ehID")];

		// Remove keyboard event handler
		(findDisplay 46) displayRemoveEventHandler  ["KeyDown", T_GETV("keyboardEHID")];
	ENDMETHOD;

	// Returns class instance, creates one if it's not created yet.
	STATIC_METHOD(getInstance)
		params [P_THISCLASS];

		pr _instance = GETSV(_thisClass, "instance");
		//OOP_INFO_1("getInstance: %1", _instance);
		if (IS_NULL_OBJECT(_instance)) then {
			_instance = NEW("DialogueClient", []);
			SETSV(_thisClass, "instance", _instance);
		};

		_instance;
	ENDMETHOD;

	// Called on each frame
	public METHOD(onEachFrame)
		params [P_THISOBJECT];

		//OOP_INFO_0("onEachFrame");

		pr _lines = T_GETV("lineControls");
		pr _pointers = T_GETV("pointerControls");
		pr _ctrlGroup = T_GETV("ctrlGroup") select 0;
		if (count _pointers > 0 || count _lines > 0) then {
			_ctrlGroup ctrlShow (!visibleMap); // Hide if map is open
			T_CALLM0("updateLines");
			T_CALLM0("updatePointers");
		} else {
			_ctrlGroup ctrlShow false;
		};
	ENDMETHOD;

	// Deletes old sentences,
	// updates positions of existing sentences
	METHOD(updateLines)
		params [P_THISOBJECT];

		//OOP_INFO_0("updateLines");

		// Delete sentences which are not needed any more
		pr _lineControlsToDelete = [];
		pr _lineControls = T_GETV("lineControls");
		//OOP_INFO_1("  line count: %1", count _lineControls);
		{
			pr _type = _x getVariable "_type";
			if (_type == LINE_TYPE_SENTENCE) then {
				// Check if time of this sentence is over
				pr _removeTime = _x getVariable "_removeTime";
				if (time >= _removeTime) then {	// Time out
					_lineControlsToDelete pushBack _x;
				};
			} else {
				// Options never expire
				if (!T_GETV("optionsShown")) then {
					_lineControlsToDelete pushBack _x;
				};
			};
		} forEach _lineControls;
		{
			OOP_INFO_1("deleted timed out line: %1", _x getVariable "_text");
			_lineControls deleteAt (_lineControls find _x);
			ctrlDelete _x;
		} forEach _lineControlsToDelete;
		_lineControlsToDelete = [];

		// Update sentences which are not deleted
		if (count _lineControls > 0) then {
			// Sentence created last is displayed at the bottom
			pr _posy = DIALOGUE_BOX_HEIGHT - DIALOGUE_GAP;
			for "_i" from (count _lineControls - 1) to 0 step -1 do {
				pr _ctrl = _lineControls select _i;
				_posy = _posy - CONTROL_HEIGHT(_ctrl); // - DIALOGUE_LINE_GAP;

				if (_posy < DIALOGUE_GAP) then {
					// Delete this control if it's outside of the group box
					_lineControlsToDelete pushBack _ctrl;
				} else {
					#ifndef _SQF_VM
					_ctrl ctrlSetPositionY _posy;
					#endif
					_ctrl ctrlCommit 0;
				};
			};
			// Delete lines which were marked for deletion
			{
				OOP_INFO_1("deleted line out of group box: %1", _x getVariable "_text");
				_lineControls deleteAt (_lineControls find _x);
				ctrlDelete _x;
			} forEach _lineControlsToDelete;
		} else {
			// There are no active sentences
			// Hide the UI?

		};
	ENDMETHOD;

	// Deletes pointers which point at units which have no more messages shown
	// Update positions of pointers
	METHOD(updatePointers)
		params [P_THISOBJECT];
		// Array of current speakers
		pr _speakersCurrent = T_GETV("lineControls") apply {_x getVariable "_speaker"};
		
		// Delete pointer controls which are pointing at objects
		// which are not one of current speakers
		pr _controls = T_GETV("pointerControls");
		pr _controlsToDelete = [];
		{
			pr _speaker = _x getVariable "_speaker";
			if (!(_speaker in _speakersCurrent) || !(alive _speaker)) then {
				_controlsToDelete pushBack _x;
			};
		} forEach _controls;
		{
			_controls deleteAt (_controls find _x);
			ctrlDelete _x;
		} forEach _controlsToDelete;

		// Update positions and text of controls
		{
			pr _ctrlIcon = _x;
			pr _speaker = _ctrlIcon getVariable "_speaker";
			
			#ifndef _SQF_VM
			pr _relDir = player getRelDir (getPosWorldVisual _speaker);
			#endif
			pr _xOffset = 0.45*safeZoneW*(sin _relDir);
			pr _yOffset = -0.04*safeZoneH*(cos _relDir);

			_ctrlIcon ctrlsetposition [
										_xOffset + DIALOGUE_POINTER_AREA_X - 0.5*DIALOGUE_POINTER_WIDTH,
										_yOffset + DIALOGUE_POINTER_AREA_Y];
			_ctrlIcon ctrlCommit 0;

			_ctrlIcon ctrlShow (!visibleMap);

			// Set text
			pr _imgPath = if ( (_relDir > 270) || (_relDir < 90) ) then {
				"\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa"
			} else {
				"\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa"
			};
			_ctrlIcon ctrlSetStructuredText (parseText format [
				"<t font='RobotoCondensed' align = 'center' size = '1'><t color = '#FFFFFF'><img image='%2'/><t color = '%1' shadow = '2'>%3<t size = '1'>%4</t>",
				_ctrlIcon getVariable "_unitColor",	// Precalculated
				_imgPath,
				"<br/>", // In case we need variable amount of line breaks
				_ctrlIcon getVariable "_unitName"	// Precalculated
			]);
		} forEach _controls;
	ENDMETHOD;

	// Private, creates a control for a line with text: a sentence or one of options
	// Returns the control
	METHOD(_createLineControl)
		params [P_THISOBJECT, P_STRING("_text"), P_NUMBER("_type"), P_OBJECT("_speaker")];

		disableSerialization;

		OOP_INFO_2("createLineControl: %1: %2", _speaker, _text);

		pr _ctrlGroup = T_GETV("ctrlGroup") select 0;

		pr _ctrlLine = (findDisplay 46) ctrlCreate ["RscTextMulti", -1, _ctrlGroup];
		//#ifdef DIALOGUE_LAYOUT_DEBUG
		_ctrlLine ctrlsetBackgroundColor [0, 0, 0, 0.55]; // can use for debug
		//#else
		//_ctrlLine ctrlsetBackgroundColor [0, 0, 0, 0];
		//#endif
		_ctrlLine ctrlSetTextColor [1, 1, 1, 1];
		_ctrlLine ctrlSetFontHeight 0.05;

		// Resolve only width and height now, position is updated elsewhere
		_ctrlLine ctrlSetPosition [DIALOGUE_GAP, 0, DIALOGUE_BOX_WIDTH-2*DIALOGUE_GAP, 0.1];
		_ctrlLine ctrlCommit 0;

		// Resolve text for control
		pr _textForControl = if (_type == LINE_TYPE_OPTION) then {
			_text;
		} else {
			if(player isEqualTo _speaker) then {
				format ["- %1", _text];
			}else{//some unit is talking to player
				format ["%1: %2", CALLSM1("DialogueClient", "getUnitName", _speaker), _text];
			};
		};
		_ctrlLine ctrlSetText _textForControl;

		// Set text and calculate height
		pr _height = (ctrlTextHeight _ctrlLine) + DIALOGUE_LINE_GAP + (safeZoneH*0.001);
		//_height = 0.1;
		#ifndef _SQF_VM
		_ctrlLine ctrlSetPositionH _height;
		#endif
		_ctrlLine ctrlCommit 0;
		OOP_INFO_1("  set line height: %1", _height);

		private _removeTime = if (_type == LINE_TYPE_SENTENCE) then {
			time + SENTENCE_DURATION(_text) + 5.0;
		} else {
			-1; // If it's an option then we don't care about time
		};
		_ctrlLine setVariable ["_removeTime",_removeTime];
		_ctrlLine setVariable ["_speaker", _speaker];
		_ctrlLine setVariable ["_type", _type];
		_ctrlLine setVariable ["_text", _text];

		OOP_INFO_1("  createdControl: %1", _ctrlLine);

		pr _lineControls = T_GETV("lineControls");
		_lineControls pushBack _ctrlLine;

	ENDMETHOD;

	// Private, creates the control for pointer
	METHOD(_createPointerControl)
		params [P_THISOBJECT, P_OBJECT("_speaker")];

		disableSerialization;

		OOP_INFO_1("createPointerControl: %1", _speaker);

		_ctrlIcon = (findDisplay 46) ctrlCreate ["rscstructuredtext", -1];
		// Initially it is created outside of view, its position will be updated later
		_ctrlIcon ctrlSetPosition [666, 0, DIALOGUE_POINTER_WIDTH, DIALOGUE_POINTER_HEIGHT];
		#ifdef DIALOGUE_LAYOUT_DEBUG
		_ctrlIcon ctrlSetBackgroundColor [0, 0.5, 0, 0.4];
		#else
		_ctrlIcon ctrlSetBackgroundColor [0, 0, 0, 0];
		#endif
		_ctrlIcon ctrlCommit 0;
		_ctrlIcon setVariable ["_speaker", _speaker];

		// Set structured text
		/*
		if(_count_breaks < 4)then{
			_count_breaks = _count_breaks +1;
			_breaks = _breaks + "<br/>";
		};
		*/

		// Evaluate color and unit name
		private _color_unit = CALLSM1("DialogueClient", "getUnitColor", _speaker);
		_ctrlIcon setVariable ["_unitColor", _color_unit];
		private _unitName = CALLSM1("DialogueClient", "getUnitName", _speaker);
		_ctrlIcon setVariable ["_unitName", _unitName];

		OOP_INFO_1("  created pointer control: %1", _ctrlIcon);
		
		T_GETV("pointerControls") pushBack _ctrlIcon;
	ENDMETHOD;

	// Creates a sentence and a compass pointer locally
	METHOD(_createSentence)
		params [P_THISOBJECT, P_OBJECT("_object"), P_STRING("_text")];

		OOP_INFO_1("_createSentence: %1", _this);

		// Evaluate if we need to create the pointer control
		// Array of current speakers
		pr _speakersCurrent = T_GETV("lineControls") apply {_x getVariable "_speaker"};
		if (!(_object in _speakersCurrent) && !(_object isEqualTo player)) then {
			T_CALLM1("_createPointerControl", _object);
		};

		T_CALLM3("_createLineControl", _text, LINE_TYPE_SENTENCE, _object);

	ENDMETHOD;




	// ==== OPTIONS

	METHOD(_createOptions)
		params [P_THISOBJECT, P_ARRAY("_options")];

		OOP_INFO_1("_createOptions: %1", _options);

		// Delete all lines
		T_CALLM0("_deleteAllLines");

		// Create lines for options
		pr _optionTags = [];
		{
			_x params ["_optionTag", "_optionText"];
			_optionTags pushBack _optionTag;
			OOP_INFO_1("create option: %1", _x);
			_optionText = format ["%1: %2", _forEachIndex + 1, _optionText];
			T_CALLM3("_createLineControl", _optionText, LINE_TYPE_OPTION, T_GETV("objectTalkTo"));
		} forEach _options;

		T_SETV("optionsShown", true);
		T_SETV("options", _optionTags);
	ENDMETHOD;

	public STATIC_METHOD(createOptions)
		params [P_THISCLASS, P_ARRAY("_options")];
		OOP_INFO_1("createOptions: %1", _options);
		pr _instance = CALLSM0(_thisClass, "getInstance");
		CALLM1(_instance, "_createOptions", _options);
	ENDMETHOD;

	METHOD(_selectOption)
		params [P_THISOBJECT, P_NUMBER("_optionID")];
		OOP_INFO_1("_selectOption: %1", _optionID);
		pr _options = T_GETV("options"); // Array with tags
		OOP_INFO_1("  current options: %1", _options);
		if ((_optionID >= 0) && (_optionID <= (count _options - 1))) then {
			pr _selectedTag = _options#_optionID;
			OOP_INFO_1("  selected tag: %1", _selectedTag);
			T_CALLM0("_deleteOptions");
			// Send data to server
			REMOTE_EXEC_CALL_METHOD(T_GETV("remoteDialogueRef"), "selectOption", [_optionID], ON_SERVER);
		} else {
			OOP_INFO_0("  option ID out of range");
		};
	ENDMETHOD;

	// Undoes what _createOptions does
	METHOD(_deleteOptions)
		params [P_THISOBJECT];
		T_CALLM0("_deleteOptionLines");
		T_SETV("optionsShown", false);
	ENDMETHOD;

	// Deletes all lines which have option type
	METHOD(_deleteOptionLines)
		params [P_THISOBJECT];

		// Delete sentences which are not needed any more
		pr _lineControls = T_GETV("lineControls");
		pr _lineControlsToDelete = _lineControls select {
			(_x getVariable "_type") == LINE_TYPE_OPTION;
		};
		{
			_lineControls deleteAt (_lineControls find _x);
			ctrlDelete _x;
		} forEach _lineControlsToDelete;
		_lineControlsToDelete = [];

	ENDMETHOD;

	// Deletes all line controls
	METHOD(_deleteAllLines)
		params [P_THISOBJECT];

		{
			ctrlDelete _x;
		} forEach T_GETV("lineControls");
		T_SETV("lineControls", []);
	ENDMETHOD;

	// ==== NEARBY OBJECT TALK HANDLER

	METHOD(_onObjectSaySentence)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogueRef"), P_OBJECT("_object"), P_STRING("_text")];

		pr _say = false;
		if (T_GETV("connected")) then {
			// If we are connected to a dialogue,
			// We only care about sentences said by the unit we are talking to
			if (_dialogueRef isEqualTo T_GETV("remoteDialogueRef")) then {
				_say = true;
			} else {
				// Just ignore it
			};
		} else {
			_say = true;
		};

		OOP_INFO_1("  sentence will be created: %1", _say);

		if (_say) then {
			T_CALLM2("_createSentence", _object, _text);
		};

	ENDMETHOD;

	// Called remotely on client when some unit nearby says something
	public STATIC_METHOD(onObjectSaySentence)
		params [P_THISCLASS, P_OOP_OBJECT("_dialogueRef"), P_OBJECT("_object"), P_STRING("_text")];

		OOP_INFO_1("onObjectSaySentence: %1", _this);

		pr _instance = CALLSM0(_thisClass, "getInstance");
		CALLM3(_instance, "_onObjectSaySentence", _dialogueRef, _object, _text);
	ENDMETHOD;



	// ==== UTILITY FUNCTIONS

	// Returns text color depending on unit side
	STATIC_METHOD(getUnitColor)
		params [P_THISCLASS, P_OBJECT("_unit")];

		#define BLUEFOR_COLOR "#0073e6"
		#define OPFOR_COLOR "#cc0000"
		#define CIVILIAN_COLOR "#b800e6"
		#define UNKNOWN_COLOR "#e6c700"
		#define ERROR_COLOR "#ff9900"

		//default 	[blufor, 	opfor, 		civilian,		sideEmpty]
		//			["#004C99",	"#800000",	"#660080",		"#B29900"]
		// i used https://www.w3schools.com/colors/colors_picker.asp to make brither colors

		private _index = [blufor, opfor, civilian] find side _unit;

		private _color = if(_index == -1)then{
			UNKNOWN_COLOR;
		}else{
			//if player doesnt know about the unit he doesnt know what side he is on
			//if(player knowsAbout _unit == 4)then{
				[BLUEFOR_COLOR, OPFOR_COLOR,CIVILIAN_COLOR] select _index;
			//}else{
				//UNKNOWN_COLOR;
			//};
		};

		_color;

	ENDMETHOD;

	STATIC_METHOD(getUnitName)
		params [P_THISCLASS, P_OBJECT("_unit")];
		if (isNull _unit) exitWith {"..."};

		pr _name = name _unit;
		if ("Error" in _name) then { // todo someone might actually have that name
			_name = getText (configFile >> "cfgVehicles" >> typeof _unit >> "displayName");
			if (_name == "") then {
				_name = "Object";
			};
		};

		_name;
	ENDMETHOD;


	// ==== CONNECTION  ====
	/*
	DialogueClient object must connect to a Dialogue object hosted by the server for a conversation to operate.
	Usual procedure is as follows:
	- Client wants to have a dialogue with an NPC
	- Server creates Dialogue object
	- Dialogue -> DialogueClient: requestConnect
	- DialogueClient -> Dialogue: acceptConnect or rejectConnect
	*/

	METHOD(_requestConnect)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogueRef"), P_OBJECT("_object")];

		OOP_INFO_1("_requestConnect: %1", _this);

		if (T_GETV("connected")) then {
			// If already connected, reject connection
			REMOTE_EXEC_CALL_METHOD(_dialogueRef, "rejectConnect", [], ON_SERVER);
		} else {
			T_SETV("connected", true);
			T_SETV("remoteDialogueRef", _dialogueRef);
			T_SETV("objectTalkTo", _object);
			REMOTE_EXEC_CALL_METHOD(_dialogueRef, "acceptConnect", [], ON_SERVER);
		};
	ENDMETHOD;

	METHOD(_disconnect)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogueRef")];

		OOP_INFO_1("_disconnect: %1", _this);

		if (T_GETV("connected") && (T_GETV("remoteDialogueRef") == _dialogueRef)) then {
			T_SETV("connected", false);
			T_SETV("remoteDialogueRef", NULL_OBJECT);
			T_SETV("objectTalkTo", objNull);

			// Shown options only make sense if we are connected
			// Therefore we must delete shown options
			T_CALLM0("_deleteOptions");
		} else {
			// Do nothing if disconnected already
		};
	ENDMETHOD;

	/*
	Remotely executed on client by the server.
	*/
	public STATIC_METHOD(requestConnect)
		params [P_THISCLASS, P_OOP_OBJECT("_dialogueRef"), P_OBJECT("_object")];

		OOP_INFO_1("requestConnect: %1", _this);

		pr _instance = CALLSM0(_thisClass, "getInstance");
		CALLM2(_instance, "_requestConnect", _dialogueRef, _object);
	ENDMETHOD;

	/*
	Remotely executed on client by the server if connection must be terminated.
	*/
	public STATIC_METHOD(disconnect)
		params [P_THISCLASS, P_OOP_OBJECT("_dialogueRef")];

		OOP_INFO_1("disconnect: %1", _this);

		pr _instance = CALLSM0(_thisClass, "getInstance");
		CALLM1(_instance, "_disconnect", _dialogueRef);
	ENDMETHOD;





	// ==== Player actions

	// Condition for talk action
	DialogueClient_fnc_talkActionCondition = {
		pr _co = cursorObject;

		// Bail if not looking at anything
		if (isNull _co) exitWith {false;};

		// Bail if unconscious or anything like that
		// todo

		// Bail if target is not alive or unconscious
		if (!alive _co || {lifestate _co == "INCAPACITATED"}) exitWith {false;};

		// Bail if target is not man, or is player
		if (!(_co isKindOf "CAManBase") || {isPlayer _co}) exitWith {false;};

		// Bail if target is too far
		if ((player distance _co) > 4.5) exitWith {false;};

		// Check if player is talking already
		pr _instance = CALLSM0("DialogueClient", "getInstance");

		// We can start a new dialogue if not talking to anyone right now
		pr _return = !GETV(_instance, "connected");

		_return;
	};

	// Initializes action to talk to bots for player
	STATIC_METHOD(initPlayerAction)
		params [P_THISCLASS];

		// Script to run when action is activated
		private _scriptRun = {
			params ["_target", "_caller", "_actionId", "_arguments"];

			pr _args = [cursorObject, player, clientOwner];
			REMOTE_EXEC_CALL_STATIC_METHOD("Dialogue", "requestStartNewDialogue", _args, ON_SERVER, false);
		};

		player addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
			_scriptRun, // Script
			0, // Arguments
			100, // Priority
			true, // ShowWindow
			false, //hideOnUse
			"", //shortcut
			"call DialogueClient_fnc_talkActionCondition;", //condition
			-1, //radius
			false, //unconscious
			"", //selection
			"" // memory point
		];
	ENDMETHOD;


ENDCLASS;

if (isNil {GETSV("DialogueClient", "instance")}) then {
	SETSV("DialogueClient", "instance", NULL_OBJECT);
};
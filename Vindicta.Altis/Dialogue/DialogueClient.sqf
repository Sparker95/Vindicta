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
	VARIABLE("serverDialogueRef");

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

	METHOD(new)
		params [P_THISOBJECT];

		disableSerialization;

		if (!hasInterface) exitWith {
			OOP_ERROR_0("DialogueClient must be created on client");
		};

		T_SETV("serverDialogueRef", NULL_OBJECT);
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
		pr _ctrlTest = (findDIsplay 46) ctrlCreate ["RscText", 123123, _ctrlGroup];
		_ctrlTest ctrlSetPosition [0, 0, DIALOGUE_BOX_WIDTH-0.001, DIALOGUE_BOX_HEIGHT-0.001];
		_ctrlTest ctrlSetBackgroundColor [0.2, 0, 0, 0.3];
		_ctrlTest ctrlCommit 0;

		// Create the compass

		// Create the per frame handler
		pr _id = addMissionEventHandler ["Draw3D", {
			pr _instance = CALLSM0("DialogueClient", "getInstance");
			//OOP_INFO_1("draw3d, instance: %1", _instance);
			CALLM0(_instance, "onEachFrame");
		}];
		T_SETV("ehID", _id);
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
		removeMissionEventHandler ["Draw3D", T_GETV("ehID")];
	ENDMETHOD;

	// Called on each frame
	public METHOD(onEachFrame)
		params [P_THISOBJECT];

		//OOP_INFO_0("onEachFrame");

		T_CALLM0("updateLines");
		T_CALLM0("updatePointers");
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
				_posy = _posy - CONTROL_HEIGHT(_ctrl) - DIALOGUE_LINE_GAP;

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

		// Update positions of controls
		{
			pr _ctrlIcon = _x;
			pr _speaker = _ctrlIcon getVariable "_speaker";
			
			pr _relDir = player getRelDir _speaker;
			pr _xOffset = 0.4*safeZoneW*(sin _relDir);
			pr _yOffset = 0.05*safeZoneH*(cos _relDir);

			_ctrlIcon ctrlsetposition [
										_xOffset + DIALOGUE_POINTER_AREA_X + 0.5*DIALOGUE_POINTER_WIDTH,
										_yOffset + DIALOGUE_POINTER_AREA_Y];
			_ctrlIcon ctrlCommit 0;
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
		_ctrlLine ctrlsetBackgroundColor [0, 0, 0, 0.3];
		_ctrlLine ctrlSetTextColor [1, 1, 1, 1];
		_ctrlLine ctrlSetFontHeight 0.05;

		// Resolve only width and height now, position is updated elsewhere
		_ctrlLine ctrlSetPosition [DIALOGUE_GAP, 0, DIALOGUE_BOX_WIDTH-2*DIALOGUE_GAP, 0.1];
		_ctrlLine ctrlCommit 0;

		// Create structured text
		if(player isEqualTo _speaker) then {
			_ctrlLine ctrlSetText (format ["- %1", _text]);
		}else{//some unit is talking to player
			_ctrlLine ctrlSetText (format ["%1: %2", CALLSM1("DialogueClient", "getUnitName", _speaker), _text]);
		};

		// Set text and calculate height
		pr _height = ctrlTextHeight _ctrlLine;
		//_height = 0.1;
		#ifndef _SQF_VM
		_ctrlLine ctrlSetPositionH _height;
		#endif
		_ctrlLine ctrlCommit 0;
		OOP_INFO_1("  set line height: %1", _height);

		private _removeTime = if (_type == LINE_TYPE_SENTENCE) then {
			time + SENTENCE_DURATION(_text) + 10.0;
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

		OOP_INFO_1("_createPointerControl: %1", _speaker);

		_ctrlIcon = _display ctrlCreate ["rscstructuredtext", -1, _hud];
		// Initially it is created outside of view, its position will be updated later
		_ctrlIcon ctrlSetPosition [666, 0, DIALOGUE_POINTER_WIDTH, DIALOGUE_POINTER_HEIGHT];
		_ctrlIcon ctrlCommit 0;
		_ctrlIcon setVariable ["_speaker", _speaker];

		// Set structured text
		/*
		if(_count_breaks < 4)then{
			_count_breaks = _count_breaks +1;
			_breaks = _breaks + "<br/>";
		};
		*/

		private _color_unit = CALLSM1("DialogueClient", "getUnitColor", _speaker);
		_ctrl_icon ctrlSetStructuredText parseText format [
			"<t font='RobotoCondensed' align = 'center' size = '1'><t color = '#FFFFFF'>"+
			"<img image='%2'/><t color = '%1' shadow = '2'>%3<t size = '1'>%4</t>",
			_color_unit,
			"\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
			"", // It might contain line breaks (not sure if they are needed yet)
			CALLSM1("DialogueClient", "getUnitName", _speaker)
		];
		
		T_GETV("pointerControls") pushBack _ctrlIcon;
	ENDMETHOD;

	// Creates a sentence locally
	public METHOD(createSentence)
		params [P_THISOBJECT, P_OBJECT("_unit"), P_STRING("_text")];



	ENDMETHOD;

	public METHOD(createOptions)
		params [P_THISOBJECT, P_ARRAY("_options")];
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
		params [P_THISOBJECT, P_OBJECT("_unit")];
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

ENDCLASS;

if (isNil {GETSV("DialogueClient", "instance")}) then {
	SETSV("DialogueClient", "instance", NULL_OBJECT);
};
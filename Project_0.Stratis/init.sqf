/*
Dirty init.sqf
add inits here until it's so fucked up, then redo it all over again
*/



//==== Locations initialization
//player allowDamage false;

#include "OOP_Light\OOP_Light.h"
#include "Message\Message.hpp"
#include "CriticalSection\CriticalSection.hpp"

// Initialize OOP classes and other things
//call compile preprocessFileLineNumbers "initModules.sqf";

// If a client, wait for the server to finish its initialization
if(! isServer) then {
	diag_log "Waiting for server init...";
	systemChat "Waiting for server initialization...";
	
	waitUntil {! isNil "serverInitDone"};
	
	systemChat "Server initialization completed!";
	diag_log "Server initialization completed!";
};

// Initialize global objects in unscheduled
CRITICAL_SECTION_START

diag_log "Init.sqf: Creating global objects...";

// Init global objects

// Main timer service
gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution


// Headless clients and server only
if (isServer || (!hasInterface && !isDedicated)) then {
	// Main message loop for garrisons
	gMessageLoopMain = NEW("MessageLoop", []);
	CALL_METHOD(gMessageLoopMain, "setDebugName", ["Main thread"]);
	
	// Global debug printer for tests
	private _args = ["TestDebugPrinter", gMessageLoopMain];
	gDebugPrinter = NEW("DebugPrinter", _args);
	
	// Message loop for group AI
	gMessageLoopGroupAI = NEW("MessageLoop", []);
	CALL_METHOD(gMessageLoopGroupAI, "setDebugName", ["Group AI thread"]);
	
	// Message loop for Stimulus Manager
	gMessageLoopStimulusManager = NEW("MessageLoop", []);
	CALL_METHOD(gMessageLoopStimulusManager, "setDebugName", ["Stimulus Manager thread"]);
	
	// Global Stimulus Manager
	gStimulusManager = NEW("StimulusManager", []);
	
	// Message loop for locations
	gMessageLoopLocation = NEW("MessageLoop", []);
	CALL_METHOD(gMessageLoopLocation, "setDebugName", ["Location thread"]);
	
	// Location unit array provider
	gLUAP = NEW("LocationUnitArrayProvider", []);
	// Create a timer for gLUAP
	private _msg = MESSAGE_NEW();
	_msg set [MESSAGE_ID_DESTINATION, gLUAP];
	_msg set [MESSAGE_ID_SOURCE, ""];
	_msg set [MESSAGE_ID_DATA, 666];
	_msg set [MESSAGE_ID_TYPE, 666];
	private _args = [gLUAP, 2, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
	private _LUAPTimer = NEW("Timer", _args);
};

// Server only
if (isServer) then {

	// Message loops for commander AI
	gMessageLoopCommanderWest = NEW("MessageLoop", []);
	gMessageLoopCommanderInd = NEW("MessageLoop", []);
	gMessageLoopCommanderEast = NEW("MessageLoop", []);
	
	// Commander AIs
	// West
	gCommanderWest = NEW("Commander", []);
	private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
	gAICommanderWest = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderWest";
	// Independent
	gCommanderInd = NEW("Commander", []);
	private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
	gAICommanderInd = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderInd";
	// East
	gCommanderEast = NEW("Commander", []);
	private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
	gAICommanderEast = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderEast";


	// Create locations and other things
	diag_log "Init.sqf: Calling initWorld...";
	call compile preprocessFileLineNumbers "Init\initWorld.sqf";
	
	// Add friendly locations to commanders
	// And start them
	{
		CALLM0(_x, "updateFriendlyLocationsData");
		CALLM1(_x, "setProcessInterval", 10);
		CALLM0(_x, "start");
	} forEach [gAICommanderWest, gAICommanderInd, gAICommanderEast];
};


// Headless Clients only
if (!hasInterface && !isDedicated) then {
	private _str = format ["Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner];
	diag_log _str;
	systemChat _str;
	
	// Test: ask the server to create an object and pass it to this computer
	[clientOwner, {
		private _remoteOwner = _this;
		diag_log format ["---- Connected headless client with owner ID: %1. RemoteExecutedOwner: %2, isRemoteExecuted: %3", _remoteOwner, remoteExecutedOwner, isRemoteExecuted];
		diag_log format ["all players: %1, all headless clients: %2", allPlayers, entities "HeadlessClient_F"];
		diag_log format ["Owners of headless clients: %1", (entities "HeadlessClient_F") apply {owner _x}];
		
		private _args = ["Remote DebugPrinter test", gMessageLoopMain];
		remoteDebugPrinter = NEW("DebugPrinter", _args);
		CALLM(remoteDebugPrinter, "setOwner", [_remoteOwner]); // Transfer it to the machine that has connected
		diag_log format ["---- Created a debug printer for the headless client: %1", remoteDebugPrinter];
		
	}] remoteExec ["spawn", 2, false];
};

// Only players
if (hasInterface) then {
	diag_log "----- Player detected!";
	[] spawn {
		waitUntil {!((finddisplay 12) isEqualTo displayNull)};
		systemChat "Player detected!";
		[] spawn compile preprocessfilelinenumbers "onPlayerSpawn.sqf";
	};
};

diag_log "Init.sqf: Init done!";



/*
[] spawn {

while {true}do{

	waituntil {isnull (findDisplay 316000) && {isnull findDisplay 49}};
	waituntil {!isnull (findDisplay 316000) || {!isnull findDisplay 49}};

	_display = findDisplay 316000;
			if(isnull _display)then{_display = findDisplay 49};//ingame
			if(isnull _display)exitWith{};
			

	_ctrl_debug = _display displayCtrl 13184; 
	_pos_debug = ctrlposition _ctrl_debug;// [x, y, w, h] 
	_pos_debug set [2, 1-safeZoneX- _pos_debug#0-0.03];
	_ctrl_debug ctrlSetPosition _pos_debug; 
	_ctrl_debug ctrlCommit 0;


	
	_ctrl_expressionBackground = _display displayCtrl 11885;
	_pos_expressionBackground = ctrlposition _ctrl_expressionBackground;// [x, y, w, h]
	_pos_expressionBackground set [2,_pos_debug#2];
	_ctrl_expressionBackground ctrlSetPosition _pos_expressionBackground; 
	_ctrl_expressionBackground ctrlCommit 0;

	_ctrl_expression = _display displayCtrl 12284;
	_pos_expression = ctrlposition _ctrl_expression;// [x, y, w, h] 
	_pos_expression set [2,_pos_debug#2 - (_pos_expression#0 *2)];
	_ctrl_expression ctrlSetPosition _pos_expression; 
	_ctrl_expression ctrlCommit 0;

	_ctrl_expressionText = _display displayCtrl 11892;
	_pos_expressionText = ctrlposition _ctrl_expressionText;// [x, y, w, h] 
	_pos_expressionText set [2,_pos_expression#2];
	_ctrl_expressionText ctrlSetPosition _pos_expressionText; 
	_ctrl_expressionText ctrlCommit 0;

	_ctrl_expressionOutputBackground = _display displayCtrl 13191;
	_pos_expressionOutputBackground = ctrlposition _ctrl_expressionOutputBackground;
	_pos_expressionOutputBackground set [2,_pos_expression#2];
	_ctrl_expressionOutputBackground ctrlSetPosition _pos_expressionOutputBackground; 
	_ctrl_expressionOutputBackground ctrlCommit 0;

	_ctrl_expressionOutput = _display displayCtrl 13190;
	_ctrl_expressionOutput ctrlSetPosition _pos_expressionOutputBackground; 
	_ctrl_expressionOutput ctrlCommit 0;

	_ctrl_title = _display displayCtrl 11884; 
	_pos_title = ctrlposition _ctrl_title;
	_pos_title set [2,_pos_expressionBackground#2];
	_ctrl_title ctrlSetPosition _pos_title; 
	_ctrl_title ctrlCommit 0;
	_ctrl_title ctrlsettext "Ultra Wide Extended Debug Console With Extra Save Buttens!";
	
	_ctrl_watchBackground = _display displayCtrl 11886;
	_pos_watchBackground = ctrlposition _ctrl_watchBackground;

	_ctrl_localButton = _display displayCtrl 13484;
	_pos_localButton = ctrlposition _ctrl_localButton; // [x, y, w, h]
	_button_hieght = _pos_localButton#3;
	
	_ctrl_nextButton = _display displayCtrl 90111;
	_pos_nextButton = ctrlposition _ctrl_nextButton;
	
	
	_spacingY =  (_pos_localButton#1 - _pos_nextButton#1)-_button_hieght ;
	_posXFINAL = _pos_watchBackground #0 + _pos_watchBackground #2  + _spacingY;
	_posY = _pos_expressionBackground #1 + _pos_expressionBackground #3 + _spacingY;
	
	
	uiNameSpace setVariable ["jn_debugConsole_expression",_ctrl_expression];
	uiNameSpace setVariable ["jn_debugConsole_buttons",[]];
	
	private _array = [
			[
				"<t align='left'>save</t>",
				0.01,
				0.5,
				{
					params ["_index"];
					
					_text = ctrltext (UiNameSpace getVariable "jn_debugConsole_expression");
					_name = "no name";
					if(_text find "//" == 0)then{
						_enter = _text find (toString [10]);
						if(_enter >0)then{
							_name = _text select [2, _enter-2];
						};
					};
					diag_log ["Save",_text];
					profilenamespace setVariable [format ["jn_debugConsole_%1",_index],_text];
					profilenamespace setVariable [format ["jn_debugConsole_%1_name",_index],_name];
					((UiNameSpace getVariable "jn_debugConsole_buttons") # _index) ctrlSetStructuredText parseText format["<t align='left'>Save (%1)</t>",_name];
				}
			],[
				"<t align='left'>Load</t>",
				0.01,
				0.10,
				{
					params ["_index"];
					_text = profilenamespace getVariable [format["jn_debugConsole_%1",_index],""];
					(UiNameSpace getVariable "jn_debugConsole_expression") ctrlsettext _text;
				}
			],[
				"<t align='left'>Run</t>",
				0.01,
				0.09,
				{
					params ["_index"];
					_text = profilenamespace getVariable [format["jn_debugConsole_%1",_index],""];
					diag_log _text;
				}
			],[
				"<t align='left'>Delete</t>",
				0.1,
				0.12,
				{
					params ["_index"];
					profilenamespace setVariable [format ["jn_debugConsole_%1",_index],nil];
					profilenamespace setVariable [format ["jn_debugConsole_%1_name",_index],nil];
					((UiNameSpace getVariable "jn_debugConsole_buttons") # _index) ctrlSetStructuredText parseText format["<t align='left'>Save</t>",_name];
				}
			]
	];
	
	for "_index" from 0 to 9 do{
		if(_posY>22)exitWith{};
		_posX = _posXFINAL;
		_nameP = profilenamespace getVariable [format['jn_debugConsole_%1_name',_index],""];
		{
			_x params ["_name","_button_spacing","_button_width","_code"];

			_ctrl = _display ctrlCreate ["RscShortcutButton", -1,_ctrl_debug];
			_ctrl ctrlSetPosition [_posX,_posY,_button_width,_button_hieght];
			_ctrl ctrlCommit 0;

			if(_foreachIndex == 0)then{
				if(_nameP != "")then{_name = format["%1 (%2)",_name,_nameP]};
				_buttonArray = UiNameSpace getVariable ["jn_debugConsole_buttons",[]];
				_buttonArray pushBack _ctrl;
			};
			
			_ctrl ctrlSetStructuredText parseText _name;
			_ctrl ctrlAddEventHandler ["ButtonClick", format["%1 call %2",_index,_code]];
			
			
			_posX = _posX + _button_width + _spacingY;
		}forEach _array;
		_posY = _posY + _spacingY + _button_hieght;
	};
	
}

};
*/

serverInitDone = 1;
publicVariable "serverInitDone";

CRITICAL_SECTION_END
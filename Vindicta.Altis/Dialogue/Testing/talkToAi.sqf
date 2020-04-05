//Spawn talk loop
("VoiceArmaDll" callExtension "@start" );

_handle= missionNameSpace getVariable "speech_loop";
if(!isnil "_handle")then{terminate _handle};

_handle = [] spawn {
	while{true}do{

		_text = ("VoiceArmaDll" callExtension "" ) ;
		if(_text != "")then{
			_t = _text splitString ":";
			hint _text;
		};

		sleep 0.1;

	};
};
missionNameSpace setVariable ["speech_loop",_handle ];
_handle









//stop talk loop
_handle= missionNameSpace getVariable "speech_loop";
if(!isnil "_handle")then{terminate _handle};










//set text to recognize 
("VoiceArmaDll" callExtension "@setGrammar test,hello" )















//start example
("VoiceArmaDll" callExtension "@start" );

_handle= missionNameSpace getVariable "speech_loop";
if(!isnil "_handle")then{terminate _handle};

_array = "follow me";

("VoiceArmaDll" callExtension format["@setGrammar %1",_array]);

_handle = [] spawn {
	while{true}do{

		_text = ("VoiceArmaDll" callExtension "" ) ;
		if(_text != "")then{
			_t = _text splitString ":";
			hint str _text;
			
			if(parsenumber (_t#1)<0.90)exitWith{};
			_text = _t#0;
			//hint str ["command",_text];
			if(_text isEqualTo "follow me")exitWith{
				_actionClassName = "ActionUnitMoveToDanger";
				_parameters = player;
				_interval = 1;
				call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
				_Action = [_unit, _actionClassName, _parameters, _interval] call AI_misc_fnc_forceUnitAction;
				_action
				
			};

			
		};

		sleep 0.1;

	};
};
missionNameSpace setVariable ["speech_loop",_handle ];
_handle







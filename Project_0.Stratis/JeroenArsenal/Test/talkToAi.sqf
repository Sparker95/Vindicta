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

_array = "get down,get up,everyone get down,everyone get up,shoot this guy,whos roo daa";

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
			if(_text isEqualTo "get down")exitWith{cursorObject setUnitPos "DOWN"};
			if(_text isEqualTo "hey you"|| {_text isEqualTo "look at me"})exitWith{cursorObject lookAt getpos player, cursorObject doTarget player;};
			if(_text isEqualTo "get up" || {_text isEqualTo "stand up"})exitWith{cursorObject setUnitPos "UP"};
			
			if(_text isEqualTo "everyone get down" || {_text isEqualTo "everyone down"})exitWith{{_x setUnitPos "DOWN"}forEach allunits - [player] };
			if(_text isEqualTo "everyone get up" || {_text isEqualTo "everyone up"})exitWith{{_x setUnitPos "UP"}forEach allunits - [player] };
			
			if(_text isEqualTo "shoot me")exitWith{cursorObject doTarget player; cursorObject doSuppressiveFire player;};
			
			if(_text isEqualTo "shoot this guy" || {_text isEqualTo "somone shoot this guy"})exitWith{cursorObject addRating -20000;};
			
			if(_text isEqualTo "hello")exitWith{("VoiceArmaDll" callExtension "How are you?")};
			if(_text isEqualTo "whos roo daa"||{_text isEqualTo "fus ro da"})exitWith{
				0 = ["ChromAberration", 200, [0.05, 0.05, true]] spawn {
					params ["_name", "_priority", "_effect", "_handle"];
					while {
						_handle = ppEffectCreate [_name, _priority];
						_handle < 0
					} do {
						_priority = _priority + 1;
					};
					_handle ppEffectEnable true;
					_handle ppEffectAdjust _effect;
					_handle ppEffectCommit 5;
					waitUntil {ppEffectCommitted _handle};
					systemChat "admire effect for a sec";
					uiSleep 3;
					_handle ppEffectEnable false;
					ppEffectDestroy _handle;
				};
			
				cursorObject setdammage 1
			};
			
		};

		sleep 0.1;

	};
};
missionNameSpace setVariable ["speech_loop",_handle ];
_handle







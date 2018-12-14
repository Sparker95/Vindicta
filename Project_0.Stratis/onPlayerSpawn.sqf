//todo redo this crap
//it just waits until the map display is available meaning that we can manipulate the map display now

#include "UI\UICommanderIDC.hpp"
#define pr private

(finddisplay 12) ctrlCreate ["group_data_group_0", IDC_GROUP_DATA_GROUP_DATA_GROUP_0];
//(finddisplay 12) ctrlCreate ["group_data_group_1", IDC_GROUP_DATA_GROUP_DATA_GROUP_0];
(findDisplay 12) displayAddEventHandler["KeyDown",
{
	diag_log format ["KeyDown: %1", _this];
	if(_this select 1 == 21) then
	{
		call compile preprocessfilelinenumbers "UI\showGroupControl.sqf";
	};
	false}
];
[] spawn compile preprocessfilelinenumbers "UI\commanderUIUpdate.sqf";



// Trigger some code when player salutes
/*
saluteKeys = actionKeys "Salute";
(findDisplay 46) displayAddEventHandler["KeyDown", {
	if ((_this select 1) in saluteKeys) then {
		systemChat "Hello, soldier!";
	};
}];*/

#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"
#include "OOP_Light\OOP_Light.h"

player addEventHandler ["AnimChanged", {
	params ["_unit", "_anim"];
	
	//systemChat format ["AnimChanged to : %1", _anim];
	//diag_log format ["AnimChanged to : %1", _anim];
	
	if (_anim == "amovpercmstpslowwrfldnon_salute" || _anim == "amovpercmstpsraswrfldnon_salute" ||
		_anim == "amovpercmstpsraswpstdnon_salute") then {                                           
		systemChat "You salute to everyone!";
		
		// Create a salute stimulus
		private _stim = STIMULUS_NEW();
		STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNIT_SALUTE);
		STIMULUS_SET_SOURCE(_stim, player);
		STIMULUS_SET_POS(_stim, getPos player);
		STIMULUS_SET_RANGE(_stim, 4);
		//_stim set [STIMULUS_ID_EXPIRATION_TIME, 10];
		// Send the stimulus to the stimulus manager
		private _args = ["handleStimulus", [_stim]];
		CALLM(gStimulusManager, "postMethodAsync", _args);
	};
}];

//player setUnitTrait ["audibleCoef",0,true];
//player setUnitTrait ["camouflageCoef",0,true];
Civilian setFriend [West , 0];

#define TRIGGER_DISTANCE 10
#define INTERVAL 0.5

while {true}do{
	//civilians are enemy with opfor but opfor is not enemies with civilian
	pr _nearestEnemy = player findNearestEnemy player;
	if(!isNull _nearestEnemy)then{
		pr _dis = _nearestEnemy distance player;
		if(_dis < TRIGGER_DISTANCE)then{
		
			// Create a salute stimulus
			pr _stim = STIMULUS_NEW();
			STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNIT_CIV_NEAR);
			STIMULUS_SET_SOURCE(_stim, player);
			STIMULUS_SET_VALUE(_stim, 1-(_dis/TRIGGER_DISTANCE));

			diag_log "NearEnemy trigger";
			
			// Send the stimulus to unit directly TODO maybe send it to group
			pr _oh = CALLSM("unit","getUnitFromObjectHandle",[_nearestEnemy]);
			pr _ai = CALLM(_oh,"getAI",[]);
			CALLM(_ai,"handleStimulus",[_stim]);
		};
	};
	
	sleep INTERVAL;
};
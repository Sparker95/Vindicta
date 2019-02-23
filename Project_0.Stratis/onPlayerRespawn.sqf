#include "OOP_Light\OOP_Light.h"
#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"

/*
This is an event script.
https://community.bistudio.com/wiki/Event_Scripts

Executed locally when player respawns in a multiplayer mission.
This event script will also fire at the beginning of a mission if respawnOnStart is 0 or 1,
oldUnit will be objNull in this instance.
This script will not fire at mission start if respawnOnStart equals -1.
*/

#define pr private

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

// Make sure server initialization is done
waitUntil {
	diag_log format ["---- onPlayerRespawn: waiting server init, time: %1", diag_tickTime];
	! isNil "serverInitDone"
};
diag_log format ["---- onPlayerRespawn: server init done, time: %1", diag_tickTime];

diag_log format ["------- onPlayerRespawn %1", _this];

// Execute script on the server
_this remoteExec ["fnc_onPlayerRespawnServer", 2, false];

//waitUntil {!((finddisplay 12) isEqualTo displayNull)};


// Trigger some code when player salutes
/*
saluteKeys = actionKeys "Salute";
(findDisplay 46) displayAddEventHandler["KeyDown", {
	if ((_this select 1) in saluteKeys) then {
		systemChat "Hello, soldier!";
	};
}];*/

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

		[_args, {CALLM(gStimulusManager, "postMethodAsync", _this);}] remoteExecCall["call", 0, false];
	};
}];

//player setUnitTrait ["audibleCoef",0,true];
//player setUnitTrait ["camouflageCoef",0,true];
//Civilian setFriend [West , 0];

#define TRIGGER_DISTANCE 10
#define INTERVAL 0.5

/*
[] spawn {
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
};
*/

// Create a suspiciousness monitor for player
NEW("undercoverMonitor", [player]);

// Create camp scroll menu
player addAction ["Create Camp", "Camp\createCamp.sqf"];

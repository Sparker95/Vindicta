#include "OOP_Light\OOP_Light.h"
#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"
#include "CivilianPresence\CivilianPresence.hpp"
#include "Location\Location.hpp"
#include "AI\Commander\AICommander.hpp"
#include "AI\Commander\LocationData.hpp"

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
diag_log format ["---- onPlayerRespawn: waiting server init, time: %1", diag_tickTime];
waitUntil {
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
NEW("UndercoverMonitor", [player]);

// Create scroll menu to talk to civilians
pr0_fnc_talkCond = { // I know I overwrite it every time but who cares now :/
    private _co = cursorObject;
    (!isNil {_co getVariable CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME}) && ((_target distance _co) < 3) 
};

_civDialogue = {
    private _co = cursorObject;
    player globalChat "Tell me if you know something!";

    sleep 0.8;

    if (!alive _co) exitWith {
        _co globalChat "How can I talk if you have killed me you asshole!";
    };

    _co globalChat "Let me think...";
    sleep (0.5+random 1);
    
    // Check nearby locations
    private _locs = CALLSM0("Location", "getAll");
    private _locsNear = _locs select {
        CALLM0(_x, "getPos") distance player < 3000
    };

    if (count _locsNear == 0) then {
        _co globalChat "I don't know anything!";
    } else {
        _co globalChat "I think I know something...";
        diag_log format ["---- Civilian told about locations:"];
        {
            //[CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
            // Civilians know about police stations in cities
            // And have limited knowledge about military facilities around
            pr _type = CALLM0(_x, "getType");
            private _updateLevel = -666;
            private _accuracyRadius = 0;
            private _dist = CALLM0(_x, "getPos") distance player;
            private _distCoeff = 0.1; // How much accuracy radius increases with  distance
            diag_log format ["   %1 %2", _x, _type];

            switch (_type) do {
                case LOCATION_TYPE_CITY: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
                case LOCATION_TYPE_POLICE_STATION: {_updateLevel = CLD_UPDATE_LEVEL_SIDE; };
                case LOCATION_TYPE_ROADBLOCK: {
                    if (GETV(_x, "isBuilt")) then {_updateLevel = CLD_UPDATE_LEVEL_SIDE;
                    _accuracyRadius = 50+_dist*_distCoeff; };
                };
                case LOCATION_TYPE_CAMP: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
                case LOCATION_TYPE_BASE: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
                case LOCATION_TYPE_OUTPOST: {_updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; _accuracyRadius = 50+_dist*_distCoeff; };
            };

            if (_updateLevel != -666) then {
                diag_log format ["    adding to database"];
                private _commander = CALLSM1("AICommander", "getCommanderAIOfSide", playerSide);
			    CALLM2(_commander, "postMethodAsync", "updateLocationData", [_x ARG _updateLevel ARG sideUnknown ARG false ARG false ARG _accuracyRadius]);
            };
        } forEach _locsNear;
    };
};

player addAction ["Talk to civilian", // title
                 _civDialogue, // Script
                 0, // Arguments
                 9000, // Priority
                 true, // ShowWindow
                 false, //hideOnUse
                 "", //shortcut
                 "call pr0_fnc_talkCond", //condition
                 2, //radius
                 false, //unconscious
                 "", //selection
                 ""]; //memoryPoint

// Init the UnitIntel on player
CALLSM1("UnitIntel", "initPlayer", player);

CALLM(gGameMode, "playerSpawn", _this);
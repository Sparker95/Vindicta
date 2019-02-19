#include "..\UI_OOP\oop.h"

#define pr private

_id = ["MainLayer"] call BIS_fnc_rscLayer;
_id cutRsc ["UIUndercoverDebug", "PLAIN", -1, false];

// create the dialog like this:
// cutRsc ["NewDialog", "PLAIN", -1, false];

// Then activate this script like this:
// call compile preprocessfilelinenumbers "testDialogUpdate.sqf";


[] spawn {
params["_unit"];

	while {true} do {
		sleep 0.3;

		pr _suspicion = player getVariable "suspicion";
		pr _ctrl = "getOOP_Text_101_Susp" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Suspicion: %1", _suspicion];

		pr _timeHostilityDebug = player getVariable "timeHostilityDebug";
		if (isNil "_timeHostilityDebug") then { _timeHostilityDebug = "UNDEF"};
		_ctrl = "getOOP_Text_101_LastSpottedTimes" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Last hostility time: %1", _timeHostilityDebug];

		pr _distance = player getVariable "nearestEnemyDist";
		if (isNil "_distance") then { _distance = "UNDEF"};
		_ctrl = "getOOP_Text_101_Distance" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Distance Nearest Enemy: %1", _distance];

		pr _bSeen = player getVariable "bSeen";
		_ctrl = "getOOP_Text_101_Seen" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Seen: %1", _bSeen];
		if (_bSeen) then { 
			_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
			_ctrl ctrlSetTextColor [0, 0, 0, 1];  
			_ctrl ctrlCommit 0;
		};

		if !(_bSeen) then {
			_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
			_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
			_ctrl ctrlCommit 0; 
		};

		pr _bInVeh = player getVariable "bInVeh";
		_ctrl = "getOOP_Text_101_InVeh" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["In Veh: %1", _bInVeh];
		if (_bInVeh) then { 
			_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
			_ctrl ctrlSetTextColor [0, 0, 0, 1];  
			_ctrl ctrlCommit 0;
		};

		if !(_bInVeh) then {
			_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
			_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
			_ctrl ctrlCommit 0; 
		};

		pr _suspGearVeh = player getVariable "suspGearVeh";
		_ctrl = "getOOP_Text_101_SuspVeh" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Susp Gear Veh: %1", _suspGearVeh];

		pr _bWanted = player getVariable "bWanted";
		_ctrl = "getOOP_Text_101_Wanted" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Wanted: %1", _bWanted];
		if (_bWanted) then { 
			_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
			_ctrl ctrlSetTextColor [0, 0, 0, 1];  
			_ctrl ctrlCommit 0;
		};

		if !(_bWanted) then {
			_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
			_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
			_ctrl ctrlCommit 0; 
		};

		pr _suspGear = player getVariable "suspGear";
		if (isNil "_suspGear") then { _suspGear = "UNDEF"};
		_ctrl = "getOOP_Text_101_SuspGear" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Susp Gear: %1", _suspGear];

		pr _bodyExposure = player getVariable "bodyExposure";
		if (isNil "_bodyExposure") then { _bodyExposure = "UNDEF"};
		_ctrl = "getOOP_Text_101_BodyExp" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Body Exposure: %1", _bodyExposure];

		pr _timeSeenDebug = player getVariable "timeSeenDebug";
		if (isNil "_timeSeenDebug") then { _timeSeenDebug = "UNDEF"};
		_ctrl = "getOOP_Text_101_TimeUnseen" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Unseen in: %1 seconds", _timeSeenDebug];

		pr _suspicious = player getVariable "bSuspicious";
		if (isNil "_suspicious") then { _suspicious = "UNDEF"};
		_ctrl = "getOOP_Text_101_Suspicious" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Suspicious: %1", _suspicious];
		if (_suspicious) then { 
			_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
			_ctrl ctrlSetTextColor [0, 0, 0, 1];  
			_ctrl ctrlCommit 0;
		};

		if !(_suspicious) then {
			_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
			_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
			_ctrl ctrlCommit 0; 
		};

		pr _bInMarker = player getVariable "bInMarker";
		if (isNil "_bInMarker") then { _bInMarker = "UNDEF"};
		_ctrl = "getOOP_Text_101_InVehMil" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["bInMarker: %1", _bInMarker];
		if (_bInMarker) then { 
			_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
			_ctrl ctrlSetTextColor [0, 0, 0, 1];  
			_ctrl ctrlCommit 0;
		};

		if !(_bInMarker) then {
			_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
			_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
			_ctrl ctrlCommit 0; 
		};
		
		pr _ctrl = "getOOP_Text_101_Captive" call UIUndercoverDebug;
		if (captive player) then { 
		_ctrl ctrlSetText "Captive"; 
		_ctrl ctrlSetBackgroundColor [0.3, 1.0, 0.3, 1];
		_ctrl ctrlSetTextColor [0, 0, 0, 1];  
		_ctrl ctrlCommit 0;
		};

		if !(captive player) then { 
		_ctrl ctrlSetText "Not captive";
		_ctrl ctrlSetTextColor [1, 1, 1, 1]; 
		_ctrl ctrlSetBackgroundColor [1.0, 0.3, 0.3, 1];
		_ctrl ctrlCommit 0; 
		};
	};
};


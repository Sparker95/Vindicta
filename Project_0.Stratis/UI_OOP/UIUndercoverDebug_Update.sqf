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

		pr _lastSpottedTimes = player getVariable "lastSpottedTimes";
		if (isNil "_lastSpottedTimes") then { _lastSpottedTimes = "UNDEF"};
		_ctrl = "getOOP_Text_101_LastSpottedTimes" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["LastSpottedTimes: %1", _lastSpottedTimes];

		pr _distance = player getVariable "distance";
		if (isNil "_distance") then { _distance = "UNDEF"};
		_ctrl = "getOOP_Text_101_Distance" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Distance Nearest Enemy: %1", _distance];

		pr _bSeen = player getVariable "bSeen";
		_ctrl = "getOOP_Text_101_Seen" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Seen: %1", _bSeen];

		pr _bInVeh = player getVariable "bInVeh";
		_ctrl = "getOOP_Text_101_InVeh" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["In Veh: %1", _bInVeh];

		pr _bInMilVeh = player getVariable "bInMilVeh";
		_ctrl = "getOOP_Text_101_InVehMil" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["In Mil Veh: %1", _bInMilVeh];

		pr _bWanted = player getVariable "bWanted";
		_ctrl = "getOOP_Text_101_Wanted" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Wanted: %1", _bWanted];

		pr _suspGear = player getVariable "suspGear";
		if (isNil "_suspGear") then { _suspGear = "UNDEF"};
		_ctrl = "getOOP_Text_101_SuspGear" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Susp Gear: %1", _suspGear];

		pr _bodyExposure = player getVariable "bodyExposure";
		if (isNil "_bodyExposure") then { _bodyExposure = "UNDEF"};
		_ctrl = "getOOP_Text_101_BodyExp" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Body Exposure: %1", _bodyExposure];

		pr _timeUnseen = player getVariable "timeUnseen";
		if (isNil "_timeUnseen") then { _timeUnseen = "UNDEF"};
		_ctrl = "getOOP_Text_101_TimeUnseen" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Time Unspotted: %1", _timeUnseen];

		pr _suspicious = player getVariable "bSuspicious";
		if (isNil "_suspicious") then { _suspicious = "UNDEF"};
		_ctrl = "getOOP_Text_101_Suspicious" call UIUndercoverDebug;
		_ctrl ctrlSetText format ["Suspicious: %1", _suspicious];
		
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


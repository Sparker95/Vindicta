params [["_obj",objNull,[objNull]]];

#include "defineCommon.hpp"

#define MAX_DISTANCE 30 // max distance unit can interact with you
#define MAX_ANGLE 0.2 // between 1 and -1 where 1=0degree FOV and -1 360degree FOV
#define MIN_VISIBILITY 1 // might need to be a bit lower

if(
	(_obj distance player < MAX_DISTANCE) && {
	eyeDirection _obj vectorcos (eyePos player vectorDiff eyepos _obj) > MAX_ANGLE} && {
	[objNull, "VIEW"] checkVisibility [eyePos cursorObject, eyePos player] >= MIN_VISIBILITY}
)then{

	if!(weaponLowered player) && {currentWeapon player != ""}then{
		private _thread = cursorTarget getVariable ["#threatValue",0];
		
		[cursorTarget,[player]] call bis_fnc_cp_main;
		cursorTarget setVariable ["#threatValue",0.2];
		if(_thread >= 0.15)exitWith{};
		[_obj,"don't shoot!",player] call Dialog_fnc_hud_createSentence;
	};
};



eyeDirection _obj
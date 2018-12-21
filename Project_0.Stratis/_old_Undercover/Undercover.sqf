/*
----------------------------------------------------------------------------------------------
									UNDERCOVER SCRIPT
----------------------------------------------------------------------------------------------


			Attention variable defines how conspicuous you are to the enemy:
			
				1.0 = Overt = setCaptive false;
				0.0 = Incognito = setCaptive true;

				SAVED for later: if ((vehicle player) isEqualTo player)

AUTHOR: Marvis, made extra spicy by Sparker and Jeroen
----------------------------------------------------------------------------------------------
*/

#include "..\modCompatBools.sqf"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

/* 
----------------------------------------------------------------------------------------------
	PARAMETERS
----------------------------------------------------------------------------------------------
*/

#define ATTN_CROUCH 0.1					// attention gained for crouching
#define ATTN_PRONE 0.2					// attention gained for being prone
#define ATTN_SPEEDMAX 0.35				// max atention gained for movement speed
#define ATTN_SPOT 0.05					// attention gained each cycle, while unit is "spotted" by enemy
#define ATTN_UNIFORM 0.7				// attention gained for mil uniform
#define ATTN_VEST 0.7					// attention gained for mil vest
#define ATTN_HEADGEAR 0.7				// attention gained for mil headgear
#define ATTN_FACEWEAR 0.05				// attention gained for mil facewear
#define ATTN_BACKPACK 0.3				// attention gained for mil backpack
#define ATTN_NVGS 0.5					// attention gained for NVGs
#define DATE_TIME ((dateToNumber date))

/* 
----------------------------------------------------------------------------------------------
	FUNCTIONS 
----------------------------------------------------------------------------------------------
*/


fnc_setUndercover = {
  params ["_unit", "_attention"];

	if ( _attention >= 1.0 ) then { _unit setCaptive false; }
  	else { _unit setCaptive true; };
};

// Check unit's stance, crouching/prone = suspicious
fnc_attnStance = {
	params ["_unit"];

	switch (stance _unit) do {

    	case "STAND": { 0.0; };
		case "CROUCH": { ATTN_CROUCH; };
    	case "PRONE": { ATTN_PRONE; };
    	case "UNDEFINED": { 0.0; };
    	default { 0.0; };
	};
	
};

// Check unit's movement speed, faster = more suspicious
fnc_attnSpeed = {
	params ["_unit"];

	private _attnSpeed = (vectorMagnitude velocity _unit) * 0.05;

		if ( _attnSpeed > ATTN_SPEEDMAX ) exitWith { ATTN_SPEEDMAX; };
		if ( _attnSpeed < 0.15 ) then { 0.0; } else { _attnSpeed; };
};

// Check if unit's equipment is in civilian item whitelist
fnc_attnGear = {
	params ["_unit"];
	private _attnGear = 0.0;
	_attnGear = 0.0;

	if !((uniform _unit in civUniforms) or (uniform _unit == "")) then { _attnGear = _attnGear + ATTN_UNIFORM; };
	if !((headgear _unit in civHeadgear) or (headgear _unit == "")) then { _attnGear = _attnGear + ATTN_HEADGEAR; }; 
	if !((goggles _unit in civFacewear) or (goggles _unit == "")) then { _attnGear = _attnGear + ATTN_FACEWEAR; };
	if !((vest _unit in civVests) or (vest _unit == "")) then { _attnGear = _attnGear + ATTN_VEST; };
	if !((backpack _unit in civBackpacks) or (backpack _unit == "")) then { _attnGear = _attnGear + ATTN_BACKPACK; };
	if (hmd player != "") then { _attnGear = _attnGear + ATTN_NVGS; };

	_attnGear;
};

fnc_attnWeap = {
	params ["_unit"];

	if ( currentWeapon _unit != "" ) exitWith { 1.0; };
	if ( primaryWeapon _unit != "" ) exitWith { 1.0; };
	if ( secondaryWeapon _unit != "" ) then { 1.0; } else { 0.0; };

};


/* 
----------------------------------------------------------------------------------------------
	MAIN UNDERCOVER FUNCTION
----------------------------------------------------------------------------------------------
*/

#define SLEEP_TIME 0.5

[player] spawn {
	params ["_unit"]; 
	_unit setCaptive true;
	_unit setVariable ["attnGear", 0.0];
	_attnGear = 0.0;

	if (activeCBA) then { 
			["loadout", { params ["_unit", "_newLoadout"];
			private _attnGearTemp = [_unit] call fnc_attnGear; 
			_unit setVariable ["attnGear", _attnGearTemp];
        	systemChat "Loadout changed.";
    	}] call CBA_fnc_addPlayerEventHandler;
	};


scopeName "onFoot"; 
	while {true} do {

		private _attention = 0.0;

		if !(activeCBA) then { _attnGear = [_unit] call fnc_attnGear; } else { _attnGear = _unit getVariable "attnGear"; };

  		private _attnStance = [_unit] call fnc_attnStance;
  		private _attnSpeed = [_unit] call fnc_attnSpeed;
		private _attnWeap = [_unit] call fnc_attnWeap;  
		

    	_attention = _attention + _attnGear + _attnStance + _attnSpeed + _attnWeap;
    	if ( _attention > 1 ) then { _attention = 1.0; };

    	[_unit, _attention] call fnc_setUndercover;    	
    	
    	// DEBUG: Show current attention value on screen
    	private _hint = format ["%1", _attention];
  		[_hint, 1, 0, 1, 0, 0, 789] call bis_fnc_dynamicText;

		sleep SLEEP_TIME;
	};

scopeName "inVeh";
scopeName "wanted";
/*	while {true} do {
	


	};*/
};






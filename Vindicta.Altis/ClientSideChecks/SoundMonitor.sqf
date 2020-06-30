#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "ClientChecks.rpt"
#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\stimulusTypes.hpp"
#include "..\CriticalSection\CriticalSection.hpp"

/*
Class: SoundMonitor
Monitors sounds emitted by player. Sends stimulus to server.

Author: Sparker 7 November 2019
*/

#define pr private

#define __HIT_ACC_VAR_NAME "__hitAccumulator"
#define __HIT_MAX_VAR_NAME "__hitMax"

#define UPDATE_INTERVAL 16

#define OOP_CLASS_NAME SoundMonitor
CLASS("SoundMonitor", "MessageReceiverEx")

	VARIABLE("timer");			// Timer

	VARIABLE("unit");			// Unit (object handle) this is attached to

	VARIABLE("silenced");		// Bool, true if current weapon is silenced

	VARIABLE("eventHandlers");

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_unit")];

		T_SETV("unit", _unit);
		T_SETV("silenced", true);
		T_SETV("eventHandlers", []);

		// Create timer
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "process");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = UPDATE_INTERVAL;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		// Init variables on unit
		// We could store stuff in OOP object instead of unit object
		// But let's store it in unit object directly to save us some microseconds
		_unit setVariable [__HIT_ACC_VAR_NAME, 0];
		_unit setVariable [__HIT_MAX_VAR_NAME, 0];

		// Add fired event handler
		pr _ehid = _unit addEventHandler ["FiredMan", GET_METHOD("SoundMonitor", "EHFiredMan")];
		T_GETV("eventHandlers") pushBack ["FiredMan", _ehid];
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Delete the timer
		pr _timer = T_GETV("timer");
		DELETE(_timer);

		// Delete the event handlers
		pr _unit = T_GETV("unit");
		{
			_x params ["_type", "_id"];
			_unit removeEventHandler [_type, _id];
		} forEach T_GETV("eventHandlers");

	ENDMETHOD;

	public override METHOD(getMessageLoop)
		gMsgLoopPlayerChecks
	ENDMETHOD;

	public METHOD(process)
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		pr _unit = T_GETV("unit");

		// Are we dead already?
		if (!alive _unit) exitWith {
			DELETE(_thisObject);
			0
		};

		// Update the silenced value
		pr _silenced = [_unit] call misc_fnc_currentWeaponSilenced;
		T_SETV("silenced", _silenced);

		// Do the processing
		CRITICAL_SECTION {
			pr _hitAcc = _unit getVariable __HIT_ACC_VAR_NAME;
			if (!_silenced) then {
				if (_hitAcc > 0) then {

					pr _hitMax = _unit getVariable __HIT_MAX_VAR_NAME;

					OOP_INFO_3("PROCESS: hitAcc: %1, hitPerSecond: %2, hit max: %3", _hitAcc, _hitAcc/UPDATE_INTERVAL, _hitMax);

					// Estimate distance how far it could be heard
					// https://www.desmos.com/calculator/u1gc21raag
					pr _range = 1000*log(_hitMax/8+1)+1100;
					pr _value = _hitAcc / UPDATE_INTERVAL; // Value is hit per second

					// Create stimulus and send it to the garrison stimulus manager
					pr _stim = STIMULUS_NEW();
					STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_SOUND);
					STIMULUS_SET_SOURCE(_stim, _unit);
					STIMULUS_SET_POS(_stim, getPos _unit);
					STIMULUS_SET_RANGE(_stim, _range);
					STIMULUS_SET_VALUE(_stim, _value);
					STIMULUS_SET_SIDES_INCLUDE(_stim, [EAST ARG WEST ARG INDEPENDENT] - [side group _unit]);
					CALLM2(gStimulusManagerGarrison, "postMethodAsync", "handleStimulus", [_stim]);

					// Reset the counters
					_unit setVariable [__HIT_MAX_VAR_NAME, 0];
					_unit setVariable [__HIT_ACC_VAR_NAME, 0];
				};
			} else {
				// Reset the counters
				_unit setVariable [__HIT_MAX_VAR_NAME, 0];
				_unit setVariable [__HIT_ACC_VAR_NAME, 0];
			};
		};

		0
	ENDMETHOD;

	public STATIC_METHOD(EHFiredMan)
		// Note the absence of P_THISCLASS in params
		params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
		
		pr _hit = getNumber (configFile >> "cfgAmmo" >> _ammo >> "hit");
		
		/*
		diag_log "Fired!";
		diag_log format ["   unit: %1, weapon: %2, muzzle: %3, mode: %4, ammo: %5, magazine: %6", _unit, _weapon, _muzzle, _mode, _ammo, _magazine];
		diag_log format ["   projectile: %1", _projectile];
		diag_log format ["   type projectile: %1, velocity: %2", typeof _projectile, vectorMagnitude (velocity _projectile)];
		diag_log format ["   ammo hit: %1", _hit];
		*/

		// Todo: find a way to detect explosives being detonated
		// Todo: add ACE grenade throwing
		// todo improve this, because hit value is 0 for smoge grenades in grenade launcher and maybe for other things
		if(_hit > 0 && _weapon != "Put") then
		{
			pr _hitMax = _unit getVariable __HIT_MAX_VAR_NAME;
			pr _hitAcc = _unit getVariable __HIT_ACC_VAR_NAME;

			// Hit accumulator
			_unit setVariable [__HIT_ACC_VAR_NAME, _hitAcc + _hit];
			//_unit setVariable [__HIT_ACC_VAR_NAME, _hitAcc + 1]; // Temporary overwriting it to 1, so that any gunshot produces same sensor stimulation

			// Maximum hit value during this time interval between process calls
			if (_hit > _hitMax) then {
				_unit setVariable [__HIT_MAX_VAR_NAME, _hit];
			};
		};
	ENDMETHOD;

ENDCLASS;
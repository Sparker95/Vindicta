#include "common.hpp"

/*
This sensor gets stimulated by sounds.
*/

#define pr private

#define UPDATE_INTERVAL 10

// How long we remember all the sound sources
#define SOUND_SOURCE_MAX_AGE 120

// How many seconds it takes stimulation to decay 2.71 times
#define STIMULATION_DECAY_CONSTANT 80

// How much stimulation results in this sensor revealing targets to the garrison
// todo maybe this number must depend on the activity in the area?? And on previous encounters by this garrison? And something else?
#define STIMULATION_THRESHOLD 10

#define OOP_CLASS_NAME SensorGarrisonSound
CLASS("SensorGarrisonSound", "SensorGarrisonStimulatable")

	// Accumulator of stimulation
	// Note that the value is actuall hit per second, because it's divided by process interval in SoundMonitor
	// If stimulated, this variable accumulates stimulation
	// If not, the value is exponentially declining
	VARIABLE("stimulation");
	
	VARIABLE("timePrevUpdate");

	// Array of [source object handle, time]
	VARIABLE("soundSources");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("stimulation", 0);
		T_SETV("timePrevUpdate", GAME_TIME);
		T_SETV("soundSources", []);
	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT];

		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};
		
		// Delete old sound sources
		pr _soundSources = T_GETV("soundSources");
		pr _i = 0;
		while {_i < count _soundSources} do {
			pr _sourceArray = _soundSources#_i;
			if (GAME_TIME - (_sourceArray#1) > SOUND_SOURCE_MAX_AGE) then {
				_soundSources deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};

		// Decrease stimulation level gradually
		pr _timePassed = GAME_TIME - T_GETV("timePrevUpdate");
		_stimulation = T_GETV("stimulation") * (exp (-_timePassed/STIMULATION_DECAY_CONSTANT));
		T_SETV("stimulation", _stimulation);

		if (_stimulation > 0) then {
			OOP_INFO_1("PROCESS Stimulation: %1", _stimulation);
		};

		// Check if stimulation is above threshold
		pr _stimulation = T_GETV("stimulation");
		if (_stimulation > STIMULATION_THRESHOLD) then {
			OOP_INFO_1("  Stimulation above threshold!", _stimulation);

			pr _AI = T_GETV("AI");
			pr _garPos = CALLM0(_AI, "getPos");

			// Make an array of stimulus structs
			OOP_INFO_0("  Sending targets:");
			pr _dateNumber = dateToNumber date;
			pr _targets = _soundSources apply {
				_x params ["_hO", "_time"];
				pr _ret = 0;
				CRITICAL_SECTION {
					// Check inside the critical section, or we have race condition
					if !(isNull _hO) then {
						pr _unit = GET_UNIT_FROM_OBJECT_HANDLE(_hO);
						_ret = if (IS_OOP_OBJECT(_unit)) then {
							pr _distance = (getPos _hO) distance2D _garPos;
							pr _inaccuracy = _distance*0.1; // We randomize the position a little, depending on how far the target is
							pr _hOpos = getPos _hO;
							pr _pos = [(_hOpos#0) + (random _inaccuracy) - 0.5*_inaccuracy, (_hOpos#1) + (random _inaccuracy) - 0.5*_inaccuracy, 0];
							pr _eff = GET_UNIT_EFFICIENCY_FROM_OBJECT_HANDLE(_hO);
							pr _target = TARGET_NEW(_unit, 2.0, _pos, _dateNumber, +_eff);

							OOP_INFO_1("    %1", _target);

							// Return stimulus
							_target
						} else {
							TARGET_NEW(format ["unknown %1", _hO], 2.0, _pos, _dateNumber, +(T_efficiency#T_INF#T_INF_rifleman))
						};
					};
				};
				_ret
			} select {
				// Filter out the invalid sources
				!isNil {_x} && {_x isEqualType []}
			};

			// Send targets to target sensor
			pr _stim = STIMULUS_NEW();
			STIMULUS_SET_SOURCE(_stim, _thisObject);
			STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_TARGETS);
			STIMULUS_SET_VALUE(_stim, _targets);
			
			pr _sensorTargets = GETV(_AI, "sensorTargets");
			CALLM1(_sensorTargets, "handleStimulus", _stim);
		};

		T_SETV("timePrevUpdate", GAME_TIME);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		OOP_INFO_1("HANDLE STIMULUS: %1", _stimulus);

		pr _distance = CALLM0(T_GETV("AI"), "getPos") distance2D STIMULUS_GET_POS(_stimulus);
		// Distance factor slowly decreases with distance
		pr _distanceFactor = 1/( ((_distance^2)/2e6)  + 1); // https://www.desmos.com/calculator/o9lyczbcmp
		
		pr _stimulation = T_GETV("stimulation");

		pr _value = STIMULUS_GET_VALUE(_stimulus);
		pr _hitPerSecond = _value*_distanceFactor;

		// Increase stimulation
		T_SETV("stimulation", _stimulation + _hitPerSecond);

		// Add the source into an array of sources
		pr _sources = T_GETV("soundSources");
		pr _sourceObjHandle = STIMULUS_GET_SOURCE(_stimulus);
		pr _index = _sources findIf {_sourceObjHandle isEqualTo _x#0};
		if (_index != -1) then {
			// Reset the time of this source
			(_sources#_index) set [1, GAME_TIME];
		} else {
			// Add a new source
			_sources pushBack [STIMULUS_GET_SOURCE(_stimulus), GAME_TIME];
		};
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_SOUND]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	METHOD(doComplexCheck)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		// Bail if not spawned
		// todo later despawned garrisons can also receive this stimulus, so that when they are spawned, they are already alert for instance
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {
			false
		};

		// Return true only if garrison is NOT in combat state
		// If in combat it makes no sense for us to hear gunshots any more
		// If not in combat, and sensor gets overstimulated, garrison will switch to combat mode
		pr _AI = T_GETV("AI");
		!CALLM0(_AI, "isAlerted")
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getUpdateInterval)
		//params [P_THISOBJECT];
		UPDATE_INTERVAL
	ENDMETHOD;

ENDCLASS;
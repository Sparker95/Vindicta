// /*
// Enum: STIMULUS_TYPE
// File: AI\stimulusTypes.hpp
// */

// Not a stimulus (used when the sensor can't be stimulated)
//#define STIMULUS_TYPE_NONE	0

// Sound such as gunfire and others
// Value is: [_hitAcc]
// _hitAcc - amount of hit produces by these gunshots (see SoundMonitor.sqf)
#define STIMULUS_TYPE_SOUND 1


// Someone has saluted to the unit
#define STIMULUS_TYPE_UNIT_SALUTE		100
#define STIMULUS_TYPE_UNIT_CIV_NEAR		101

// Information about targets
// Value is: array of TARGET structures
#define STIMULUS_TYPE_TARGETS			200
// Value is: array of target object handles
#define STIMULUS_TYPE_FORGET_TARGETS	201

// Information about some unit which was destroyed in this garrison
// Sent to a garrison AI from killed EH
// Value is: [_unit, _hOKiller] 
#define STIMULUS_TYPE_UNIT_DESTROYED	250

// Information about friendly destroyed units
// Sent to commander AI from garrison AI
// Value is: array of [_catID, _subcatID, _hOKiller]
#define STIMULUS_TYPE_UNITS_DESTROYED	251


// Information about location composition
#define STIMULUS_TYPE_LOCATION			300
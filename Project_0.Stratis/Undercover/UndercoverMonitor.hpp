// Name of the 'exposed' variable that we set on unit
#define UNDERCOVER_EXPOSED "bExposed"

// Macro for getting the 'exposed' value of a unit (object handle)
#define UNDERCOVER_IS_UNIT_EXPOSED(unit) unit getVariable [UNDERCOVER_EXPOSED, false]
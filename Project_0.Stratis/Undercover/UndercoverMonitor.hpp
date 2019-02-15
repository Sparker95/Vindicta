// Name of the 'exposed' variable that we set on unit
#define UNDERCOVER_EXPOSED "bExposed"
#define UNDERCOVER_WANTED "bWanted"
#define UNDERCOVER_SUSPICIOUS "bSuspicious"

// Macro for getting the 'exposed' value of a unit (object handle)
#define UNDERCOVER_IS_UNIT_EXPOSED(unit) unit getVariable [UNDERCOVER_EXPOSED, false]
#define UNDERCOVER_IS_UNIT_WANTED(unit) unit getVariable [UNDERCOVER_WANTED, false]
#define UNDERCOVER_IS_UNIT_SUSPICIOUS(unit) unit getVariable [UNDERCOVER_SUSPICIOUS, false]
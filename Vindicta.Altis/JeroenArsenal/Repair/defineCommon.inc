#include "..\defineCommon.inc"

#define FLOAT_MASSMULTIPLIER 1.1
#define INT_MAX_DISTANCE_TO_REPAIR 5

#define STR_ACTION_REPAIR(REPAIRCARGO,REPAIRCARGOCAPACTIY) format ["<img size='1.75' image='\A3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa' />%1 [%2/%3]",localize "STR_JN_REPAIR_ACT_REPAIR",REPAIRCARGO,REPAIRCARGOCAPACTIY]


#define TYPE_WHEEL 0
#define TYPE_TRACK 1
#define TYPE_ENGINE 2
#define TYPE_FUEL 3
#define TYPE_BODY 4
#define TYPE_HULL 5
#define TYPE_GLASS 6
#define TYPE_LIGHT 7

#define TYPE_PARTS ["Wheel","Track","Engine","Fuel tank","Chassis","Body","Glass","Light"]

//[_displayName,_type,_size,_armor,_wheelSize,_hitpoints,_selections,_hitTypes,_hitpointNames]
#define VEHICLE_DATA_DISPLAYNAME 0
#define VEHICLE_DATA_TYPE 1
#define VEHICLE_DATA_SIZE 2
#define VEHICLE_DATA_ARMOR 3
#define VEHICLE_DATA_WHEELSIZE 4
#define VEHICLE_DATA_HITPOINTS 5
#define VEHICLE_DATA_SELECTIONS 6
#define VEHICLE_DATA_HITTYPES 7

	
#define SKILL_REQUIRED_PART [\
	0.1,\
	0.4,\
	0.2,\
	0.2,\
	0.2,\
	0.2,\
	0.5,\
	0.2]\
	
#define SKILL_REQUIRED_VEHICLE [\
	0.1,\
	0.5,\
	0.8,\
	0.8,\
	0.3,\
	0.2]\

	
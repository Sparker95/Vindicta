#include "..\defineCommon.inc"

#define INT_MAX_DISTANCE_TO_REFUEL 4
#define INT_FUELCONSUMTION_MULTIPLIER 1//how much more fuel is used per tick;
#define FLOAT_MASSMULTIPLIER 1.3//how much more heavy is a fully loaded fuel truck
#define FLOAT_REFUELINTERVAL 0.5
#define STR_ACTION_REFUEL(FUELCARGO,FUELCARGOCAPACTIY) format ["<img size='1.75' image='\A3\ui_f\data\IGUI\Cfg\Actions\refuel_ca.paa' />%1 [%2L/%3L]",localize "STR_JN_FUEL_ACT_REFUEL",FUELCARGO,FUELCARGOCAPACTIY]

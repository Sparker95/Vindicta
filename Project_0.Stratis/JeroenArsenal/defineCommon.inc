#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

#define pr private// Sparker Pr(ivate)© all rights resevered 

#define DISPLAYNAME_VEHICLE(OBJ) gettext (configfile >> "CfgVehicles" >> (typeOf OBJ) >> "displayName")
#define DISPLAYNAME_MAG(MAG) gettext (configfile >> "CfgMagazines" >> MAG >> "displayName")
#define DISPLAYNAME_AMMO(AMMO) gettext (configfile >> "CfgAmmo" >> AMMO >> "displayName")

#define TYPE_CAR 0
#define TYPE_ARMOR 1
#define TYPE_HELI 2
#define TYPE_PLANE 3
#define TYPE_NAVAL 4
#define TYPE_STATIC 5

#define TYPE_VEHICLES ["Car","Armor","Heli","Plane","Naval","Static"]

#define COLOR_ORANGE [1,0.64,0,1]
#define COLOR_WHITE [1,1,1,1]
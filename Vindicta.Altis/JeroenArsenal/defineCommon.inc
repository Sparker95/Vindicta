#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
#include "..\common.h"
#define OFSTREAM_FILE "JeroenArsenal.rpt"

#define ERROR_JN_6(A,B,C,D,E,F) diag_log format["JN_ERROR: ,%1,%2,%3,%4,%5,%6",A,B,C,D,E,F]
#define ERROR_JN_5(A,B,C,D,E) diag_log format["JN_ERROR: ,%1,%2,%3,%4,%5",A,B,C,D,E]
#define ERROR_JN_4(A,B,C,D) diag_log format["JN_ERROR: ,%1,%2,%3,%4",A,B,C,D]
#define ERROR_JN_3(A,B,C) diag_log format["JN_ERROR: ,%1,%2,%3",A,B,C]
#define ERROR_JN_2(A,B) diag_log format["JN_ERROR: ,%1,%2",A,B]
#define ERROR_JN_1(A) diag_log format["JN_ERROR: ,%1",A]

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


#define ACTION_SET_ICON_AND_TEXT(OBJECT_ACTION,ID,NAME,ICON) OBJECT_ACTION setUserActionText [\
		ID,NAME,"",format["<img size='3' color='#ffffff' image='%1'/>",\
			ICON\
		]\
	]
	
#define ROUND_TO(FLOAT,INT) (round ((FLOAT)*10*(INT)))/(10*(INT))
	
	
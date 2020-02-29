removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_PilotHelmetFighter_I_E";
this forceAddUniform "U_I_pilotCoveralls";
this addVest "V_Rangemaster_belt";
this addBackpack "B_Parachute";

this addWeapon "hgun_Pistol_heavy_01_green_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "optic_MRD_black";
this addHandgunItem "11Rnd_45ACP_Mag";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "11Rnd_45ACP_Mag";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";

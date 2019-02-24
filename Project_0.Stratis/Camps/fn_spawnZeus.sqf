/*
Creates a Zeus curator for camps

Author: Marvis 22.02.2018 
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camps.hpp"

#define pr private

params ["_unit"];

pr _pos = getPos _unit;

zeusCurator = "ModuleCurator_F" createUnit [[0, 90, 90], group _unit];
zeusCurator addCuratorAddons activatedAddons;
_unit assignCurator zeusCurator; 

zeusCurator addCuratorEditableObjects [vehicles,true];
zeusCurator addCuratorEditableObjects [(allMissionObjects "Man"),false];
zeusCurator addCuratorEditableObjects [(allMissionObjects "Air"),true];
zeusCurator addCuratorEditableObjects [(allMissionObjects "Ammo"),false];
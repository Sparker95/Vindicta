/*
Creates a Zeus curator for camps

Author: Marvis 22.02.2018 
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camp.hpp"

#define pr private

// create curator
pr _groupCurator = createGroup WEST;
campCurator = groupCurator createunit ["ModuleCurator_F", [0, 90, 90], [], 0.5, "NONE"];

// set editing area
campCurator addCuratorEditingArea [89, position player, 40];
campCurator setCuratorEditingAreaType true; // disallow placing outside of area

// camera movement restrictions
campCurator addCuratorCameraArea [90, position player, 40];
campCurator setCuratorCameraAreaCeiling 50;
campCurator allowCuratorLogicIgnoreAreas false; // may have to enable to allow commanding units

removeAllCuratorAddons campCurator; // remove *all* objects from Zeus menu
unassignCurator campCurator;
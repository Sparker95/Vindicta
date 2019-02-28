/*
	Description:
	Adds an action to open the camp's Zeus interface to an object if run on client
	
	Parameter(s):
	Object
	
	Usage: object call fnc_addActionCampZeus;

	Author: Marvis, 25.02.2018 
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camp.hpp"

#define pr private

params["_object"];

_object addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  

	params ["_target", "_caller", "_actionId", "_arguments"];

	[_caller, campCurator] remoteExec ["assignCurator", 2, false];
	openCuratorInterface;

}];
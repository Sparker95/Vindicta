#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"

/*
	
	Adds an action to an object that opens the build menu UI

*/

params["_object"];

_object addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  

	params ["_target", "_caller", "_actionId", "_arguments"];

	g_buildUIRpt << "fn_OpenBuildUI: Open Build UI action menu option called.";
	g_buildUIRpt << format ["fn_OpenBuildUI: Caller %1", name _caller];
	private _bUI = _caller getVariable "BuildUI";
	CALLM0(_bUI, "openUI");

}];
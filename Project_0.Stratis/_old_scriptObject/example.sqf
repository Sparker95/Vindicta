/*
Template for a thread to be started by scriptObject.
*/

#define SLEEP_TIME 2
#define SLEEP_RESOLUTION 0.01

params ["_so", "_extraParams"]; //script object, extra params

//Do synchronous initialization here

private _hScript = [_so, _extraParams] spawn
{
	params ["_so", "_extraParams"];
	
	//Start the loop
	private _run = true;
	private _t = time;
	while {_run && _so getVariable "so_run"} do
	{
		//Check if it's time to stop
		if (_run) then
		{

			//_run = false; can be used to terminate the thread internally
			
			//Update time variable
			_t = time + SLEEP_TIME;
			
			//Sleep and check if it's ordered to stop the thread
			waitUntil
			{
				sleep SLEEP_RESOLUTION;
				(time > _t) || (!(_so getVariable "so_run"))
			};
		};
	}; //while
	
	//It was requested externally or internally to terminate the script
	
	//Do the deinitialization here
	
	/*
	If it's also needed to delete the scriptObject on thread termination, do like this:
	[_so, false] call scriptObject_fnc_delete; //false parameter is required, otherwise the script will hang
	*/

}; //spawn

//Return the script handle to scriptObject_fnc_start
_hScript
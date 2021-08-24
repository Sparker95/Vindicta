// Code for Random weather, Credits to Sil Carmikas @ https://forums.bohemia.net/forums/topic/202392-sils-simple-random-weather-script/
// Edited by Jasperdoit
if isServer then {
	[] spawn {

		//Initial weather vodoo

		0 setOvercast random 1; 
		forceWeatherChange;

		// Random Weather
			while {true} do {
				private _randomTime = random (600 + 300);
				_randomTime setOvercast random 1;
				sleep (_randomTime + 100);
		};
	};
};
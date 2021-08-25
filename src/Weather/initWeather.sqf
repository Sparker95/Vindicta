// Code for Random weather, Credits to Sil Carmikas @ https://forums.bohemia.net/forums/topic/202392-sils-simple-random-weather-script/
// Edited by Jasperdoit

if isServer then {
	[] spawn {

		private _weather = [
			[
				0.3
			],
			[
				0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45
			],
			[
				0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1
			]
		] select vin_server_weather_toggle;

		//Initial weather vodoo

		0 setOvercast selectRandom _weather; 
		forceWeatherChange;

		// Random Weather
			while {true} do {
				private _randomTime = (random 3600 + 1200);
				_randomTime setOvercast selectRandom _weather;
				sleep (_randomTime + 300);
		};
	};
};
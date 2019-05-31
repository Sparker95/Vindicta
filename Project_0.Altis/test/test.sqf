
#define THREAT_FADE_RATE 0.93
#define ACTIVITY_FADE_RATE 0.98
#define FADE_RATE_PERIOD 360
//#define POW(a, b) (a)^(b)
#define POW(a, b) (exp ((b) * ln (a)))

private _initial = 100;
private _final = 10;
private _finalPercent = 100 * (1 - _final / _initial);
private _threat = _initial;
private _t = 0;
while {_threat > _final} do
{
	private _dt = 30 + random 30;
	_t = _t + _dt;
	
	//private _threatFade = THREAT_FADE_RATE ^ (_dt / FADE_RATE_PERIOD);
	private _threatFade = POW(THREAT_FADE_RATE, (_dt / FADE_RATE_PERIOD));
	_threat = _threat * _threatFade;
};
diag_log format["It took %1 hrs for threat to drop by %2%3", _t / 3600, _finalPercent, "%"];

private _activity = _initial;
_t = 0;
while {_activity > _final} do
{
	private _dt = 30 + random 30;
	_t = _t + _dt;
	
	//private _activityFade = ACTIVITY_FADE_RATE ^ (_dt / FADE_RATE_PERIOD);
	private _activityFade = POW(ACTIVITY_FADE_RATE, (_dt / FADE_RATE_PERIOD));
	_activity = _activity * _activityFade;
};
diag_log format["It took %1 hrs for activity to drop by %2%3", _t / 3600, _finalPercent, "%"];

//Formula used to calculate hearing radius based on ammo hit value
#define hearingRadius(hit) (700 + 31*hit)

//These constants help classify the amount of sound produced by ammo based on its hit value from cfgAmmo.
#define S_HIT_LIGHT		1	//Light is everything above 1
#define S_HIT_MEDIUM	23	//Medium is everything above 25
#define S_HIT_HEAVY		200	//Heavy is everything above 200

//Types of sounds:
#define S_SOUND_FIRE_LIGHT		0
#define S_SOUND_FIRE_MEDIUM		1
#define S_SOUND_FIRE_HEAVY		2
#define S_SOUND_FIRE_ARTILLERY	3
#define S_SOUND_HELICOPTER		4
#define S_SOUND_PLANE			5

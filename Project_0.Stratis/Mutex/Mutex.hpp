/*
Macros to manipulate a mutex
thx to Freghar from BIS forum for the idea: https://forums.bohemia.net/forums/topic/183993-scripting-introduction-for-new-scripters/?tab=comments#comment-3016726
*/

//Mutex is just an empty array
#define MUTEX_NEW() []

//Lock the mutex
#define MUTEX_LOCK(mutex) waitUntil { (mutex pushBackUnique 0) == 0;}

//Unlock the mutex
#define MUTEX_UNLOCK(mutex) mutex deleteAt 0

//Tries to lock the mutex pointed to by mutex without blocking. Returns immediately if the mutex is already locked.
//Return value: true if successful, false if the mutex has already been locked
#define MUTEX_TRY_LOCK(mutex) if((mutex pushBackUnique 0) == 0) then {true} else {false}
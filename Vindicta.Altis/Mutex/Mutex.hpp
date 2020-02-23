// /*
// Struct: Mutex
// Mutex lets multiple threads (scheduled scripts) share the same resource so that only one of the threads can access it.

// Usage: Create a Mutex known to both threads. Lock it before doing read-modify-write operations on the common resource. Unlock it.

// Warning: this Mutex is NON-RECURSIVE! The thread will DEADLOCK if attempted to lock a mutex more than once.
 
// thx to Freghar from BIS forum for the implementation: https://forums.bohemia.net/forums/topic/183993-scripting-introduction-for-new-scripters/?tab=comments#comment-3016726
// */

// /*Macro: MUTEX_NEW()
// Returns a new Mutex*/
#define MUTEX_NEW() []

// /*Macro: MUTEX_LOCK(mutex)
// Locks the mutex*/
#ifndef _SQF_VM
#define MUTEX_LOCK(mutex) waitUntil { (mutex pushBackUnique 0) == 0;}
#else
#define MUTEX_LOCK(mutex) (mutex pushBackUnique 0)
#endif

// /*Macro: MUTEX_UNLOCK(mutex)
// Unlocks the mutex*/
#define MUTEX_UNLOCK(mutex) mutex deleteAt 0

// /*Macro: MUTEX_TRY_LOCK(mutex)
// Tries to lock the mutex without blocking. Returns immediately if the mutex is already locked.

// Returns: true if successful, false if the mutex has already been locked
// */

#define MUTEX_TRY_LOCK(mutex) if(((mutex) pushBackUnique 0) == 0) then {true} else {false}
#define MUTEX_IS_LOCKED(mutex) (count (mutex) > 0)

// diag_tickTime becomes less accurate the longer a mission is running, so higher timeout value is better for robustness
#define MUTEX_TRY_LOCK_TIMEOUT(mutex, timeout) [] call { private _timer = diag_tickTime; private _locked = false; waitUntil { _locked = ((mutex) pushBackUnique 0) == 0; _locked || {diag_tickTime > (_timer + (timeout))} }; _locked }

#ifndef _SQF_VM
#define MUTEX_SCOPED_LOCK(mutex) for [{ private _runOnce = true; waitUntil { ((mutex) pushBackUnique 0) == 0 } }, { _runOnce }, { (mutex) deleteAt 0; _runOnce = false }] do
#else
#define MUTEX_SCOPED_LOCK(mutex) call
#endif 
// MUTEX_SCOPED_LOCK(mutex) {
// 	// blah blah
// };
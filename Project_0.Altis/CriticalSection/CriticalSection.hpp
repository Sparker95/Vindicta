/*
Class: CriticalSection
Critical section is a piece of code which must be executed uninterrupted.
In SQF scheduled scripts can potentially be interrupted at any point by another scheduled script or by an event handler, thus we must prevent it.

It is just a wrapper for isNil {};

Example:

--- Code
CRITICAL_SECTION_START
_a = b;
_a = _a + 1;
b = _a;
CRITICAL_SECTION_END
---

Author: Sparker

Thx Dedmen for this idea!
*/

// Macro: CRITICAL_SECTION_START
#define CRITICAL_SECTION_START private _null = isNil {

// Macro: CRITICAL_SECTION_END
#define CRITICAL_SECTION_END };

#define CRITICAL_SECTION private _null = isNil 
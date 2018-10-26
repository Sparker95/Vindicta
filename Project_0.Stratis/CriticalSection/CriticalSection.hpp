/*
Critical section is a piece of code which must be executed uninterrupted.
In SQF scheduled scripts can potentially be interrupted at any point by another scheduled script or by an event handler, thus we must prevent it.

Author: Sparker
Thx Dedmen for this idea!
*/

#define CRITICAL_SECTION_START private _null = isNil {

#define CRITICAL_SECTION_END };
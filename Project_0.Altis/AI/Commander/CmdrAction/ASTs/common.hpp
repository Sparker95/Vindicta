#include "..\..\common.hpp"

// AST_VAR macros for ASTs

// These work differently for ASTs and actions
// In actions we access our own "variables" array,
// In ASTs we access our action's "variables" array

// Function: T_GET_AST_VAR
// Get the value from an AST_VAR that is a member variable of _thisObject.
#define T_GET_AST_VAR(property) GET_AST_VAR(T_GETV("action"), T_GETV(property))

// Function: T_SET_AST_VAR
// Write a value to an AST_VAR that is a member variable of _thisObject.
#define T_SET_AST_VAR(property, value) SET_AST_VAR(T_GETV("action"), T_GETV(property), value)
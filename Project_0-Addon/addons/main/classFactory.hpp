// BRO CLASS !!
// I borrowed this idea from TFAR
// After Dedmen told me about it
// Sparker 31.05.2019
#define __BC(destClass, sourceClass, ID) \
class destClass##_##ID : sourceClass { };

#define COPY_CLASS_200(d, s) \
__BC(d,s,0) \
__BC(d,s,1) \
__BC(d,s,2) \
__BC(d,s,3) \
__BC(d,s,4) 
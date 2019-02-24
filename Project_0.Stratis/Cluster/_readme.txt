The purpose of the cluster module is to group objects on a 2D plane based on their distance between each other.

So, a group of objects located on a plane like this:

 |
Y| * *
 |  *
 |
 |           ***
 |          **
_|_________________
 |               X
 
Has to be transformed into two clusters:

 |
Y| [C0]
 | [C0]  
 |
 |         [ C1 ]
 |         [ C1 ]
_|_________________
 |               X

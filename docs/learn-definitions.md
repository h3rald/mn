-----
content-type: "page"
title: "Learn: Definitions"
-----
{@ _defs_.md || 0 @}

Being a concatenative language, {{m}} does not really need named parameters or variables: symbols just pop elements off the main stack in order, and that's normally enough. There is however one small problem with the traditional concatenative paradigm; consider the following program for example:

     dup 
     () cons "Compiling in $# mode..." swap interpolate puts pop
     () cons "nim -d:$# c test.nim" swap interpolate run

This program takes an string containing either "release" or "development" and attempts to build the file **test.nim** for it. Sure, it is remarkable that no variables are needed for such a program, but it is not very readable: because no variables are used, it is often necessary to make copies of elements and push them to the end of the stack -- that's what the {#link-symbol||dup#} and {#link-symbol||swap#} are used for.

The good news is that you can use the {#link-symbol||let#} symbol to define new symbols, and symbols can also be set to literals of course.

Consider the following program:

     (mode) let
     "Compiling in $# mode..." (mode) interpolate puts pop
     "nim -d:$# c test.nim" (mode) interpolate run

In this case, the first element on the stack is saved to a symbol called **mode**, which is then used whenever needed in the rest of the program.


## Lexical scoping and binding

mn, like many other programming languages, uses [lexical scoping](https://en.wikipedia.org/wiki/Scope_\(computer_science\)#Lexical_scope_vs._dynamic_scope) to resolve symbols.

Consider the following program:


     4 (a) let
     ( 
       a 3 + (a) let
       (
          a 1 + (a) let
          (a dup * (a) let) dequote
       ) dequote
     ) dequote

...What is the value of the symbol `a` after executing it? 

Simple: `4`. Every quotation defines its own scope, and in each scope, a new variable called `a` is defined. In the innermost scope containing the quotation `(a dup * (a) let)` the value of `a` is set to `64`, but this value is not propagated to the outer scopes. Note also that the value of `a` in the innermost scope is first retrieved from the outer scope (8).

If we want to change the value of the original `a` symbol defined in the outermost scope, we have to use the {#link-symbol||bind#}, so that the program becomes the following:

     4 (a) let ;First definition of the symbol a
     (
       a 3 + (a) bind ;The value of a is updated to 7.
       (
         a 1 + (a) bind ;The value of a is updated to 8
         (a dup * (a) bind) dequote ;The value of a is now 64
       ) dequote
     ) dequote

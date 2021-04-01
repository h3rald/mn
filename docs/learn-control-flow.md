-----
content-type: "page"
title: "Learn: Control Flow"
-----
{@ _defs_.md || 0 @}

{{m}} provides some symbols that can be used for the most common control flow statements. Unlike most programming languages, {{m}} does not differentiate between functions and statements -- control flow statements are just ordinary symbols that manipulate the main stack.

## Conditionals

The {#link-symbol||when#} symbol can be used to implement conditional statements.

For example, consider the following program:

     (
       "Unknown" (system) let 
        [uname] (uname) let
        (uname "MINGW" indexof -1 !=)
          ("Windows" (system) bind)  
        when
        (uname "Linux" indexof -1 !=)
          ("Linux" (system) bind)  
        when
        (uname "Darwin" indexof -1 !=)
          ("macOS" (system) bind)  
        when
       "The current OS is $#" (system) interpolate puts
     ) (display-os) lambda

This program defines a symbol `display-os` that execute the **uname** system command to discover the operating system and outputs a message.

## Loops

The following symbols provide ways to implement common loops:

* {#link-symbol||foreach#}
* {#link-symbol||while#}

For example, consider the following program:

     (
       (n) let
       1 (i) let
       1 (f) let
       (i n <=)
       (
         f i * (f) bind 
         i 1 + (i) bind
       ) while
       f
     ) (factorial) lambda

This program defines a symbol `factorial` that calculates the factorial of an integer iteratively using the symbol {#link-symbol||while#}.

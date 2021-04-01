-----
content-type: "page"
title: "Learn: Operators"
-----
{@ _defs_.md || 0 @}

Every {{m}} program needs _operators_ to:

* Manipulate elements on the stack
* Perform operations on data
* Provide side effects (read/print to standard input/output/files, etc.)

An {{m}} symbol is a single word that is either provided by {{m}} like `dup` or defined by the user. User-defined symbols must:

* Start with a letter
* Contain zero or more letters, numbers and/or underscores.

To define a new operator symbol, you can use the {#link-symbol||lambda#} symbol. For example, the following symbol defines a quotation that can be used to calculate the square value of a number.

     (dup *) (square) lambda
     
Note that this feels like using {#link-symbol||let#}, but the main difference between {#link-symbol||lambda#} and {#link-symbol||let#} is that `lambda` only works on quotations and it doesn't auto-quote them, so that they are immediately evaluated when the corresponding symbol is pushed on the stack.

> %tip%
> Tip
> 
> You can use {#link-symbol||lambda-bind#} to re-set a previously set lambda.

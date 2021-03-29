-----
content-type: "page"
title: "Learn: Data Types"
-----
{@ _defs_.md || 0 @}


The following data types are availanle in {{m}} (with the corresponding shorthand symbols used in symbol signatures in brackets):

null (null)
: null value.
boolean (bool)
: **true** or **false**.
integer (int)
: A 64-bit integer number like 1, 27, or -15.
float (flt)
: A 64-bit floating-point number like 3.14 or -56.9876.
string (str)
: A series of characters wrapped in double quotes: "Hello, World!".
quotation (quot)
: A list of elements, which may also contain symbols. Quotations can be used to create heterogenous lists of elements of any data type, and also to create a block of code that will be evaluated later on (quoted program). Example: `(1 2 3 + \*)`
command (cmd)
: A command string wrapped in square brackets that will be immediately executed on the current shell and converted into the command standard output. Example: `[ls -a]`

-----
content-type: "page"
title: "Reference"
-----
{@ _defs_.md || 0 @}

## Notation

The following notation is used in the signature of all {{m}} symbols:

### Types and Values

{{none}}
: No value.
{{null}}
: null value
{{any}}
: A value of any type.
{{b}}
: A boolean value
{{i}}
: An integer value.
{{flt}}
: A float value.
{{n}}
: A numeric (integer or float) value.
{{s}}
: A string value.
{{sl}}
: A string-like value (string or quoted symbol).
{{q}}
: A quotation (also expressed as parenthesis enclosing other values).

### Suffixes

The following suffixes can be placed at the end of a value or type to indicate ordering or quantities.

{{1}}
: The first value of the specified type.
{{2}}
: The second value of the specified type.
{{3}}
: The third value of the specified type.
{{4}}
: The fourth value of the specified type.
{{01}}
: Zero or one.
{{0p}}
: Zero or more.
{{1p}}
: One or more

## Symbols

{#op||&gt;||{{a1}} {{a2}}||{{b}}||
> Returns {{t}} if {{a1}} is greater than {{a2}}, {{f}} otherwise. 
> > %note%
> > Note
> > 
> > Only comparisons among two numbers or two strings are supported.#}

{#op||&gt;=||{{a1}} {{a2}}||{{b}}||
> Returns {{t}} if {{a1}} is greater than or equal to {{a2}}, {{f}} otherwise.
> > %note%
> > Note
> > 
> > Only comparisons among two numbers or two strings are supported.#}

{#op||&lt;||{{a1}} {{a2}}||{{b}}||
> Returns {{t}} if {{a1}} is smaller than {{a2}}, {{f}} otherwise. 
> > %note%
> > Note
> > 
> > Only comparisons among two numbers or two strings are supported.#}

{#op||&lt;=||{{a1}} {{a2}}||{{b}}||
> Returns {{t}} if {{a1}} is smaller than or equal to {{a2}}, {{f}} otherwise.
> > %note%
> > Note
> > 
> > Only comparisons among two numbers or two strings are supported.#}

{#op||==||{{a1}} {{a2}}||{{b}}||
Returns {{t}} if {{a1}} is equal to {{a2}}, {{f}} otherwise. #}

{#op||!=||{{a1}} {{a2}}||{{b}}||
Returns {{t}} if {{a1}} is not equal to {{a2}}, {{f}} otherwise. #}

{#op||&&||{{q}}||{{b}}||
Assuming that {{q}} is a quotation of quotations each evaluating to a boolean value, it pushes {{t}} on the stack if they all evaluate to {{t}}, {{f}} otherwise. #}
 
{#op|| \|\| ||{{q}}||{{b}}||
Assuming that {{q}} is a quotation of quotations each evaluating to a boolean value, it pushes {{t}} on the stack if any evaluates to {{t}}, {{f}} otherwise.
 #}

{#op||!||{{b1}}||{{b2}}||
Negates {{b1}}.#}

{#op||+||{{n1}} {{n2}}||{{n3}}||
Sums {{n1}} and {{n2}}. #}

{#op||-||{{n1}} {{n2}}||{{n3}}||
Subtracts {{n2}} from {{n1}}. #}

{#op||-inf||{{none}}||{{n}}||
Returns negative infinity. #}

{#op||&ast;||{{n1}} {{n2}}||{{n3}}||
Multiplies {{n1}} by {{n2}}. #}

{#op||/||{{n1}} {{n2}}||{{n3}}||
Divides {{n1}} by {{n2}}. #}

{#op||+inf||{{none}}||{{n}}||
Returns infinity. #}

{#op||nan||{{none}}||nan||
Returns **NaN** (not a number). #}

{#op||append||{{s1}} {{s2}}||{{none}}||
Appends {{s1}} to the end of file {{s2}}. #}

{#op||apply||{{q}}||({{a0p}})||
Returns a new quotation obtained by evaluating each element of {{q}} in a separate stack. #}

{#op||args||{{none}}||{{q}}||
Returns a list of all arguments passed to the current program.#}

{#op||bind||{{any}} {{sl}}||{{none}}||
Binds the specified value (auto-quoted) to an existing symbol {{sl}}.#}

{#op||concat||{{q1}} {{q2}}||{{q3}}||
Concatenates {{q1}} with {{q2}}. #}

{#op||cons||{{a1}} ({{a0p}})||({{a1}} {{a0p}})||
Prepends {{a1}} to the quotation on top of the stack.#}

{#op||cpu||{{none}}||{{s}}||
Returns the host CPU. It can be one of the following strings i386, alpha, powerpc, powerpc64, powerpc64el, sparc, amd64, mips, mipsel, arm, arm64. #}

{#op||dip||{{a1}} ({{a2}})||{{a0p}} {{a1}}||
Removes the first and second element from the stack, dequotes the first element, and restores the second element.#}

{#op||dup||{{a1}}||{{a1}} {{a1}}||
Duplicates the first element on the stack.#}

{#op||dequote||{{q}}||{{a0p}}||
> Pushes the contents of quotation {{q}} on the stack.
>
> Each element is pushed on the stack one by one. If any error occurs, {{q}} is restored on the stack.#}

{#op||eval||{{s}}||{{a0p}}||
Parses and interprets {{s}}. #}

{#op||exit||{{i}}||{{none}}||
Exits the program or shell with {{i}} as return code. #}

{#op||expect||{{q1}}||{{q2}}||
> Validates the first _n_ elements of the stack against the type descriptions specified in {{q1}} (_n_ is {{q1}}'s length) and if all the elements are valid returns them wrapped in {{q2}} (in reverse order). 

> > %tip%
> > Tip
> > 
> > You can specify two or more matching types by separating combined together in a type union, e.g.: `string|quot`

> > %sidebar%
> > Example
> > 
> > Assuming that the following elements are on the stack (from top to bottom): 
> > 
> > `1 "test" 3.4`
> > 
> > the following program evaluates to `true`:
> > 
> > `(int string num) expect (3.4 "test" 1) ==`#}

{#op||filter||{{q1}} {{q2}}||{{q3}}||
> Returns a new quotation {{q3}} containing all elements of {{q1}} that satisfy predicate {{q2}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(34 2 6 8 12)` on the stack:
> > 
> >     (1 37 34 2 6 8 12 21) 
> >     (2 / 0 ==) filter #}

{#op||foreach||{{q1}} {{q2}}||{{a0p}}||
Applies the quotation {{q2}} to each element of {{q1}}.#}

{#op||get||{{q}} {{i}}||{{any}}||
Returns the _n^th_ element of {{q}} (zero-based).#}

{#op||gets||{{none}}||{{s}}||
Reads a line from STDIN and places it on top of the stack as a string.#}

{#op||getstack||{{none}}||({{a0p}})||
Puts a quotation containing the contents of the stack on the stack.#}

{#op||indexof||{{s1}} {{s2}}||{{i}}||
If {{s2}} is contained in {{s1}}, returns the index of the first match or -1 if no match is found. #}

{#op||interpolate||{{s}} {{q}}||{{s}}||
> Substitutes the placeholders included in {{s}} with the values in {{q}}.
> > %note%
> > Notes
> > 
> > * If {{q}} contains symbols or quotations, they are interpreted.
> > * You can use the `$#` placeholder to indicate the next placeholder that has not been already referenced in the string.
> > * You can use named placeholders like `$pwd`, but in this case {{q}} must contain a quotation containing both the placeholder names (odd items) and the values (even items).
> 
> > %sidebar%
> > Example
> >  
> > The following code (executed in a directory called '/Users/h3rald/Development/mn' containing 15 files and directories):
> > 
> > `"Directory '$1' includes $2 items." ([pwd] ([ls] "\n" split size)) interpolate`
> > 
> > produces:
> > 
> > `"Directory '/Users/h3rald/Development/mn' includes 15 items."`#}

{#op||join||{{q}} {{sl}}||{{s}}||
Joins the elements of {{q}} using separator {{sl}}, producing {{s}}.#}

{#op||lambda||{{q}} {{sl}}||{{none}}||
Defines a new symbol {{sl}}, containing the specified quotation {{q}}. Unlike with `let`, in this case {{q}} will not be quoted, so its values will be pushed on the stack when the symbol {{sl}} is pushed on the stack.

Essentially, this symbol allows you to define an symbol without any validation of constraints and bind it to a symbol.#}

{#op||lambdabind||{{q}} {{sl}}||{{none}}||
Binds the specified quotation (unquoted) to an existing symbol {{sl}}.#}

{#op||length||{{sl}}||{{i}}||
Returns the length of {{sl}}.#}

{#op||let||{{any}} {{sl}}||{{none}}||
Defines a new symbol {{sl}}, containing the specified value.#}

{#op||map||{{q1}} {{q2}}||{{q3}}||
Returns a new quotation {{q3}} obtained by applying {{q2}} to each element of {{q1}}.#}

{#op||os||{{none}}||{{s}}||
Returns the host operating system. It can be one of the following strings: windows, macosx, linux, netbsd, freebsd, openbsd, solaris, aix, standalone. #}

{#op||pop||{{any}}||{{none}}||
Removes the first element from the stack.#}

{#op||print||{{any}}||{{any}}||
Prints {{any}} to STDOUT.#}

{#op||puts||{{any}}||{{any}}||
Prints {{any}} and a new line to STDOUT.#}

{#op||quote||{{any}}||({{any}})||
Wraps {{any}} in a quotation. #}

{#op||quotesym||{{s}}||({{sym}})||
Creates a symbol with the value of {{s}} and wraps it in a quotation. #}

{#op||quotecmd||{{s}}||({{sym}})||
Creates a command with the value of {{s}} and wraps it in a quotation. #}

{#op||read||{{s}}||{{s}}||
Reads the file {{s}} and puts its contents on the top of the stack as a string.#}

{#op||replace||{{s1}} {{s2}} {{s3}}||{{s4}}||
> Returns a copy of {{s1}} containing all occurrences of {{s2}} replaced by {{s3}} #}

{#op||run||{{sl}}||{{i}}||
Executes the external command {{sl}} in the current directory and pushes its return code on the stack. #}

{#op||setstack||{{q}}||{{a0p}}||
Substitute the existing stack with the contents of {{q}}.#}

{#op||swap||{{a1}} {{a2}}||{{a2}} {{a1}}||
Swaps the first two elements on the stack. #}

{#op||size||{{q}}||{{i}}||
Returns the length of {{q}}.#}

{#op||slice||{{q1}} {{i1}} {{i2}}||{{q2}}||
> Creates a new quotation {{q2}} obtaining by selecting all elements of {{q1}} between indexes {{i1}} and {{i2}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(3 4 5)` on the stack:
> > 
> >     (1 2 3 4 5 6) 
> >     2 4 slice #}

{#op||split||{{sl1}} {{sl2}}||{{q}}||
Splits {{sl1}} using separator {{sl2}} and returns the resulting strings within the quotation {{q}}. #}

{#op||strip||{{sl}}||{{s}}||
Returns {{s}}, which is set to {{sl}} with leading and trailing spaces removed.#} 

{#op||substr||{{s1}} {{i1}} {{i2}}||{{s2}}||
Returns a substring {{s2}} obtained by retriving {{i2}} characters starting from index {{i1}} within {{s1}}.#}

{#op||symbols||{{none}}||({{s0p}})||
Returns a list of all symbols defined in the global scope.#}

{#op||timestamp||{{none}}||{{i}}||
Returns the current time as Unix timestamp. #}

{#op||type||{{any}}||{{s}}||
Puts the data type of {{any}} on the stack.#}

{#op||when||{{q1}} {{q2}}||{{a0p}}||
If {{q1}} evaluates to {{t}} then evaluates {{q2}}.#}

{#op||which||{{sl}}||{{s}}||
Returns the full path to the directory containing executable {{sl}}, or an empty string if the executable is not found in **$PATH**. #}

{#op||while||{{q1}} {{q2}}||{{a0p}}||
> Executes {{q2}} while {{q1}} evaluates to {{t}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program prints all natural numbers from 0 to 10:
> > 
> >     0 (count) let 
> >     (count 10 <=) 
> >     (count puts 1 + (count) bind) while #}

{#op||write||{{s1}} {{s2}}||{{none}}||
Writes {{s1}} to the file {{s2}}, erasing all its contents first. #}

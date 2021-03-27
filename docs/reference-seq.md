-----
content-type: "page"
title: "seq Module"
-----
{@ _defs_.md || 0 @}

{#op||all?||{{q1}} {{q2}}||{{b}}||
Applies predicate {{q2}} to each element of {{q1}} and returns {{t}} if all elements of {{q1}} satisfy predicate {{q2}}, {{f}} otherwise. #}

{#op||any?||{{q1}} {{q2}}||{{b}}||
Applies predicate {{q2}} to each element of {{q1}} and returns {{t}} if at least one element of {{q1}} satisfies predicate {{q2}}, {{f}} otherwise. #}

{#op||append||{{any}} {{q}}||({{a0p}} {{any}})||
Returns a new quotation containing the contents of {{q}} with {{any}} appended. #}

{#op||get||{{q}} {{i}}||{{any}}||
Returns the _n^th_ element of {{q}} (zero-based).#}

{#op||concat||{{q1}} {{q2}}||{{q3}}||
Concatenates {{q1}} with {{q2}}. #}

{#op||difference||{{q1}} {{q2}}||{{q3}}||
> Calculates the difference {{q3}} of {{q1}} and {{q2}}.
>
> > %sidebar%
> > Example
> > 
> > The following program leaves `(2)` on the stack:
> > 
> >     (1 2 "test") ("test" "a" true 1) difference #}

{#op||drop||{{q1}} {{i}}||{{q2}}||
Returns a quotation {{q2}} containing the remaining elements after the first _n_ values of the input quotation {{q1}}, or an empty quotation if {{i}} is greater than the length of {{q1}}. #}

{#op||filter||{{q1}} {{q2}}||{{q3}}||
> Returns a new quotation {{q3}} containing all elements of {{q1}} that satisfy predicate {{q2}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(2 6 8 12)` on the stack:
> > 
> >     (1 37 34 2 6 8 12 21) 
> >     (dup 20 < swap even? and) filter #}

{#op||find||{{q1}} {{q2}}||{{i}}||
> Returns the index of the first element within {{q1}} that satisfies predicate {{q2}}, or -1 if no element satisfies it.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `3` on the stack:
> > 
> >     (1 2 4 8 16) 
> >     (5 >) find #}

{#op||first||{{q}}||{{any}}||
Returns the first element of {{q}}. #}

{#op||flatten||{{q1}}||{{q2}}||
> Flattens all quotations within {{q1}} and returns the resulting sequence {{q2}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(1 2 3 4 5 6 7 8)` on the stack:
> > 
> >     (1 (2 3 4) 5 (6 7) 8) 
> >     flatten #}

{#op||harvest||{{q1}}||{{q2}}||
> Creates a new quotation {{q2}} containing all elements of {{q1}} except for empty quotations.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(1 2 3)` on the stack:
> > 
> >     (1 () () () 2 () 3) 
> >     harvest #}

{#op||in?||{{q}} {{any}}||{{b}}||
Returns {{t}} if {{any}} is contained in {{q}}, {{f}} otherwise.#}

{#op||insert||{{q1}} {{any}} {{i}}||{{q2}}||
Inserts {{any}} as the value of the _n^th_ element {{q1}} (zero-based), and returns the modified copy of the quotation {{q2}}. #}

{#op||intersection||{{q1}} {{q2}}||{{q3}}||
> Calculates the intersection {{q3}} of {{q1}} and {{q2}}.
>
> > %sidebar%
> > Example
> > 
> > The following program leaves `(1 "test")` on the stack:
> > 
> >     (1 2 "test") ("test" "a" true 1) intersection #}

{#op||last||{{q}}||{{any}}||
Returns the last element of {{q}}. #}

{#op||map||{{q1}} {{q2}}||{{q3}}||
Returns a new quotation {{q3}} obtained by applying {{q2}} to each element of {{q1}}.#}

{#op||map-reduce||{{q1}} {{q2}} {{q3}}||{{i}}||
> Applies {{q2}} (map) to each element of {{q1}} and then applies {{q3}} (reduce) to each successive element of {{q1}}. {{q1}} must have at least one element.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `35` on the stack:
> > 
> >     (1 3 5) 
> >     (dup *) (+) map-reduce #}

{#op||partition||{{q1}} {{q2}}||{{q3}} {{q4}}||
> Partitions {{q1}} into two quotations: {{q3}} contains all elements of {{q1}} that satisfy predicate {{q2}}, {{q4}} all the others.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(1 3 5) (2 4 6)` on the stack:
> > 
> >     (1 2 3 4 5 6) 
> >     (odd?) partition #}

{#op||one?||{{q1}} {{q2}}||{{b}}||
Applies predicate {{q2}} to each element of {{q1}} and returns {{t}} if only one element of {{q1}} satisfies predicate {{q2}}, {{f}} otherwise. #}

{#op||prepend||{{any}} {{q}}||({{any}} {{a0p}})||
Returns a new quotation containing the contents of {{q}} with {{any}} prepended. #}

{#op||quote-map||{{q1}}||{{q2}}||
Returns a new quotation {{q2}} obtained by quoting each element of {{q1}}.#}

{#op||reduce||{{q1}} {{any}} {{q2}}||{{i}}||
> Combines each successive element of {{q1}} using {{q2}}. On the first iteration, the first two inputs processed by {{q2}} are {{any}} and the first element of {{q1}}.
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `120` on the stack:
> > 
> >     (1 2 3 4 5) 
> >     1 (*) reduce #}

{#op||reject||{{q1}} {{q2}}||{{q3}}||
Returns a new quotatios {{q3}} including all elements of {{q1}} that do not satisfy predicate {{q2}} (i.e. the opposite of `filter`)#}

{#op||remove||{{q1}} {{i}}||{{q2}}||
Returns the _n^th_ element of {{q1}} (zero-based), and returns the modified copy of the quotation {{q2}}.#}

{#op||rest||{{q1}}||{{q2}}||
Returns a new quotation {{q2}} containing all elements of {{q1}} quotation except for the first. #}

{#op||reverse||{{q1}}||{{q2}}||
Returns a new quotation {{q2}} containing all elements of {{q1}} in reverse order. #}

{#op||set||{{q1}} {{any}} {{i}}||{{q2}}||
Sets the value of the _n^th_ element {{q1}} (zero-based) to {{any}}, and returns the modified copy of the quotation {{q2}}. #}

{#op||shorten||{{q1}} {{i}}||{{q2}}||
Returns a quotation {{q2}} containing the first _n_ values of the input quotation {{q1}}. #}

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

{#op||sort||{{q1}} {{q2}}||{{q3}}||
> Sorts all elements of {{q1}} according to predicate {{q2}}. 
> 
> > %sidebar%
> > Example
> > 
> > The following program leaves `(1 3 5 7 9 13 16)` on the stack:
> > 
> >     (1 9 5 13 16 3 7) '> sort #}

{#op||symmetric-difference||{{q1}} {{q2}}||{{q3}}||
> Calculates the symmetric difference {{q3}} of {{q1}} and {{q2}}.
>
> > %sidebar%
> > Example
> > 
> > The following program leaves `(true "a" 2)` on the stack:
> > 
> >     (1 2 "test") ("test" "a" true 1) symmetric-difference #}

{#op||take||{{q1}} {{i}}||{{q2}}||
Returns a quotation {{q2}} containing the first _n_ values of the input quotation {{q1}}, or {{q1}} itself if {{i}} is greater than the length of {{q1}}. #}

{#op||union||{{q1}} {{q2}}||{{q3}}||
> Calculates the union {{q3}} of {{q1}} and {{q2}}.
>
> > %sidebar%
> > Example
> > 
> > The following program leaves `(true 1 "test" "a" 2)` on the stack:
> > 
> >     (1 2 "test") ("test" "a" true 1) union #}

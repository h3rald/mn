-----
content-type: "page"
title: "Learn: Extending mn"
-----
{@ _defs_.md || 0 @}

{{m}} provides a fairly very basic standard library. If you want to extend it, you basically have the following options:

* Implementing new {{m}} symbols using {{m}} itself
* Embedding {{m}} in your [Nim](https://nim-lang.org) program

## Implementing new mn symbols using mn itself

When you just want to create more high-level {{m}} symbol using functionalities that are already available in mn, the easiest way is to create your own reusable {{m}} symbols in separate files.


```
(dup *)             (pow2) lambda
(dup dup * *)       (pow3) lambda
(dup dup dup * * *) (pow4) lambda

```

Save your code to a file (e.g. *quickpows.mn*) and you can use it in other nim files using the {#link-symbol||read#} symbol to read it and then the {#link-symbol||eval#} to evaluate the program in the current scope:

```
"quickpows.mn" read eval

2 pow3 pow2 puts ;prints 64
```

## Embedding mn in your Nim program

If you'd like to use {{m}} as a scripting language within your own program, and maybe extend it by implementing additional symbols, you can use {{m}} as a Nim library.

To do so:

1. Download and install [Nim](https://nim-lang.org)
2. Import it in your Nim file.
3. Implement a new `proc` to define the module.

The following code is adapted from [HastySite](https://github.com/h3rald/hastysite) (which internally uses [min](https://min-lang.org)) and shows how to define a new `hastysite` module containing some symbols (`preprocess`, `postprocess`, `process-rules`, ...):

```
import mn

proc hastysite_module*(i: In, hs1: HastySite) =
  var hs = hs1
  let def = i.define()
  
  def.symbol("preprocess") do (i: In):
    hs.preprocess()

   def.symbol("postprocess") do (i: In):
    hs.postprocess()

  def.symbol("process-rules") do (i: In):
    hs.interpret(hs.files.rules)

  # ...

  def.finalize("hastysite")
```

Then you need to:

4. Instantiate a new {{m}} interpreter using the `newMnInterpreter` proc.
5. Run the `proc` used to define the module.
6. Call the `interpret` method to interpret a {{m}} file or string:

```
proc interpret(hs: HastySite, file: string) =
  var i = newMnInterpreter(file, file.parentDir)
  i.hastysite_module(hs)
  i.interpret(newFileStream(file, fmRead))
```

> %tip%
> Tip
> 
> For more information on how to create new symbols with Nim, have a look in the [lang.nim](https://github.com/h3rald/mn/tree/master/mnpkg/lang.nim) file in the {{m}} repository, which contains all the symbols included in {{m}}.

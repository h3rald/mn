-----
content-type: "page"
title: "About"
-----
{@ _defs_.md || 0 @}

{{m}} is a concatenative, fully-homoiconic, functional, interpreted programming language. 

This basically means that:

* It is based on a somewhat obscure and slightly unintuitive programming paradigm, think of [Forth](http://www.forth.org/), [Factor](http://factorcode.org/) and [Joy](http://www.kevinalbrecht.com/code/joy-mirror/) but with parentheses for an extra [Lisp](https://common-lisp.net/)y flavor.
* Programs written in {{m}} are actually written using *quotations*, i.e. lists.
* It comes with map, filter, find, and loads of other functional goodies.
* It is probably slower than the average production-ready programming language.

## Why?

{{m}} is [min](https://min-lang.org)'s little brother. When I started implementing min, I wanted to create a small but practical programming language you could use for shell scripting and perform common tasks. As more feature requests piled in, I noticed it slowly became more and more comprehensive and _batteries-included_: I slowly swapped small, less-unknown and somewhat quirky libraries used for regular expressions, compression etc. with more complete and well-known ones, added HTTPS support (and OpenSSL), improved runtime checks when creating symbols, enhanced the type system, and so on. While min can now be used on its own to create quite complex programs, it became less minimal than originally intended.

I tried to add compilation variants to reduce the modules to include but that made it more difficult to maintain and still included complex constructs like dictionaries and the full type system, so one day I decided to... fork it! And that's how {{m}} was born.

Is {{m}} the *successor* of min? No! As I said, it is min's little brother, and it has its own (somewhat more minimalist) life. If you want to create a quick script to glue some shell commands together, then {{m}} is definitely the fastest way to do so. If you want to use the concatenative paradigm to create more complex applications, then min comes with a much bigger toolbox.

## How?

{{m}} is developed entirely in [Nim](https://nim-lang.org) and started off as a fork of the [min](https://min-lang.org) programming language. I took the v0.35.0 codebase and started removing stuff, including the only vowel used in the language name. What else was removed you ask? Let's see... compared to min, {{m}}:

* does not have dictionaries
* does not have modules
* does not have **require**, **include**, etc.
* does not support compilation via Nim
* does not have sigils
* does not have an **operator** symbol, only **lambda**
* does not have any dependency from third-party code
* does not have type classes or type expressions, except for unions of basic types
* does not have JSON interoperability
* does not have error handling, i.e. a try/catch mechanism
* does not have any built-in support for networking, cryptography, etc.
* does not have a fancy REPL with autocompletion

What *does* it have then? Well, {{m}} provides:

* exactly 70 symbols, nearly all of which are borrowed from min
* file reading/writing (via the {#link-symbol||read#} and {#link-symbol||write#} symbols)
* stdin reading ({#link-symbol||gets#}) and writing ({#link-symbol||puts#})
* external command execution via {#link-symbol||run#} and automatic command expansion for all strings wrapped in square brackets
* string evaluation via {#link-symbol||eval#}
* string interpolation via {#link-symbol||interpolate#}
* a basic REPL

## Who?

{{m}} was created and implemented by [Fabio Cevasco](https://cevasco.org).

## When?

{{m}} source code [repository](https://github.com/h3rald/mn) was created on March 23^rd 2021.

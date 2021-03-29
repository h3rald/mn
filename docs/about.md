-----
content-type: "page"
title: "About"
-----
{@ _defs_.md || 0 @}

**mn** is a concatenative, fully-homoiconic, functional, interpreted programming language. 

This basically means that:

* It is based on a somewhat obscure and slightly unintuitive programming paradigm, think of [Forth](http://www.forth.org/), [Factor](http://factorcode.org/) and [Joy](http://www.kevinalbrecht.com/code/joy-mirror/) but with parentheses for an extra [Lisp](https://common-lisp.net/)y flavor.
* Programs written in mn are actually written using *quotations*, i.e. lists.
* It comes with map, filter, find, and loads of other functional goodies.
* It is probably slower than the average production-ready programming language.

## Why?

mn is [min](https://min-lang.org) little brother. When I started implementing min, I wanted to create a small but practical programming language you could use for shell scripting and perform common tasks. As more feature requests piled in, I noticed it slowly became more and more comprehensive and _batteries-included_: I slowly swapped small, less-unknown and somewhat quirky libraries for regular expressions, compression etc. to more complete and well-known ones, I added HTTPS support (and OpenSSL), and then improved runtime checks when creating symbols, enhanced the type system, and so on. While min can now be used on its own to create quite complex programs, it became less minimal that originally intended.

I tried to add compilation variants to reduce the modules to include but that made it more difficult to maintain and still included complex constructs like dictionaries and the full type system, so one day I decided to... fork it! 

## How?

mn is developed entirely in [Nim](https://nim-lang.org) and started off as a fork of the [https://min-lang.org](min) programming language. I took the v0.35.0 codebase and started removing stuff, including the only vowel included in the name. What else was removed you ask? Let's see... compared to min, mn:

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

What *does* it have then? Well:

* exactly 70 symbols, nearly all of which are borrowed from min
* file reading/writing (via the {#link-symbol||read#} and {#link-symbol||write#} symbols)
* stdin reading ({#link-symbol||gets#}) and writing ({#link-symbol||puts#})
* external command execution via {#link-symbol||run#} and automatic command expansion for all strings wrapped in square brackets
* string evaluation via {#link-symbol||eval#}
* string interpolation via {#link-symbol||interpolate#}
* a basic REPL

## Who?

mn was created and implemented by [Fabio Cevasco](https://h3rald.com), 

## When?

mn source code [repository](https://github.com/h3rald/mn) was created on March 23^rd^ 2021.
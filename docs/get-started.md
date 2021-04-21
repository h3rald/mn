-----
content-type: "page"
title: "Get Started"
-----
{@ _defs_.md || 0 @}

You can download one of the following pre-built {{m}} binaries:

-   {#release||{{$version}}||macosx||macOS||x64#}
-   {#release||{{$version}}||windows||Windows||x64#}
-   {#release||{{$version}}||linux||Linux||x64#}

{#release -> [mn v$1 for $3 ($4)](https://github.com/h3rald/mn/releases/download/v$1/mn_v$1_$2_$4.zip) #}

## Building from source

Alternatively, you can build {{m}} from source as follows:

1. Download and install [Nim](https://nim-lang.org).
3. Clone the {{m}} [repository](https://github.com/h3rald/mn).
4. Navigate to the {{m}} repository local folder.
6. Run **./build.sh**.

## Running the mn REPL

To start the {{m}} REPL, run [mn](class:cmd) with no arguments. You will be presented with a prompt displaying the path to the current directory:

> %mn-terminal%
> mn v{{$version}}
> [::](class:prompt)

You can type {{m}} code and press [ENTER](class:kbd) to evaluate it immediately:

> %mn-terminal%
> [::](class:prompt) 2 2 +
> 4
> [::](class:prompt)

The result of each operation will be placed on top of the stack, and it will be available to subsequent operation

> %mn-terminal%
> [::](class:prompt) dup \*
> 16
> [::](class:prompt)

To exit {{m}} shell, press [CTRL+C](class:kbd) or type [0 exit](class:cmd) and press [ENTER](class:kbd).

## Executing an mn Program

To execute a {{m}} script, you can:

-   Run `mn -e:"... program ..."` to execute a program inline.
-   Run `mn myfile.mn` to execute a program contained in a file.

{{m}} also supports running programs from standard input, so the following command can also be used (on Unix-like system) to run a program saved in [myfile.mn](class:file):

> %mn-terminal%
>
> [$](class:prompt) cat myfile.mn | mn

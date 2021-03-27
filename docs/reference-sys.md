-----
content-type: "page"
title: "sys Module"
-----
{@ _defs_.md || 0 @}

{#sig||$||get-env#}

{#alias||$||get-env#}

{#sig||&excl;||system#}

{#alias||&excl;||system#}

{#alias||&excl;&excl;||system!#}

{#sig||&||run#}

{#alias||&||run#}

{#op||.||{{none}}||{{s}}||
Returns the full path to the current directory. #}

{#op||..||{{none}}||{{s}}||
Returns the full path to the parent directory. #}

{#op||chmod||{{sl}} {{i}}||{{none}}||
> Sets the permissions of file or directory {{sl}} to {{i}}. {{i}} is a three-digit representation of user, group and other permissions. See the [Unix Permissions Calculator](http://permissions-calculator.org/) for examples and conversions.
> 
> > %sidebar%
> > Example
> > 
> > The following program makes the file **/tmp/test.txt** readable, writable and executable by its owner, and readable and executable by users of the same group and all other users:
> > 
> > `/tmp/test.txt 755 chmod`#}

{#op||cd||{{sl}}||{{none}}||
Change the current directory to {{sl}}. #}

{#op||cp||{{sl1}} {{sl2}}||{{none}}||
Copies the file or directory {{sl1}} to {{sl2}}. #}

{#op||cpu||{{none}}||{{s}}||
Returns the host CPU. It can be one of the following strings i386, alpha, powerpc, powerpc64, powerpc64el, sparc, amd64, mips, mipsel, arm, arm64. #}

{#op||env?||{{sl}}||{{b}}||
Returns {{t}} if environment variable {{sl}} exists, {{f}} otherwise. #}

{#op||dir?||{{sl}}||{{b}}||
Returns {{t}} if the specified path {{sl}} exists and is a directory. #}

{#op||dirname||{{sl}}||{{s}}||
Returns the path of the directory containing path {{sl}}.#}

{#op||exists?||{{sl}}||{{b}}||
Returns {{t}} if the specified file or directory {{sl}} exists. #}

{#op||file?||{{sl}}||{{b}}||
Returns {{t}} if the specified path {{sl}} exists and is a file. #}

{#op||filename||{{sl}}||{{s}}||
Returns the file name of path {{sl}}.#}

{#op||get-env||{{sl}}||{{s}}||
Returns environment variable {{sl}}. #}

{#op||hardlink||{{sl1}} {{sl2}}||{{none}}||
Creates hardlink {{sl2}} for file or directory {{sl1}}. #}

{#op||ls||{{sl}}||{{q}}||
Returns a quotation {{q}} containing all children (files and directories) of the directory {{sl}}. #}

{#op||ls-r||{{sl}}||{{q}}||
Returns a quotation {{q}} containing all children (files and directories) of the directory {{sl}}, recursively. #}

{#op||mkdir||{{sl}}||{{none}}||
Creates the specified directory {{sl}}. #}

{#op||mv||{{sl1}} {{sl2}}||{{none}}||
Moves the file or directory {{sl1}} to {{sl2}}. #}

{#op||os||{{none}}||{{s}}||
Returns the host operating system. It can be one of the following strings: windows, macosx, linux, netbsd, freebsd, openbsd, solaris, aix, standalone. #}

{#op||put-env||{{sl1}} {{sl2}}||{{s}}||
Sets environment variable {{sl2}} to {{sl1}}. #}

{#op||rm||{{sl}}||{{none}}||
Deletes the specified file {{sl}}. #}

{#op||rmdir||{{sl}}||{{none}}||
Deletes the specified directory {{sl}} and all its subdirectories recursively. #}

{#op||run||{{sl}}||{{d}}||
Executes the external command {{sl}} in the current directory without displaying its output. Returns a dictionary containing the command output and return code (in keys **output** and **code** respectively). #}

{#op||sleep||{{i}}||{{none}}||
Halts program execution for {{i}} milliseconds.#}

{#op||symlink||{{sl1}} {{sl2}}||{{none}}||
Creates symlink {{sl2}} for file or directory {{sl1}}. #}

{#op||symlink?||{{sl}}||{{b}}||
Returns {{t}} if the specified path {{sl}} exists and is a symbolic link. #}

{#op||system||{{sl}}||{{i}}||
Executes the external command {{sl}} in the current directory and pushes its return code on the stack. #}

{#op||unzip||{{sl1}} {{sl2}}||{{none}}||
Decompresses zip file {{sl1}} to directory {{sl2}} (created if not present).#}

{#op||which||{{sl}}||{{s}}||
Returns the full path to the directory containing executable {{sl}}, or an empty string if the executable is not found in **$PATH**. #}

{#op||zip||{{q}} {{sl}}||{{none}}||
Compresses files included in quotation {{q}} into zip file {{sl}}.#}

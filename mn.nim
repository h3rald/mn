import 
  streams, 
  strutils, 
  os,
  mnpkg/parser, 
  mnpkg/value, 
  mnpkg/scope,
  mnpkg/interpreter, 
  mnpkg/utils,
  mnpkg/lang 

export 
  parser,
  interpreter,
  utils,
  value,
  scope,
  lang

proc stdLib*(i: In) =
  i.lang_module

proc interpret*(i: In, s: Stream) =
  i.stdLib()
  i.open(s, i.filename)
  discard i.parser.getToken() 
  try:
    i.interpret()
  except:
    i.error(getCurrentExceptionMsg())
  i.close()

proc interpret*(i: In, s: string): MnValue = 
  i.open(newStringStream(s), i.filename)
  discard i.parser.getToken() 
  try:
    result = i.interpret()
  except:
    i.error(getCurrentExceptionMsg())
  i.close()
    
proc mnFile*(filename: string, op = "interpret", main = true): seq[string] {.discardable.}

proc mnStream(s: Stream, filename: string, op = "interpret", main = true): seq[string] {.discardable.}= 
  var i = newMinInterpreter(filename = filename)
  i.pwd = filename.parentDir
  i.interpret(s)
  newSeq[string](0)

proc mnStr*(buffer: string) =
  mnStream(newStringStream(buffer), "input")

proc mnFile*(filename: string, op = "interpret", main = true): seq[string] {.discardable.} =
  var fn = filename
  if not filename.endsWith(".mn"):
    fn &= ".mn"
  var fileLines = newSeq[string](0)
  var contents = ""
  try:
    fileLines = fn.readFile().splitLines()
  except:
    stderr.writeLine("Cannot read from file: " & fn)
    quit(3)
  if fileLines[0].len >= 2 and fileLines[0][0..1] == "#!":
    contents = ";;\n" & fileLines[1..fileLines.len-1].join("\n")
  else:
    contents = fileLines.join("\n")
  mnStream(newStringStream(contents), fn, op, main)

when isMainModule:
  import 
    terminal,
    parseopt,
    mnpkg/meta

  var exeName = "mn"

  proc printResult(i: In, res: MnValue) =
    if res.isNil:
      return
    if i.stack.len > 0:
      let n = $i.stack.len
      if res.isQuotation and res.qVal.len > 1:
        echo " ("
        for item in res.qVal:
          echo  "   " & $item
        echo " ".repeat(n.len) & ")"
      elif res.isCommand:
        echo " [" & res.cmdVal & "]"
      else:
        echo " $1" % [$i.stack[i.stack.len - 1]]

  proc mnSimpleRepl*(i: var MnInterpreter) =
    i.stdLib()
    var s = newStringStream("")
    i.open(s, "<repl>")
    var line: string
    echo "mn v$#" % pkgVersion
    while true:
      stdout.write(":: ")
      stdout.flushFile()
      line = stdin.readLine()
      let r = i.interpret($line)
      if $line != "":
        i.printResult(r)

  proc mnSimpleRepl*() = 
    var i = newMinInterpreter(filename = "<repl>")
    i.mnSimpleRepl()
      

  let usage* = """  mn v$version - A truly minimal concatenative programming language 
  (c) 2021 Fabio Cevasco
  
  Usage:
    $exe [options] [filename]

  Arguments:
    filename  A $exe file to interpret or compile 
  Options:
    -e, --evaluate            Evaluate a $exe program inline
    -h, --help                Print this help
    -d, --debug               Enable debug messages
    -v, —-version             Print the program version""" % [
      "exe", exeName, 
      "version", pkgVersion, 
  ]

  var file, s: string = ""
  var args = newSeq[string](0)
  var p = initOptParser()
  
  for kind, key, val in getopt(p):
    case kind:
      of cmdArgument:
        args.add key
        if file == "":
          file = key 
      of cmdLongOption, cmdShortOption:
        case key:
          of "debug", "d":
            DEBUG = true 
          of "evaluate", "e":
            if file == "":
              s = val
          of "help", "h":
            if file == "":
              echo usage
              quit(0)
          of "version", "v":
            if file == "":
              echo pkgVersion
              quit(0)
          else:
            discard
      else:
        discard
  var op = "interpret"
  if s != "":
    mnStr(s)
  elif file != "":
    mnFile file, op
  else:
    if isatty(stdin):
      mnSimpleRepl()
      quit(0)
    else:
      mnStream newFileStream(stdin), "stdin", op

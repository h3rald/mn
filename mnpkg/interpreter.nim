import 
  streams, 
  strutils, 
  os,
  osproc,
  critbits,
  algorithm
import 
  value,
  scope,
  parser

type
  MnTrappedException* = ref object of CatchableError
  MnReturnException* = ref object of CatchableError
  MnRuntimeError* = ref object of CatchableError
    data*: MnValue

var DEBUG* {. threadvar .} : bool
DEBUG = false

proc diff*(a, b: seq[MnValue]): seq[MnValue] =
  result = newSeq[MnValue](0)
  for it in b:
    if not a.contains it:
      result.add it

proc newSym*(i: In, s: string): MnValue =
 return MnValue(kind: mnSymbol, symVal: s, filename: i.currSym.filename, line: i.currSym.line, column: i.currSym.column, outerSym: i.currSym.symVal)

proc copySym*(i: In, sym: MnValue): MnValue =
  return MnValue(kind: mnSymbol, symVal: sym.outerSym, filename: sym.filename, line: sym.line, column: sym.column, outerSym: "", docComment: sym.docComment)

proc raiseRuntime*(msg: string) =
  raise MnRuntimeError(msg: msg)

proc dump*(i: MnInterpreter): string =
  var s = ""
  for item in i.stack:
    s = s & $item & " "
  return s

template withScope*(i: In, res:ref MnScope, body: untyped): untyped =
  let origScope = i.scope
  try:
    i.scope = newScopeRef(origScope)
    body
    res = i.scope
  finally:
    i.scope = origScope

template withScope*(i: In, body: untyped): untyped =
  let origScope = i.scope
  try:
    i.scope = newScopeRef(origScope)
    body
  finally:
    i.scope = origScope

proc newMinInterpreter*(filename = "input", pwd = ""): MnInterpreter =
  var path = pwd
  if not pwd.isAbsolute:
    path = joinPath(getCurrentDir(), pwd)
  var stack:MnStack = newSeq[MnValue](0)
  var trace:MnStack = newSeq[MnValue](0)
  var stackcopy:MnStack = newSeq[MnValue](0)
  var pr:MnParser
  var scope = newScopeRef(nil)
  var i:MnInterpreter = MnInterpreter(
    filename: filename, 
    pwd: path,
    parser: pr, 
    stack: stack,
    trace: trace,
    stackcopy: stackcopy,
    scope: scope,
    currSym: MnValue(column: 1, line: 1, kind: mnSymbol, symVal: "")
  )
  return i

proc copy*(i: MnInterpreter, filename: string): MnInterpreter =
  var path = filename
  if not filename.isAbsolute:
    path = joinPath(getCurrentDir(), filename)
  result = newMinInterpreter()
  result.filename = filename
  result.pwd =  path.parentDir
  result.stack = i.stack
  result.trace = i.trace
  result.stackcopy = i.stackcopy
  result.scope = i.scope
  result.currSym = MnValue(column: 1, line: 1, kind: mnSymbol, symVal: "")

proc formatError(sym: MnValue, message: string): string =
  var name = sym.symVal
  return "$1($2,$3) [$4]: $5" % [sym.filename, $sym.line, $sym.column, name, message]

proc formatTrace(sym: MnValue): string =
  var name = sym.symVal
  if sym.filename == "":
    return "<native> in symbol: $1" % [name]
  else:
    return "$1($2,$3) in symbol: $4" % [sym.filename, $sym.line, $sym.column, name]

proc stackTrace*(i: In) =
  var trace = i.trace
  trace.reverse()
  for sym in trace:
    echo sym.formatTrace

proc error*(i: In, message: string) =
  stderr.writeLine(i.currSym.formatError(message))

proc open*(i: In, stream:Stream, filename: string) =
  i.filename = filename
  i.parser.open(stream, filename)

proc close*(i: In) = 
  i.parser.close();

proc push*(i: In, val: MnValue) {.gcsafe.} 

proc apply*(i: In, op: MnOperator, sym = "") {.gcsafe.}=
  if op.kind == mnProcOp:
    op.prc(i)
  else:
    if op.val.kind == mnQuotation:
      var newscope = newScopeRef(i.scope)
      i.withScope(newscope):
        for e in op.val.qVal:
          if e.isSymbol and e.symVal == sym:
            raiseInvalid("Symbol '$#' evaluates to itself" % sym)
          i.push e
    else:
      i.push(op.val)

proc dequote*(i: In, q: var MnValue) =
  if q.kind == mnQuotation:
    i.withScope(): 
      let qqval = deepCopy(q.qVal)
      for v in q.qVal:
        i.push v
      q.qVal = qqval
  else:
    i.push(q)

proc apply*(i: In, q: var MnValue) {.gcsafe.}=
  var i2 = newMinInterpreter("<apply>")
  i2.trace = i.trace
  i2.scope = i.scope
  try:
    i2.withScope(): 
      for v in q.qVal:
        if (v.kind == mnQuotation):
          var v2 = v
          i2.dequote(v2)
        else:
          i2.push v
  except:
    i.currSym = i2.currSym
    i.trace = i2.trace
    raise
  i.push i2.stack.newVal

proc pop*(i: In): MnValue =
  if i.stack.len > 0:
    return i.stack.pop
  else:
    raiseEmptyStack()

# Inherit file/line/column from current symbol
proc pushSym*(i: In, s: string) =
  i.push MnValue(
    kind: mnSymbol, 
    symVal: s, 
    filename: i.currSym.filename, 
    line: i.currSym.line, 
    column: i.currSym.column, 
    outerSym: i.currSym.symVal, 
    docComment: i.currSym.docComment)

proc push*(i: In, val: MnValue) {.gcsafe.}= 
  if val.kind == mnSymbol:
    if not i.evaluating:
      if val.outerSym != "":
        i.currSym = i.copySym(val)
      else:
        i.currSym = val
    i.trace.add val
    if DEBUG:
      echo "-- push  symbol: $#" % val.symVal
    let symbol = val.symVal
    if i.scope.hasSymbol(symbol):
      i.apply i.scope.getSymbol(symbol), symbol
    else: 
      raiseUndefined("Undefined symbol '$1'" % [val.symVal])
    discard i.trace.pop
  elif val.kind == mnCommand:
    if DEBUG:
      echo "-- push command: $#" % val.cmdVal
    let res = execCmdEx(val.cmdVal)
    i.push res.output.strip.newVal
  else:
    if DEBUG:
      echo "-- push literal: $#" % $val
    i.stack.add(val)

proc peek*(i: MnInterpreter): MnValue = 
  if i.stack.len > 0:
    return i.stack[i.stack.len-1]
  else:
    raiseEmptyStack()

template handleErrors*(i: In, body: untyped) =
  try:
    body
  except MnRuntimeError:
    let msg = getCurrentExceptionMsg()
    i.stack = i.stackcopy
    stderr.writeLine("$1:$2,$3 $4" % [i.currSym.filename, $i.currSym.line, $i.currSym.column, msg])
    i.stackTrace()
    i.trace = @[]
    raise MnTrappedException(msg: msg)
  except MnTrappedException:
    raise
  except:
    let msg = getCurrentExceptionMsg()
    i.stack = i.stackcopy
    i.stackTrace()
    i.trace = @[]
    raise MnTrappedException(msg: msg)

proc interpret*(i: In, parseOnly=false): MnValue {.discardable.} =
  var val: MnValue
  var q: MnValue
  if parseOnly:
    q = newSeq[MnValue](0).newVal
  while i.parser.token != tkEof: 
    if i.trace.len == 0:
      i.stackcopy = i.stack
    handleErrors(i) do:
      val = i.parser.parseMinValue(i)
      if parseOnly:
        q.qVal.add val
      else:
        i.push val
  if parseOnly:
    return q
  if i.stack.len > 0:
    return i.stack[i.stack.len - 1]

proc eval*(i: In, s: string, name="<eval>", parseOnly=false): MnValue {.discardable.}=
  var i2 = i.copy(name)
  i2.open(newStringStream(s), name)
  discard i2.parser.getToken() 
  result = i2.interpret(parseOnly)
  i.trace = i2.trace
  i.stackcopy = i2.stackcopy
  i.stack = i2.stack
  i.scope = i2.scope

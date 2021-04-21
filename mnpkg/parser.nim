# Adapted from: https://github.com/Araq/Nimrod/blob/v0.9.6/lib/pure/json.nim
import 
  lexbase, 
  strutils, 
  streams, 
  critbits

import unicode except strip

type
  MnTokenKind* = enum
    tkError,
    tkEof,
    tkString,
    tkCommand,
    tkInt,
    tkFloat,
    tkBracketLe,
    tkBracketRi,
    tkSqBracketLe,
    tkSqBracketRi,
    tkSymbol,
    tkNull,
    tkTrue,
    tkFalse
  MnKind* = enum
    mnInt,
    mnFloat,
    mnQuotation,
    mnCommand,
    mnString,
    mnSymbol,
    mnNull,
    mnBool
  MnEventKind* = enum     ## enumeration of all events that may occur when parsing
    eMinError,             ## an error ocurred during parsing
    eMinEof,               ## end of file reached
    eMinString,            ## a string literal
    eMinInt,               ## an integer literal
    eMinFloat,             ## a float literal
    eMinQuotationStart,    ## start of an array: the ``(`` token
    eMinQuotationEnd,      ## start of an array: the ``)`` token
  MnParserError* = enum        ## enumeration that lists all errors that can occur
    errNone,               ## no error
    errInvalidToken,       ## invalid token
    errStringExpected,     ## string expected
    errBracketRiExpected,  ## ``)`` expected
    errQuoteExpected,      ## ``"`` expected
    errSqBracketRiExpected,## ``]`` expected
    errEOC_Expected,       ## ``*/`` expected
    errEofExpected,        ## EOF expected
    errExprExpected
  MnParserState* = enum 
    stateEof, 
    stateStart, 
    stateQuotation, 
    stateExpectValue
  MnParser* = object of BaseLexer
    a*: string
    doc*: bool
    currSym*: MnValue
    token*: MnTokenKind
    state*: seq[MnParserState]
    kind*: MnEventKind
    err*: MnParserError
    filename*: string
  MnValue* = ref MnValueObject 
  MnValueObject*  = object
    line*: int
    column*: int
    filename*: string
    outerSym*: string
    docComment*: string
    case kind*: MnKind
      of mnNull: discard
      of mnInt: intVal*: BiggestInt
      of mnFloat: floatVal*: BiggestFloat
      of mnCommand: cmdVal*: string
      of mnQuotation:
        qVal*: seq[MnValue]
      of mnString: strVal*: string
      of mnSymbol: symVal*: string
      of mnBool: boolVal*: bool
  MnScopeKind* = enum
    mnNativeScope,
    mnLangScope
  MnScope*  = object
    parent*: ref MnScope
    symbols*: CritBitTree[MnOperator]
    kind*: MnScopeKind
  MnOperatorProc* = proc (i: In) {.gcsafe.}
  MnOperatorKind* = enum
    mnProcOp
    mnValOp
  MnOperator* = object
    sealed*: bool
    case kind*: MnOperatorKind
    of mnProcOp:
      prc*: MnOperatorProc
    of mnValOp:
      quotation*: bool
      val*: MnValue
  MnStack* = seq[MnValue]
  In* = var MnInterpreter
  MnInterpreter* = object
    stack*: MnStack
    trace*: MnStack
    stackcopy*: MnStack
    pwd*: string
    scope*: ref MnScope
    parser*: MnParser
    currSym*: MnValue
    filename*: string
    evaluating*: bool 
  MnParsingError* = ref object of ValueError 
  MnUndefinedError* = ref object of ValueError
  MnEmptyStackError* = ref object of ValueError
  MnInvalidError* = ref object of ValueError
  MnOutOfBoundsError* = ref object of ValueError
  

# Helpers

proc raiseInvalid*(msg: string) =
  raise MnInvalidError(msg: msg)

proc raiseUndefined*(msg: string) =
  raise MnUndefinedError(msg: msg)

proc raiseOutOfBounds*(msg: string) =
  raise MnOutOfBoundsError(msg: msg)

proc raiseEmptyStack*() =
  raise MnEmptyStackError(msg: "Insufficient items on the stack")

const
  errorMessages: array[MnParserError, string] = [
    "no error",
    "invalid token",
    "string expected",
    "')' expected",
    "'\"' expected",
    "']' expected",
    "'*/' expected",
    "EOF expected",
    "expression expected"
  ]
  tokToStr: array[MnTokenKind, string] = [
    "invalid token",
    "EOF",
    "string literal",
    "command literal",
    "int literal",
    "float literal",
    "(", 
    ")",
    "{",
    "}",
    "symbol",
    "null",
    "true",
    "false"
  ]

proc newScope*(parent: ref MnScope, kind = mnLangScope): MnScope =
  result = MnScope(parent: parent, kind: kind)

proc newScopeRef*(parent: ref MnScope, kind = mnLangScope): ref MnScope =
  new(result)
  result[] = newScope(parent, kind)

proc open*(my: var MnParser, input: Stream, filename: string) =
  lexbase.open(my, input)
  my.filename = filename
  my.state = @[stateStart]
  my.kind = eMinError
  my.a = ""

proc close*(my: var MnParser) = 
  lexbase.close(my)

proc getInt*(my: MnParser): int = 
  assert(my.kind == eMinInt)
  return parseint(my.a)

proc getFloat*(my: MnParser): float = 
  assert(my.kind == eMinFloat)
  return parseFloat(my.a)

proc kind*(my: MnParser): MnEventKind = 
  return my.kind

proc getColumn*(my: MnParser): int = 
  result = getColNumber(my, my.bufpos)

proc getLine*(my: MnParser): int = 
  result = my.lineNumber

proc getFilename*(my: MnParser): string = 
  result = my.filename
  
proc errorMsg*(my: MnParser, msg: string): string = 
  assert(my.kind == eMinError)
  result = "$1 [l:$2, c:$3] ERROR - $4" % [
    my.filename, $getLine(my), $getColumn(my), msg]

proc errorMsg*(my: MnParser): string = 
  assert(my.kind == eMinError)
  result = errorMsg(my, errorMessages[my.err])
  
proc errorMsgExpected*(my: MnParser, e: string): string = 
  result = errorMsg(my, e & " expected")

proc raiseParsing*(p: MnParser, msg: string) =
  raise MnParsingError(msg: errorMsgExpected(p, msg))

proc raiseUndefined*(p:MnParser, msg: string) =
  raise MnUndefinedError(msg: errorMsg(p, msg))

proc parseNumber(my: var MnParser) = 
  var pos = my.bufpos
  var buf = my.buf
  if buf[pos] == '-': 
    add(my.a, '-')
    inc(pos)
  if buf[pos] == '.': 
    add(my.a, "0.")
    inc(pos)
  else:
    while buf[pos] in Digits:
      add(my.a, buf[pos])
      inc(pos)
    if buf[pos] == '.':
      add(my.a, '.')
      inc(pos)
  # digits after the dot:
  while buf[pos] in Digits:
    add(my.a, buf[pos])
    inc(pos)
  if buf[pos] in {'E', 'e'}:
    add(my.a, buf[pos])
    inc(pos)
    if buf[pos] in {'+', '-'}:
      add(my.a, buf[pos])
      inc(pos)
    while buf[pos] in Digits:
      add(my.a, buf[pos])
      inc(pos)
  my.bufpos = pos

proc handleHexChar(c: char, x: var int): bool = 
  result = true # Success
  case c
  of '0'..'9': x = (x shl 4) or (ord(c) - ord('0'))
  of 'a'..'f': x = (x shl 4) or (ord(c) - ord('a') + 10)
  of 'A'..'F': x = (x shl 4) or (ord(c) - ord('A') + 10)
  else: result = false # error

proc parseString(my: var MnParser): MnTokenKind =
  result = tkString
  var pos = my.bufpos + 1
  var buf = my.buf
  while true:
    case buf[pos] 
    of '\0': 
      my.err = errQuoteExpected
      result = tkError
      break
    of '"':
      inc(pos)
      break
    of '\\':
      case buf[pos+1]
      of '\\', '"', '\'', '/': 
        add(my.a, buf[pos+1])
        inc(pos, 2)
      of 'b':
        add(my.a, '\b')
        inc(pos, 2)      
      of 'f':
        add(my.a, '\f')
        inc(pos, 2)      
      of 'n':
        add(my.a, '\L')
        inc(pos, 2)      
      of 'r':
        add(my.a, '\C')
        inc(pos, 2)    
      of 't':
        add(my.a, '\t')
        inc(pos, 2)
      of 'u':
        inc(pos, 2)
        var r: int
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        add(my.a, toUTF8(Rune(r)))
      else: 
        # don't bother with the error
        add(my.a, buf[pos])
        inc(pos)
    of '\c': 
      pos = lexbase.handleCR(my, pos)
      buf = my.buf
      add(my.a, '\c')
    of '\L': 
      pos = lexbase.handleLF(my, pos)
      buf = my.buf
      add(my.a, '\L')
    else:
      add(my.a, buf[pos])
      inc(pos)
  my.bufpos = pos # store back

proc parseCommand(my: var MnParser): MnTokenKind =
  result = tkCommand
  var pos = my.bufpos + 1
  var buf = my.buf
  while true:
    case buf[pos] 
    of '\0': 
      my.err = errSqBracketRiExpected
      result = tkError
      break
    of ']':
      inc(pos)
      break
    of '\\':
      case buf[pos+1]
      of '\\', '"', '\'', '/': 
        add(my.a, buf[pos+1])
        inc(pos, 2)
      of 'b':
        add(my.a, '\b')
        inc(pos, 2)      
      of 'f':
        add(my.a, '\f')
        inc(pos, 2)      
      of 'n':
        add(my.a, '\L')
        inc(pos, 2)      
      of 'r':
        add(my.a, '\C')
        inc(pos, 2)    
      of 't':
        add(my.a, '\t')
        inc(pos, 2)
      of 'u':
        inc(pos, 2)
        var r: int
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        if handleHexChar(buf[pos], r): inc(pos)
        add(my.a, toUTF8(Rune(r)))
      else: 
        # don't bother with the error
        add(my.a, buf[pos])
        inc(pos)
    of '\c': 
      pos = lexbase.handleCR(my, pos)
      buf = my.buf
      add(my.a, '\c')
    of '\L': 
      pos = lexbase.handleLF(my, pos)
      buf = my.buf
      add(my.a, '\L')
    else:
      add(my.a, buf[pos])
      inc(pos)
  my.bufpos = pos # store back

proc parseSymbol(my: var MnParser): MnTokenKind = 
  result = tkSymbol
  var pos = my.bufpos
  var buf = my.buf
  if not(buf[pos] in Whitespace):
    while not(buf[pos] in WhiteSpace) and not(buf[pos] in ['\0', ')', '(', ']', '[']):
        if buf[pos] == '"':
          add(my.a, buf[pos])
          my.bufpos = pos
          let r = parseString(my)
          if r == tkError:
            result = tkError
            return
          add(my.a, buf[pos])
          return
        else:
          add(my.a, buf[pos])
          inc(pos)
  my.bufpos = pos

proc addDoc(my: var MnParser, docComment: string, reset = true) =
  if my.doc and not my.currSym.isNil and my.currSym.kind == mnSymbol:
    if reset:
      my.doc = false
    if my.currSym.docComment.len == 0 or my.currSym.docComment.len > 0 and my.currSym.docComment[my.currSym.docComment.len-1] == '\n':
      my.currSym.docComment &= docComment.strip(true, false)
    else:
      my.currSym.docComment &= docComment

proc skip(my: var MnParser) = 
  var pos = my.bufpos
  var buf = my.buf
  while true: 
    case buf[pos]
    of ';':
      # skip line comment:
      if  buf[pos+1] == ';':
        my.doc = true 
      inc(pos, 2)
      while true:
        case buf[pos] 
        of '\0': 
          break
        of '\c': 
          pos = lexbase.handleCR(my, pos)
          buf = my.buf
          my.addDoc "\n"
          break
        of '\L': 
          pos = lexbase.handleLF(my, pos)
          buf = my.buf
          my.addDoc "\n"
          break
        else:
          my.addDoc $my.buf[pos], false
          inc(pos)
    of '#': 
      if buf[pos+1] == '|':
        # skip long comment:
        if buf[pos+2] == '|':
          inc(pos)
          my.doc = true
        inc(pos, 2)
        while true:
          case buf[pos] 
          of '\0': 
            my.err = errEOC_Expected
            break
          of '\c': 
            pos = lexbase.handleCR(my, pos)
            my.addDoc "\n", false
            buf = my.buf
          of '\L': 
            pos = lexbase.handleLF(my, pos)
            my.addDoc "\n", false
            buf = my.buf
          of '|':
            inc(pos)
            if buf[pos] == '|':
              inc(pos)
            if buf[pos] == '#': 
              inc(pos)
              break
            my.addDoc $buf[pos], false
          else:
            my.addDoc $my.buf[pos], false
            inc(pos)
      else: 
        break
    of ' ', '\t': 
      inc(pos)
    of '\c':  
      pos = lexbase.handleCR(my, pos)
      buf = my.buf
    of '\L': 
      pos = lexbase.handleLF(my, pos)
      buf = my.buf
    else:
      break
  my.bufpos = pos

proc getToken*(my: var MnParser): MnTokenKind =
  setLen(my.a, 0)
  skip(my) 
  case my.buf[my.bufpos]
  of '-', '.':
    if my.bufpos+1 <= my.buf.len and my.buf[my.bufpos+1] in '0'..'9':
      parseNumber(my)
      if {'.', 'e', 'E'} in my.a:
        result = tkFloat
      else:
        result = tkInt
    else:
      result = parseSymbol(my)
  of '0'..'9': 
    parseNumber(my)
    if {'.', 'e', 'E'} in my.a:
      result = tkFloat
    else:
      result = tkInt
  of '"':
    result = parseString(my)
  of '(':
    inc(my.bufpos)
    result = tkBracketLe
  of ')':
    inc(my.bufpos)
    result = tkBracketRi
  of '[':
    result = parseCommand(my)
  of '\0':
    result = tkEof
  else:
    result = parseSymbol(my)
    case my.a 
    of "null": result = tkNull
    of "true": result = tkTrue
    of "false": result = tkFalse
    else: 
      discard
  my.token = result


proc next*(my: var MnParser) = 
  var tk = getToken(my)
  var i = my.state.len-1
  case my.state[i]
  of stateEof:
    if tk == tkEof:
      my.kind = eMinEof
    else:
      my.kind = eMinError
      my.err = errEofExpected
  of stateStart: 
    case tk
    of tkString, tkInt, tkFloat, tkTrue, tkFalse:
      my.state[i] = stateEof # expect EOF next!
      my.kind = MnEventKind(ord(tk))
    of tkBracketLe: 
      my.state.add(stateQuotation) # we expect any
      my.kind = eMinQuotationStart
    of tkEof:
      my.kind = eMinEof
    else:
      my.kind = eMinError
      my.err = errEofExpected
  of stateQuotation:
    case tk
    of tkString, tkInt, tkFloat, tkTrue, tkFalse:
      my.kind = MnEventKind(ord(tk))
    of tkBracketLe: 
      my.state.add(stateQuotation)
      my.kind = eMinQuotationStart
    of tkBracketRi:
      my.kind = eMinQuotationEnd
      discard my.state.pop()
    else:
      my.kind = eMinError
      my.err = errBracketRiExpected
  of stateExpectValue:
    case tk
    of tkString, tkInt, tkFloat, tkTrue, tkFalse:
      my.kind = MnEventKind(ord(tk))
    of tkBracketLe: 
      my.state.add(stateQuotation)
      my.kind = eMinQuotationStart
    else:
      my.kind = eMinError
      my.err = errExprExpected

proc eat(p: var MnParser, token: MnTokenKind) = 
  if p.token == token: discard getToken(p)
  else: raiseParsing(p, tokToStr[token])

proc `$`*(a: MnValue): string =
  case a.kind:
    of mnNull:
      return "null"
    of mnBool:
      return $a.boolVal
    of mnSymbol:
      return a.symVal
    of mnString:
      return "\"$1\"" % a.strVal.replace("\"", "\\\"")
    of mnInt:
      return $a.intVal
    of mnFloat:
      return $a.floatVal
    of mnQuotation:
      var q = "("
      for i in a.qVal:
        q = q & $i & " "
      q = q.strip & ")"
      return q
    of mnCommand:
      return "[" & a.cmdVal & "]"

proc `$$`*(a: MnValue): string =
  case a.kind:
    of mnNull:
      return "null"
    of mnBool:
      return $a.boolVal
    of mnSymbol:
      return a.symVal
    of mnString:
      return a.strVal
    of mnInt:
      return $a.intVal
    of mnFloat:
      return $a.floatVal
    of mnQuotation:
      var q = "("
      for i in a.qVal:
        q = q & $i & " "
      q = q.strip & ")"
      return q
    of mnCommand:
      return "[" & a.cmdVal & "]"

proc parseMinValue*(p: var MnParser, i: In): MnValue =
  case p.token
  of tkNull:
    result = MnValue(kind: mnNull)
    discard getToken(p)
  of tkTrue:
    result = MnValue(kind: mnBool, boolVal: true)
    discard getToken(p)
  of tkFalse:
    result = MnValue(kind: mnBool, boolVal: false)
    discard getToken(p)
  of tkString:
    result = MnValue(kind: mnString, strVal: p.a)
    p.a = ""
    discard getToken(p)
  of tkCommand:
    result = MnValue(kind: mnCommand, cmdVal: p.a)
    p.a = ""
    discard getToken(p)
  of tkInt:
    result = MnValue(kind: mnInt, intVal: parseint(p.a))
    discard getToken(p)
  of tkFloat:
    result = MnValue(kind: mnFloat, floatVal: parseFloat(p.a))
    discard getToken(p)
  of tkBracketLe:
    var q = newSeq[MnValue](0)
    discard getToken(p)
    while p.token != tkBracketRi: 
      q.add p.parseMinValue(i)
    eat(p, tkBracketRi)
    result = MnValue(kind: mnQuotation, qVal: q)
  of tkSymbol:
    result = MnValue(kind: mnSymbol, symVal: p.a, column: p.getColumn, line: p.lineNumber, filename: p.filename)
    p.a = ""
    p.currSym = result
    discard getToken(p)
  else:
     let err = "Undefined or invalid value: "&p.a
     raiseUndefined(p, err)
  result.filename = p.filename
  
proc print*(a: MnValue) =
  stdout.write($$a)
  stdout.flushFile()

# Predicates

proc isNull*(s: MnValue): bool =
  return s.kind == mnNull

proc isSymbol*(s: MnValue): bool =
  return s.kind == mnSymbol

proc isQuotation*(s: MnValue): bool = 
  return s.kind == mnQuotation

proc isCommand*(s: MnValue): bool = 
  return s.kind == mnCommand

proc isString*(s: MnValue): bool = 
  return s.kind == mnString

proc isFloat*(s: MnValue): bool =
  return s.kind == mnFloat

proc isInt*(s: MnValue): bool =
  return s.kind == mnInt

proc isNumber*(s: MnValue): bool =
  return s.kind == mnInt or s.kind == mnFloat

proc isBool*(s: MnValue): bool =
  return s.kind == mnBool

proc isStringLike*(s: MnValue): bool =
  return s.isSymbol or s.isString or (s.isQuotation and s.qVal.len == 1 and s.qVal[0].isSymbol)

proc `==`*(a: MnValue, b: MnValue): bool =
  if not (a.kind == b.kind or (a.isNumber and b.isNumber)):
    return false
  if a.kind == mnSymbol and b.kind == mnSymbol:
    return a.symVal == b.symVal
  elif a.kind == mnInt and b.kind == mnInt:
    return a.intVal == b.intVal
  elif a.kind == mnInt and b.kind == mnFloat:
    return a.intVal.float == b.floatVal.float
  elif a.kind == mnFloat and b.kind == mnFloat:
    return a.floatVal == b.floatVal
  elif a.kind == mnFloat and b.kind == mnInt:
    return a.floatVal == b.intVal.float
  elif a.kind == b.kind:
    if a.kind == mnString:
      return a.strVal == b.strVal
    elif a.kind == mnBool:
      return a.boolVal == b.boolVal
    elif a.kind == mnNull:
      return true
    elif a.kind == mnQuotation:
      if a.qVal.len == b.qVal.len:
        var c = 0
        for item in a.qVal:
          if item == b.qVal[c]:
            c.inc
          else:
            return false
        return true
      else:
        return false
  else:
    return false

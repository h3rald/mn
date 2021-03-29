import 
  strutils, 
  algorithm,
  critbits,
  math
import 
  parser, 
  value,
  interpreter

proc floatCompare*(n1, n2: MnValue): bool =
  let
    a:float = if n1.kind != mnFloat: n1.intVal.float else: n1.floatVal
    b:float = if n2.kind != mnFloat: n2.intVal.float else: n2.floatVal
  if a.classify == fcNan and b.classify == fcNan:
    return true
  else:
    const
      FLOAT_MIN_NORMAL = 2e-1022
      FLOAT_MAX_VALUE = (2-2e-52)*2e1023
      epsilon = 0.00001
    let
      absA = abs(a)
      absB = abs(b)
      diff = abs(a - b)

    if a == b:
      return true
    elif a == 0 or b == 0 or diff < FLOAT_MIN_NORMAL:
      return diff < (epsilon * FLOAT_MIN_NORMAL)
    else:
      return diff / min((absA + absB), FLOAT_MAX_VALUE) < epsilon
  
# Library methods

proc symbol*(scope: ref MnScope, sym: string, p: MnOperatorProc) =
  scope.symbols[sym] = MnOperator(prc: p, kind: mnProcOp, sealed: true)

proc symbol*(scope: ref MnScope, sym: string, v: MnValue) =
  scope.symbols[sym] = MnOperator(val: v, kind: mnValOp, sealed: true)

# Validators

proc validUserSymbol*(s: string): bool =
  for i in 0..<s.len:
    case s[i]:
    of 'a'..'z':
      discard
    of '0'..'9', '_':
      if i > 0:
        discard
      else:
        return false
    else:
      return false
  return true

proc validate*(i: In, value: MnValue, t: string): bool {.gcsafe.} 

proc validateValueType*(i: var MnInterpreter, element: string, value: MnValue, vTypes: var seq[string], c: int): bool {.gcsafe.} =
  vTypes.add value.typeName
  let ors = element.split("|")
  for to in ors:
    let ands = to.split("&")
    var andr = true
    for ta in ands:
      var t = ta
      var neg = false
      if t.len > 1 and t[0] == '!':
        t = t[1..t.len-1]
        neg = true
      andr = i.validate(value, t)
      if neg:
        andr = not andr
      if not andr:
        if neg:
          vTypes[c] = t
        else:
          vTypes[c] = value.typeName
          break
    if andr:
      result = true 
      break

proc validateValueType*(i: var MnInterpreter, element: string, value: MnValue): bool {.gcsafe.} =
  var s = newSeq[string](0)
  var c = 0
  return i.validateValueType(element, value, s, c)

proc validate*(i: In, value: MnValue, t: string): bool {.gcsafe.} =
  case t:
    of "bool":
      return value.isBool
    of "null":
      return value.isNull
    of "int":
      return value.isInt
    of "num":
      return value.isNumber
    of "quot":
      return value.isQuotation
    of "cmd":
      return value.isCommand
    of "'sym":
      return value.isStringLike
    of "sym":
      return value.isSymbol
    of "flt":
      return value.isFloat
    of "str":
      return value.isString
    of "a":
      return true
    else:
      raiseInvalid("Unknown type '$#'" % t)


proc expect*(i: var MnInterpreter, elements: varargs[string]): seq[MnValue] {.gcsafe.}=
  let sym = i.currSym.getString
  var valid = newSeq[string](0)
  result = newSeq[MnValue](0)
  let message = proc(invalid: string, elements: varargs[string]): string =
    var pelements = newSeq[string](0)
    for e in elements.reversed:
        pelements.add e
    let stack = pelements.join(" ")
    result = "Incorrect values found on the stack:\n"
    result &= "- expected: " & stack & " $1\n" % sym
    var other = ""
    if valid.len > 0:
      other = valid.reversed.join(" ") & " "
    result &= "- got:      " & invalid & " " & other & sym
  var res = false
  var vTypes = newSeq[string](0)
  var c = 0
  for el in elements:
    let value = i.pop
    result.add value
    res = i.validateValueType(el, value, vTypes, c)
    if res:
      valid.add el
    else:
      raiseInvalid(message(vTypes[c], elements))
    c = c+1
        
proc reqQuotationOfQuotations*(i: var MnInterpreter, a: var MnValue) =
  a = i.pop
  if not a.isQuotation:
    raiseInvalid("A quotation is required on the stack")
  for s in a.qVal:
    if not s.isQuotation:
      raiseInvalid("A quotation of quotations is required on the stack")

proc reqQuotationOfNumbers*(i: var MnInterpreter, a: var MnValue) =
  a = i.pop
  if not a.isQuotation:
    raiseInvalid("A quotation is required on the stack")
  for s in a.qVal:
    if not s.isNumber:
      raiseInvalid("A quotation of numbers is required on the stack")
      
proc reqQuotationOfIntegers*(i: var MnInterpreter, a: var MnValue) =
  a = i.pop
  if not a.isQuotation:
    raiseInvalid("A quotation is required on the stack")
  for s in a.qVal:
    if not s.isInt:
      raiseInvalid("A quotation of integers is required on the stack")

proc reqQuotationOfSymbols*(i: var MnInterpreter, a: var MnValue) =
  a = i.pop
  if not a.isQuotation:
    raiseInvalid("A quotation is required on the stack")
  for s in a.qVal:
    if not s.isSymbol:
      raiseInvalid("A quotation of symbols is required on the stack")

proc reqTwoNumbersOrStrings*(i: var MnInterpreter, a, b: var MnValue) =
  a = i.pop
  b = i.pop
  if not (a.isString and b.isString or a.isNumber and b.isNumber):
    raiseInvalid("Two numbers or two strings are required on the stack")

proc reqStringOrQuotation*(i: var MnInterpreter, a: var MnValue) =
  a = i.pop
  if not a.isQuotation and not a.isString:
    raiseInvalid("A quotation or a string is required on the stack")

proc reqTwoQuotationsOrStrings*(i: var MnInterpreter, a, b: var MnValue) =
  a = i.pop
  b = i.pop
  if not (a.isQuotation and b.isQuotation or a.isString and b.isString):
    raiseInvalid("Two quotations or two strings are required on the stack")
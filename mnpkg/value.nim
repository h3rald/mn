import
  parser,
  hashes

proc typeName*(v: MnValue): string =
  case v.kind:
    of mnInt:
      return "int"
    of mnFloat:
      return "flt"
    of mnCommand: 
      return "cmd"
    of mnQuotation:
      return "quot"
    of mnString:
      return "str"
    of mnSymbol:
      return "sym"
    of mnNull:
      return "null"
    of mnBool:
      return "bool"

# Constructors

proc newNull*(): MnValue =
  return MnValue(kind: mnNull)

proc newVal*(s: string): MnValue =
  return MnValue(kind: mnString, strVal: s)

proc newVal*(s: cstring): MnValue =
  return MnValue(kind: mnString, strVal: $s)

proc newVal*(q: seq[MnValue]): MnValue =
  return MnValue(kind: mnQuotation, qVal: q)

proc newVal*(i: BiggestInt): MnValue =
  return MnValue(kind: mnInt, intVal: i)

proc newVal*(f: BiggestFloat): MnValue =
  return MnValue(kind: mnFloat, floatVal: f)

proc newVal*(s: bool): MnValue =
  return MnValue(kind: mnBool, boolVal: s)

proc newSym*(s: string): MnValue =
  return MnValue(kind: mnSymbol, symVal: s)

proc newCmd*(s: string): MnValue =
  return MnValue(kind: mnCommand, cmdVal: s)

proc hash*(v: MnValue): Hash =
  return hash($v)

# Get string value from string or quoted symbol

proc getFloat*(v: MnValue): float =
  if v.isInt:
    return v.intVal.float
  elif v.isFloat:
    return v.floatVal
  else:
    raiseInvalid("Value is not a number")

proc getString*(v: MnValue): string =
  if v.isSymbol:
    return v.symVal
  elif v.isString:
    return v.strVal
  elif v.isCommand:
    return v.cmdVal
  elif v.isQuotation:
    if v.qVal.len != 1:
      raiseInvalid("Quotation is not a quoted symbol")
    let sym = v.qVal[0]
    if sym.isSymbol:
      return sym.symVal
    else:
      raiseInvalid("Quotation is not a quoted symbol")

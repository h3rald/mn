import
  strutils,
  critbits
import
  parser

proc copy*(s: ref MnScope): ref MnScope =
  var scope = newScope(s.parent)
  scope.symbols = s.symbols
  scope.sigils = s.sigils
  new(result)
  result[] = scope
  
proc getSymbol*(scope: ref MnScope, key: string, acc=0): MnOperator =
  if scope.symbols.hasKey(key):
    return scope.symbols[key]
  else:
    if scope.parent.isNil:
      raiseUndefined("Symbol '$1' not found." % key)
    return scope.parent.getSymbol(key, acc + 1)

proc hasSymbol*(scope: ref MnScope, key: string): bool =
  if scope.isNil:
    return false
  elif scope.symbols.hasKey(key):
    return true
  elif not scope.parent.isNil:
    return scope.parent.hasSymbol(key)
  else:
    return false

proc delSymbol*(scope: ref MnScope, key: string): bool {.discardable.}=
  if scope.symbols.hasKey(key):
    if scope.symbols[key].sealed:
      raiseInvalid("Symbol '$1' is sealed." % key) 
    scope.symbols.excl(key)
    return true
  return false

proc setSymbol*(scope: ref MnScope, key: string, value: MnOperator, override = false): bool {.discardable.}=
  result = false
  # check if a symbol already exists in current scope
  if not scope.isNil and scope.symbols.hasKey(key):
    if not override and scope.symbols[key].sealed:
      raiseInvalid("Symbol '$1' is sealed ." % key) 
    scope.symbols[key] = value
    result = true
  else:
    # Go up the scope chain and attempt to find the symbol
    if not scope.parent.isNil:
      result = scope.parent.setSymbol(key, value, override)

proc getSigil*(scope: ref MnScope, key: string): MnOperator =
  if scope.sigils.hasKey(key):
    return scope.sigils[key]
  elif not scope.parent.isNil:
    return scope.parent.getSigil(key)
  else:
    raiseUndefined("Sigil '$1' not found." % key)

proc hasSigil*(scope: ref MnScope, key: string): bool =
  if scope.isNil:
    return false
  elif scope.sigils.hasKey(key):
    return true
  elif not scope.parent.isNil:
    return scope.parent.hasSigil(key)
  else:
    return false

proc delSigil*(scope: ref MnScope, key: string): bool {.discardable.}=
  if scope.sigils.hasKey(key):
    if scope.sigils[key].sealed:
      raiseInvalid("Sigil '$1' is sealed." % key) 
    scope.sigils.excl(key)
    return true
  return false

proc setSigil*(scope: ref MnScope, key: string, value: MnOperator, override = false): bool {.discardable.}=
  result = false
  # check if a sigil already exists in current scope
  if not scope.isNil and scope.sigils.hasKey(key):
    if not override and scope.sigils[key].sealed:
      raiseInvalid("Sigil '$1' is sealed." % key) 
    scope.sigils[key] = value
    result = true
  else:
    # Go up the scope chain and attempt to find the sigil
    if not scope.parent.isNil:
      result = scope.parent.setSymbol(key, value)

proc previous*(scope: ref MnScope): ref MnScope =
  if scope.parent.isNil:
    return scope 
  else:
    return scope.parent

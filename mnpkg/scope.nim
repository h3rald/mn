import
  strutils,
  critbits
import
  parser

proc copy*(s: ref MnScope): ref MnScope =
  var scope = newScope(s.parent)
  scope.symbols = s.symbols
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

proc previous*(scope: ref MnScope): ref MnScope =
  if scope.parent.isNil:
    return scope 
  else:
    return scope.parent

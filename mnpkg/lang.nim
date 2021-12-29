import 
  critbits, 
  strutils,
  sequtils, 
  algorithm,
  times,
  os
import 
  parser, 
  value, 
  interpreter, 
  utils,
  scope

proc lang_module*(i: In) =
  let def = i.scope

  def.symbol("apply") do (i: In):
    let vals = i.expect("quot")
    var prog = vals[0]
    i.apply prog

  def.symbol("expect") do (i: In):
    var q: MnValue
    i.reqQuotationOfSymbols q
    i.push(i.expect(q.qVal.mapIt(it.getString())).reversed.newVal)
  
  def.symbol("print") do (i: In):
    let a = i.peek
    a.print
  
  def.symbol("read") do (i: In):
    let vals = i.expect("str")
    let file = vals[0].strVal
    var contents = file.readFile
    i.push newVal(contents)
  
  def.symbol("write") do (i: In):
    let vals = i.expect("str", "str")
    let a = vals[0]
    let b = vals[1]
    a.strVal.writeFile(b.strVal)
  
  def.symbol("append") do (i: In):
    let vals = i.expect("str", "str")
    let a = vals[0]
    let b = vals[1]
    var f:File
    discard f.open(a.strVal, fmAppend)
    f.write(b.strVal)
    f.close()

  def.symbol("args") do (i: In):
    var args = newSeq[MnValue](0)
    for par in commandLineParams():
        args.add par.newVal
    i.push args.newVal
  
  def.symbol("exit") do (i: In):
    let vals = i.expect("int")
    quit(vals[0].intVal.int)

  def.symbol("puts") do (i: In):
    let a = i.peek
    echo $$a
  
  def.symbol("gets") do (i: In) {.gcsafe.}:
    i.push stdin.readLine().newVal
    
  def.symbol("symbols") do (i: In):
    var q = newSeq[MnValue](0)
    var scope = i.scope
    while not scope.isNil:
      for s in scope.symbols.keys:
        q.add s.newVal
      scope = scope.parent
    i.push q.newVal

  def.symbol("defined") do (i: In):
    let vals = i.expect("'sym")
    i.push(i.scope.hasSymbol(vals[0].getString).newVal)

  # Language constructs

  def.symbol("let") do (i: In):
    let vals = i.expect("'sym", "a")
    let sym = vals[0]
    var q1 = vals[1]
    var symbol: string
    var isQuot = q1.isQuotation
    q1 = @[q1].newVal
    symbol = sym.getString
    if not validUserSymbol(symbol):
      raiseInvalid("User symbols must start with a letter and contain only letters, numbers, and underscores (_).")
    i.scope.symbols[symbol] = MnOperator(kind: mnValOp, val: q1, sealed: false, quotation: isQuot)
  
  def.symbol("lambda") do (i: In):
    let vals = i.expect("'sym", "quot")
    let sym = vals[0]
    var q1 = vals[1]
    var symbol: string
    symbol = sym.getString
    if not validUserSymbol(symbol):
      raiseInvalid("User symbols must start with a letter and contain only letters, numbers, and underscores (_).")
    i.scope.symbols[symbol] = MnOperator(kind: mnValOp, val: q1, sealed: false, quotation: true)
    
  def.symbol("bind") do (i: In):
    let vals = i.expect("'sym", "a")
    let sym = vals[0]
    var q1 = vals[1]
    var symbol: string
    var isQuot = q1.isQuotation
    q1 = @[q1].newVal
    symbol = sym.getString
    let res = i.scope.setSymbol(symbol, MnOperator(kind: mnValOp, val: q1, quotation: isQuot))
    if not res:
      raiseUndefined("Attempting to bind undefined symbol: " & symbol)
      
  def.symbol("lambdabind") do (i: In):
    let vals = i.expect("'sym", "quot")
    let sym = vals[0]
    var q1 = vals[1] 
    var symbol: string
    symbol = sym.getString
    let res = i.scope.setSymbol(symbol, MnOperator(kind: mnValOp, val: q1, quotation: true))
    if not res:
      raiseUndefined("Attempting to lambda-bind undefined symbol: " & symbol)

  def.symbol("delete") do (i: In):
    let vals = i.expect("'sym")
    let sym = vals[0]
    let res = i.scope.delSymbol(sym.getString) 
    if not res:
      raiseUndefined("Attempting to delete undefined symbol: " & sym.getString)
  
  def.symbol("eval") do (i: In):
    let vals = i.expect("str")
    let s = vals[0]
    i.eval s.strVal

  def.symbol("type") do (i: In):
    let vals = i.expect("a")
    i.push vals[0].typeName.newVal

  def.symbol("quotesym") do (i: In):
    let vals = i.expect("str")
    let s = vals[0]
    i.push(@[i.newSym(s.strVal)].newVal)

  def.symbol("quotecmd") do (i: In):
    let vals = i.expect("str")
    let s = vals[0]
    i.push(@[newCmd(s.strVal)].newVal)
  
  def.symbol("quote") do (i: In):
    let vals = i.expect("a")
    let a = vals[0]
    i.push @[a].newVal
  
  def.symbol("dequote") do (i: In):
    let vals = i.expect("quot")
    var q = vals[0]
    i.dequote(q)

  def.symbol("when") do (i: In):
    let vals = i.expect("quot", "quot")
    var tpath = vals[0]
    var check = vals[1]
    var stack = i.stack
    i.dequote(check)
    let res = i.pop
    i.stack = stack
    if not res.isBool:
      raiseInvalid("Result of check is not a boolean value")
    if res.boolVal == true:
      i.dequote(tpath)
  
  def.symbol("while") do (i: In):
    let vals = i.expect("quot", "quot")
    var d = vals[0]
    var b = vals[1]
    i.dequote(b)
    var check = i.pop
    while check.boolVal == true:
      i.dequote(d)
      i.dequote(b)
      check = i.pop

  def.symbol("os") do (i: In):
    i.push hostOS.newVal

  def.symbol("run") do (i: In):
    let vals = i.expect("'sym")
    let cmd = vals[0]
    let res = execShellCmd(cmd.getString)
    i.push(res.newVal)

  def.symbol("which") do (i: In):
    let vals = i.expect("'sym")
    let s = vals[0]
    i.push s.getString.findExe.newVal

  def.symbol("os") do (i: In):
    i.push hostOS.newVal
  
  def.symbol("cpu") do (i: In):
    i.push hostCPU.newVal

  def.symbol("timestamp") do (i: In):
    i.push getTime().toUnix().newVal

  def.symbol("getstack") do (i: In):
    i.push i.stack.newVal

  def.symbol("setstack") do (i: In):
    let vals = i.expect("quot")
    let q = vals[0]
    i.stack = q.qVal
  
  def.symbol("pop") do (i: In):
    discard i.pop
  
  def.symbol("dup") do (i: In):
    i.push i.peek

  def.symbol("swap") do (i: In):
    let vals = i.expect("a", "a")
    let a = vals[0]
    let b = vals[1]
    i.push a
    i.push b

  def.symbol("cons") do (i: In):
    let vals = i.expect("quot", "a")
    let q = vals[0]
    let v = vals[1]
    i.push newVal(@[v] & q.qVal)

  def.symbol("interpolate") do (i: In):
    var vals = i.expect("quot")
    var prog = vals[0]
    i.apply prog
    vals = i.expect("quot", "str")
    var q = vals[0]
    let s = vals[1]
    var strings = newSeq[string](0)
    for el in q.qVal:
      strings.add $$el
    let res = s.strVal % strings
    i.push res.newVal

  def.symbol("strip") do (i: In):
    let vals = i.expect("'sym")
    let s = vals[0]
    i.push s.getString.strip.newVal
    
  def.symbol("substr") do (i: In):
    let vals = i.expect("int", "int", "'sym")
    let length = vals[0].intVal
    let start = vals[1].intVal
    let s = vals[2].getString
    let index = min(start+length-1, s.len-1) 
    i.push s[start..index].newVal

  def.symbol("split") do (i: In):
    let vals = i.expect("'sym", "'sym")
    let sep = vals[0].getString
    let s = vals[1].getString
    var q = newSeq[MnValue](0)
    for e in s.split(sep):
      q.add e.newVal
    i.push q.newVal

  def.symbol("join") do (i: In):
    let vals = i.expect("'sym", "quot")
    let s = vals[0]
    let q = vals[1]
    i.push q.qVal.mapIt($$it).join(s.getString).newVal 

  def.symbol("length") do (i: In):
    let vals = i.expect("'sym")
    let s = vals[0]
    i.push s.getString.len.newVal
  
  def.symbol("indexof") do (i: In):
    let vals = i.expect("str", "str")
    let reg = vals[0]
    let str = vals[1]
    let index = str.strVal.find(reg.strVal)
    i.push index.newVal

  def.symbol("replace") do (i: In):
    let vals = i.expect("str", "str", "str")
    let s_replace = vals[0].strVal
    let src = vals[1].strVal
    let s_find = vals[2].strVal
    i.push s_find.replace(src, s_replace).newVal

  def.symbol("concat") do (i: In):
    let vals = i.expect("quot", "quot")
    let q1 = vals[0]
    let q2 = vals[1]
    let q = q2.qVal & q1.qVal
    i.push q.newVal
  
  def.symbol("get") do (i: In):
    let vals = i.expect("int", "quot")
    let index = vals[0]
    let q = vals[1]
    let ix = index.intVal
    if q.qVal.len < ix or ix < 0:
      raiseOutOfBounds("Index out of bounds")
    i.push q.qVal[ix.int]
  
  def.symbol("set") do (i: In):
    let vals = i.expect("int", "a", "quot")
    let index = vals[0]
    let val = vals[1]
    let q = vals[2]
    let ix = index.intVal
    if q.qVal.len < ix or ix < 0:
      raiseOutOfBounds("Index out of bounds")
    q.qVal[ix.int] = val
    i.push q
  
  def.symbol("remove") do (i: In):
    let vals = i.expect("int", "quot")
    let index = vals[0]
    let q = vals[1]
    let ix = index.intVal
    if q.qVal.len < ix or ix < 0:
      raiseOutOfBounds("Index out of bounds")
    var res = newSeq[MnValue](0)
    for x in 0..q.qVal.len-1:
      if x == ix:
        continue
      res.add q.qVal[x]
    i.push res.newVal
  
  def.symbol("size") do (i: In):
    let vals = i.expect("quot")
    let q = vals[0]
    i.push q.qVal.len.newVal
  
  def.symbol("included") do (i: In):
    let vals = i.expect("a", "quot")
    let v = vals[0]
    let q = vals[1]
    i.push q.qVal.contains(v).newVal 
  
  def.symbol("map") do (i: In):
    let vals = i.expect("quot", "quot")
    var prog = vals[0]
    let list = vals[1]
    var res = newSeq[MnValue](0)
    for litem in list.qVal:
      i.push litem
      i.dequote(prog)
      res.add i.pop
    i.push res.newVal

  def.symbol("filter") do (i: In):
    let vals = i.expect("quot", "quot")
    var filter = vals[0]
    let list = vals[1]
    var res = newSeq[MnValue](0)
    for e in list.qVal:
      i.push e
      i.dequote(filter)
      var check = i.pop
      if check.isBool and check.boolVal == true:
        res.add e
    i.push res.newVal

  def.symbol("foreach") do (i: In):
    let vals = i.expect("quot", "quot")
    var prog = vals[0]
    var list = vals[1]
    for litem in list.qVal:
      i.push litem
      i.dequote(prog)

  def.symbol("slice") do (i: In):
    let vals = i.expect("int", "int", "quot")
    let finish = vals[0]
    let start = vals[1]
    let q = vals[2]
    let st = start.intVal
    let fn = finish.intVal
    if st < 0 or fn > q.qVal.len-1:
      raiseOutOfBounds("Index out of bounds")
    elif fn < st:
      raiseInvalid("End index must be greater than start index")
    let rng = q.qVal[st.int..fn.int]
    i.push rng.newVal

  def.symbol("nan") do (i: In):
    i.push newVal(NaN)
  
  def.symbol("+inf") do (i: In):
    i.push newVal(Inf)
  
  def.symbol("-inf") do (i: In):
    i.push newVal(NegInf)
  
  def.symbol("+") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(a.intVal + b.intVal)
      else:
        i.push newVal(a.intVal.float + b.floatVal)
    else:
      if b.isFloat:
        i.push newVal(a.floatVal + b.floatVal)
      else:
        i.push newVal(a.floatVal + b.intVal.float)
  
  def.symbol("-") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(b.intVal - a.intVal)
      else:
        i.push newVal(b.floatVal - a.intVal.float)
    else:
      if b.isFloat:
        i.push newVal(b.floatVal - a.floatVal)
      else:
        i.push newVal(b.intVal.float - a.floatVal) 
  
  def.symbol("*") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(a.intVal * b.intVal)
      else:
        i.push newVal(a.intVal.float * b.floatVal)
    else:
      if b.isFloat:
        i.push newVal(a.floatVal * b.floatVal)
      else:
        i.push newVal(a.floatVal * b.intVal.float)
  
  def.symbol("/") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(b.intVal.int / a.intVal.int)
      else:
        i.push newVal(b.floatVal / a.intVal.float)
    else:
      if b.isFloat:
        i.push newVal(b.floatVal / a.floatVal)
      else:
        i.push newVal(b.intVal.float / a.floatVal) 

  def.symbol(">") do (i: In):
    var n1, n2: MnValue
    i.reqTwoNumbersOrStrings n2, n1
    if n1.isNumber and n2.isNumber:
      if n1.isInt and n2.isInt:
        i.push newVal(n1.intVal > n2.intVal)
      elif n1.isInt and n2.isFloat:
        i.push newVal(n1.intVal.float > n2.floatVal)
      elif n1.isFloat and n2.isFloat:
        i.push newVal(n1.floatVal > n2.floatVal)
      elif n1.isFloat and n2.isInt:
        i.push newVal(n1.floatVal > n2.intVal.float)
    else:
        i.push newVal(n1.strVal > n2.strVal)
  
  def.symbol(">=") do (i: In):
    var n1, n2: MnValue
    i.reqTwoNumbersOrStrings n2, n1
    if n1.isNumber and n2.isNumber:
      if n1.isInt and n2.isInt:
        i.push newVal(n1.intVal >= n2.intVal)
      elif n1.isInt and n2.isFloat:
        i.push newVal(n1.intVal.float > n2.floatVal or floatCompare(n1, n2))
      elif n1.isFloat and n2.isFloat:
        i.push newVal(n1.floatVal > n2.floatVal or floatCompare(n1, n2))
      elif n1.isFloat and n2.isInt:
        i.push newVal(n1.floatVal > n2.intVal.float or floatCompare(n1, n2))
    else:
      i.push newVal(n1.strVal >= n2.strVal)
  
  def.symbol("<") do (i: In):
    var n1, n2: MnValue
    i.reqTwoNumbersOrStrings n1, n2
    if n1.isNumber and n2.isNumber:
      if n1.isInt and n2.isInt:
        i.push newVal(n1.intVal > n2.intVal)
      elif n1.isInt and n2.isFloat:
        i.push newVal(n1.intVal.float > n2.floatVal)
      elif n1.isFloat and n2.isFloat:
        i.push newVal(n1.floatVal > n2.floatVal)
      elif n1.isFloat and n2.isInt:
        i.push newVal(n1.floatVal > n2.intVal.float)
    else:
        i.push newVal(n1.strVal > n2.strVal)
  
  def.symbol("<=") do (i: In):
    var n1, n2: MnValue
    i.reqTwoNumbersOrStrings n1, n2
    if n1.isNumber and n2.isNumber:
      if n1.isInt and n2.isInt:
        i.push newVal(n1.intVal >= n2.intVal)
      elif n1.isInt and n2.isFloat:
        i.push newVal(n1.intVal.float > n2.floatVal or floatCompare(n1, n2))
      elif n1.isFloat and n2.isFloat:
        i.push newVal(n1.floatVal > n2.floatVal or floatCompare(n1, n2))
      elif n1.isFloat and n2.isInt:
        i.push newVal(n1.floatVal > n2.intVal.float or floatCompare(n1, n2))
    else:
        i.push newVal(n1.strVal >= n2.strVal)
  
  def.symbol("==") do (i: In):
    var n1, n2: MnValue
    let vals = i.expect("a", "a")
    n1 = vals[0]
    n2 = vals[1]
    if (n1.kind == mnFloat or n2.kind == mnFloat) and n1.isNumber and n2.isNumber:
      i.push newVal(floatCompare(n1, n2))
    else:
      i.push newVal(n1 == n2)
  
  def.symbol("!=") do (i: In):
    var n1, n2: MnValue
    let vals = i.expect("a", "a")
    n1 = vals[0]
    n2 = vals[1]
    if (n1.kind == mnFloat or n2.kind == mnFloat) and n1.isNumber and n2.isNumber:
      i.push newVal(not floatCompare(n1, n2))
    i.push newVal(not (n1 == n2))
  
  def.symbol("!") do (i: In):
    let vals = i.expect("bool")
    let b = vals[0]
    i.push newVal(not b.boolVal)
      
  def.symbol("&&") do (i: In):
    let vals = i.expect("quot")
    let q = vals[0]
    var c = 0
    for v in q.qVal:
      if not v.isQuotation:
        raiseInvalid("A quotation of quotations is expected")
      var vv = v
      i.dequote vv
      let r = i.pop
      c.inc()
      if not r.isBool:
        raiseInvalid("Quotation #$# does not evaluate to a boolean value")
      if not r.boolVal:
        i.push r
        return
    i.push true.newVal
      
  def.symbol("||") do (i: In):
    let vals = i.expect("quot")
    let q = vals[0]
    var c = 0
    for v in q.qVal:
      if not v.isQuotation:
        raiseInvalid("A quotation of quotations is expected")
      var vv = v
      i.dequote vv
      let r = i.pop
      c.inc()
      if not r.isBool:
        raiseInvalid("Quotation #$# does not evaluate to a boolean value")
      if r.boolVal:
        i.push r
        return
    i.push false.newVal

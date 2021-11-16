import 
    std/jsconsole

type JSStream = object

var stdout* {.threadvar.}: JSStream
var stderr* {.threadvar.}: JSStream
var stdin* {.threadvar.}: JSStream

proc write*(o: JSStream, s: varargs[string, `$`]) =
    console.log(s)

proc writeLine*(o: JSStream, s: varargs[string, `$`]) =
    console.log(s)

proc readLine*(o: JSStream): string =
    return "" # TODO: fix

proc flushFile*(o: JSStream) =
    discard

proc deepCopy*[T](v: T): T =
    return v

proc isatty*(s: JSStream): bool =
    return true

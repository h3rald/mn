import 
  os

proc reverse*[T](xs: openarray[T]): seq[T] =
  result = newSeq[T](xs.len)
  for i, x in xs:
    result[result.len-i-1] = x 

proc parentDirEx*(s: string): string =
  return s.parentDir
    
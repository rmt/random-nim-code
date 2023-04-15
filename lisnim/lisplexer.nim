# because strutils.split is not smart enough
iterator smarterSplit*(inp: string): string {.noSideEffect.} =
  var inString = false
  var buf = ""
  for i, c in inp:
    # handle quoted strings
    if inString:
      buf &= c
      if c == '"':
        yield buf
        buf = ""
        inString = false
      continue
    elif c == '"':
      if buf != "":
        yield buf
      buf = "\""
      inString = true
      continue

    # handle '( special-case
    if c == '\'':
      if buf != "":
        yield buf
      buf = "'"
      continue
    elif c == '(' and buf == "'":
      yield "'("
      buf = ""
      continue

    if c in "()' \t\r\n":
      if buf != "":
        yield buf
        buf = ""
      if c notin " \t\r\n":
        yield "" & c
    else:
      buf &= c

  if buf != "":
    yield buf

when isMainModule:
  import strutils except toLower, toUpper

  template prepareString(str: string): string =
    str.replace("\\\"", "\"")

  proc mytokenize(input: string): seq[string] {.noSideEffect.} =
    ##  Convert ``input`` string into sequence of tokens.
    result = @[]
    #let input = input.replace(
    #  "(", " ( ").replace(")", " ) ").replace("' ( ", " '( ").replace(
    #  "\"", " \" ").replace("\\ \" ", "\\\"")
  
    var
      inStr = false
      seqStr: seq[string] = @[]
    for token in smarterSplit(input):
      if inStr:
        if token == "\"":
          inStr = false
          result.add("\"" & seqStr.join(" ").prepareString() & "\"")
          seqStr = @[]
        else:
          seqStr.add(token)
      else: # not inStr
        if token.len > 0:
          if token == "\"":
            inStr = true
          else:
            result.add(token)

  let inp = """
(ask '(  "what is" "your" "$( name )"))
(say '("y'all are crazy"))
[bum]
"""
  for token in mytokenize(inp):
    echo "-> ", token

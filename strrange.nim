when isMainModule:
  let s = "abcdefg"
  echo s[0..3]  # abcd
  echo s[2..^2] # cdef

  echo "---"
  for c, j in s:
    echo c, ": ", j

# abcd
# cdef
# ---
# 0: a
# 1: b
# 2: c
# 3: d
# 4: e
# 5: f
# 6: g

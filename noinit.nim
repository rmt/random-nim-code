proc a =
  var x {.noinit.}: array[4096, uint8]
  for i in 0..<4096:
    x[i] = 7'u8

proc b =
  var x {.noinit.}: array[2048, uint8]
  echo $x

a()
b()  # will show some uninitialized memory, maybe from a() above

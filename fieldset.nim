#
# A working attempt to have a templated set(stringKey, stringValue) method for
# setting non-string values on fields of sub-objects.
#
# The use-case in mind is as a REPL helper, enabling the easy parsing of
# "object.key = value" style commands without a runtime performance hit of
# looking up properties in a table.
#
# I'm not sure this is the best approach to take, but it works. :-)

import strutils

type
  BaseObj = ref object of RootObj
    x: float

  Foo = ref object of BaseObj
    a, b, c: int
    f: float

  Bar = ref object of BaseObj
    a, b, c: float

var
  x = Foo(a: 0, b: 0, c: 0, f: 0.0)
  y = new Bar

method `$`(obj: BaseObj): string {.base.} = `$`(obj[])

method set(obj: BaseObj, key: string, value: string) {.base.} = discard

proc strSet[T: ref object](obj: T; key: string, value: string) =
  for name, v1 in fieldPairs(obj[]):
    if name == key:
      when v1.type is int:
        v1 = parseInt(value)
      when v1.type is float:
        v1 = parseFloat(value)

template register(T: typedesc[BaseObj]) =
  method set(obj: T, key: string, value: string) =
    for name, v1 in fieldPairs(obj[]):
      if name == key:
        when v1.type is int:
          v1 = parseInt(value)
        when v1.type is float:
          v1 = parseFloat(value)
    #strSet(T(obj), key, value)
  method `$`(obj: T): string = `$`(obj[])

register(Foo)
register(Bar)

# and to remind myself how everything works later:
echo "### Initialization ###"
echo "# BaseObj is a ref object with x: int and has base methods for set(key, value: string) and `$`()"
echo "# Foo is a subclass of BaseObj with a, b, c: int"
echo "# Bar is a subclass of BaseObj with a, b, c: float"
echo ""
echo "# register is a template to create type specific set() and $() methods"
echo "register(Foo); register(Bar);"
echo ""
echo "var x = Foo(a: 0, b: 0, c: 0, f: 0.0)"
echo "var y = new Bar  # equiv"
echo "let z: BaseObj = x"
echo ""

echo "### Experiment 1 ###"
let z: BaseObj = x
echo """x.set("a", "1"); x.set("b", "2"); x.set("c", "3"); x.set("f", "4.2");"""
x.set("a", "1")
z.set("b", "2")
z.set("c", "3")
x.set("f", "4.2")
echo "$x is ", $x, " (calls Foo.$ directly)"
echo "$z is ", $z, " (still calls Foo.$ thanks to OO polymorphism)"

echo "\n### Experiment 2 ###"
echo "z is BaseObj == ", $(z is BaseObj)
echo "z of BaseObj == ", $(z of BaseObj)
echo "z of Foo == ", $(z of Foo)
echo "z of Bar == ", $(z of Bar)
#echo x.a, x.b, x.c, " ", x.f

echo "\n### Experiment 3 ###"
echo "# strSet can set any int or float value on any object by key-name"
echo """strSet(y, "a", "42.42")"""
strSet(y, "a", "42.42")

echo "y is ", y
echo "y[] is ", y[]

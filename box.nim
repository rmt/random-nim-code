type
    Animal = object
      name: string

var a = Animal(name: "Fido")
var b: ref Animal

# copy Animal object to a ref Animal
new(b); b[] = a

# see, it's a copy
b.name = "Spot"
echo a.name, " != ", b.name  # prints: Fido != Spot

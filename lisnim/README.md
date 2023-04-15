lisnim - Lisp interpreter in Nim
================================

`NOTE: This was copied from https://github.com/Vladar4/lisnim and modified.`

Inspired by [lis.py](http://norvig.com/lispy.html) by Peter Norvig.

This is "just for fun" project. Don't expect much.

Usage
-----

Linux: `./lis [source1 source2 ...]`

Windows: `.\lis.exe [source1 source2 ...]`

Syntax
------

* Base:
  * `(quote ...) or '(...)`
  * `(list ...)`
  * `(if test conseq alt)`
  * `(echo arg)` Prints and returns `arg`

* Functions:
  * `(def name value)` Binds `value` to `name`
  * `(def (name args...) body)` Defines function `name` with `args`. Equivalent of `(def name (lambda (args...) body))`
  * `(fn-name args...)` Function application

* Lambdas:
  * `(lambda (args...) body)` Anomymous function
  * `(\ (args...) body)` Lambda a la Haskell :) \x -> x + x
  * `(fn arg body)` Lambda of one argument. Useful for curried functions
  * `(fun arg body)` Variant of the above for those of us who like to have some fun
  * `((lambda (x y) (+ x y)) 5 6)` Lambda application

* Sequential evalueation:
  * `(do (expr1) (expr2) ...)`
  Sequential evaluation with results of previous evaluation being saved in local environment. This means that variable `i` defined in `expr1` is visible in all following expressions, but not visible outside of `do`
  * `(begin (expr1) (expr2) ...)` Syntactic variant of the above

Types
-----

* List: `(item1 item2 ...)`
* Number: `int`, `float` or `ratio` e.g. `5`, `3.1415926`, `42/7`
* Bool: `T` or `NIL`
* String: "line of characters bound in quotes"

Built-in functions
------------------

* **Boolean:** `t`, `nil`
* **Type-check:** `bool?`, `number?`, `defined?`
* **Check:** `nil?`, `null?`
* **Constants:** `pi`, `e`
* **Arithmetics:** `+`, `-`, `*`, `/`, `max`, `min`, `abs`, `round`, `mod`, `odd?`, `even?`
* **Comparison:** `=`, `!=`, `>`, `<`, `>=`, `<=`
* **List:** `cons`, `snoc`, `car`, `cdr`, `len`
* **Output:** `echo`, `print`
* **Strings:** capitalize, upcase, downcase, len, char, format, fmt
* **Exit:** `exit`, `quit` (with optional errorcode)

Example
-------

```
(def (factorial n) (if (<= n 1) 1 (\* n (factorial (- n 1)))))

(def (map f ls)  (if (nil? ls)
  '()
  (cons (f (car ls)) (map f (cdr ls)))))

(echo (map (fn x (+ x 1)) '(1 2 3 4)))   ; output: ( 2 3 4 5 )

(fn () (+ 5 6))   ; returns anonymous function 'fn ()'
((fn () (+ 5 6))) ; anonymous function application

(def somefun
  (fn x
    (fn y
      (+ x y))))  ; curried function

(somefun)         ; => fn (x) -> fn (y) partial application (though 'fn (y)' not showed)
(somefun 5)       ; => fn (y)  partial application
(somefun 5 6)     ; => 11 fully applied
((somefun 5) 6)   ; same as above
(((somefun) 5) 6) ; same as above
((somefun) 5 6)   ; save as above
```

Building
--------

To build:
`nim c lis.nim`

To run on Linux:

`./lis`

`./lis filename`

To run on Windows:

`.\lis.exe`

`.\lis.exe filename`


Embedding:
----------

```nim
  import lis

  proc myfunc(args: openarray[Atom]): Atom {.cdecl.} =
    stdout.write "This is my own function! "
    for arg in args:
      stdout.write $arg
    stdout.write "\n"

  setAtom("myfunc", atom myfunc)
  discard execLine("""(myfunc "hello," " world" "!")""")
```

Notes
-----

* Nested functions ARE now supported.

```
(def (f x)
  (do
    (def (g x) (+ x 1))
    (g x)))
 ; `g` is visible inside `f`, but not outside
```

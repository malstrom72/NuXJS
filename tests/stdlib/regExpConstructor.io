> var re = new RegExp(/e/g);
> print(re.lastIndex)
> print(re.test("ee"))
> print(re.lastIndex)
< 0
< true
< 1
-
> var re = RegExp(/e/g);
> print(re.lastIndex)
> print(re.test("ee"))
> print(re.lastIndex)
< 0
< true
< 1
-
> try { var re = RegExp(/e/g, "i") } catch (x) { print(x) }
< TypeError: Cannot supply flags when constructing one RegExp from another
-
> try { var re = new RegExp(/e/g, "i") } catch (x) { print(x) }
< TypeError: Cannot supply flags when constructing one RegExp from another
-
> var re = RegExp("e", "g");
> print(re.lastIndex)
> print(re.test("ee"))
> print(re.lastIndex)
< 0
< true
< 1
-
> re = /e/g;
> print(re.lastIndex)
> print(re.test("ee"))
> print(re.lastIndex)
< 0
< true
< 1
-

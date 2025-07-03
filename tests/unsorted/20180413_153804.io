> x = 8
> y = 123
> print(eval("out: {try { } finally {} }"))
< undefined
-
> print(eval("out: {5;try { } finally {} }"))
< 5
-
> print(eval("out: {try { 5} finally {} }"))
< 5
-
> print(eval("out: {try { } finally {5} }"))
< undefined
-
> print(eval("out: {5;try {3 } finally {} }"))
< 3
-
> print(eval("out: {5;try {3 } finally {8} }"))
< 3
-
> print(eval("out: {try {break out } finally {} }"))
< undefined
-
> print(eval("out: {try {break out } finally {8} }"))
< undefined
-
> print(eval("out: {try {break out } finally {x+x} }"))
< undefined
-
> print(eval("out: { 55; try {break out } finally {8} }"))
< 55
-
> print(eval("out: { 55; try {break out } finally {x+x} }"))
< 55
-
> print(eval("out: {try {y+y;break out } finally {x+x} }"))
< 246
-
> print(eval("out: {try {y+y } finally {x+x; break out} }"))
< 16
-
> print(eval("out: {try {y+y;break out } finally {x+x; break out} }"))
< 16
-
> print((function() { out: {try { } finally {} } })())
< undefined
-
> print((function() { out: {5;try { } finally {} } })())
< undefined
-
> print((function() { out: {try { 5} finally {} } })())
< undefined
-
> print((function() { out: {try { } finally {5} } })())
< undefined
-
> print((function() { out: {5;try {3 } finally {} } })())
< undefined
-
> print((function() { out: {5;try {3 } finally {8} } })())
< undefined
-
> print((function() { out: {try {break out } finally {} } })())
< undefined
-
> print((function() { out: {try {break out } finally {8} } })())
< undefined
-
> print((function() { out: {try {break out } finally {x+x} } })())
< undefined
-
> print((function() { out: {try {y+y;break out } finally {x+x} } })())
< undefined
-
> print((function() { out: {try {y+y } finally {x+x; break out} } })())
< undefined
-
> print((function() { out: {try {y+y;break out } finally {x+x; break out} } })())
< undefined
-
> print((function() { out: {try {return 123 } finally {} } })())
< 123
-
> print((function() { out: {try {return y+y } finally {} } })())
< 246
-
> print((function() { out: {try {return 123 } finally {return 8} } })())
< 8
-
> print((function() { out: {try {return y+y } finally {return 8} } })())
< 8
-
> print((function() { out: {try {return 123 } finally {return x+x} } })())
< 16
-
> print((function() { out: {try {return y+y } finally {return x+x} } })())
< 16
-

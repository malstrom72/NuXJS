> try { eval('var r = /(/;'); print('no error'); } catch (e) { print(e instanceof SyntaxError); }
< true
-

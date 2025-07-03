> try { TypeError = function() { print("BOOHOO"); }; o = { toString: function() { return {} } }; print('' + o); } catch (x) { print(x) }
< TypeError: Error converting object to primitive type
-
> try { SyntaxError = function() { print("BOOHOO"); }; print(JSON.parse("{")) } catch (x) { print(x) }
< SyntaxError: Error parsing JSON
-
> try { SyntaxError = function() { print("BOOHOO"); }; print(eval("{")) } catch (x) { print(x) }
< SyntaxError: Expected '}'
-
> try { SyntaxError = function() { print("BOOHOO"); }; throw SyntaxError("help") } catch (x) { print(x) }
< BOOHOO
< undefined
-

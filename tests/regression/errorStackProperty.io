> var direct = new Error("direct check"); print(typeof direct.stack === "undefined"); print('stack' in direct === false);
< true
< true
-
> try { throw new Error("caught once"); } catch (err) { var lines = err.stack.split("\n"); print(typeof err.stack === "string"); print(err.stack.indexOf("caught once") >= 0); print(typeof err.error === "undefined"); print(lines[0].indexOf("Error: caught once") === 0); print(lines[1].indexOf("    at ") === 0); }
< true
< true
< true
< true
< true
-
> (function() { function bounce() { try { throw new Error("bounce around"); } catch (err) { throw err; } } try { bounce(); } catch (err) { var lines = err.stack.split("\n"); print(err.stack.indexOf("bounce around") >= 0); print(typeof err.error === "undefined"); print(lines[0].indexOf("Error: bounce around") === 0); print(lines[1].indexOf("    at ") === 0); } })()
< true
< true
< true
< true
-
> try { ({}).notAFunction(); } catch (err) { var lines = err.stack.split("\n"); print(err instanceof Error); print(typeof err.stack === "string"); print(err.stack.indexOf("TypeError") >= 0); print(typeof err.error === "undefined"); print(lines[0].indexOf("TypeError:") === 0); print(lines[1].indexOf("    at ") === 0); }
< true
< true
< true
< true
< true
< true
-

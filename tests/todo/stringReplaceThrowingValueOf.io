> try {
>     "a".replace("a", {
>         toString: function(){ return { }; },
>         valueOf: function(){ throw new Error("Y"); }
>     });
> } catch (e) {
>     print(e.message);
> }
< Y
-

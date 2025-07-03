> /*
> Had a bug with "interactive" REPL mode which extend the global "function frame" as new variables are added.
> This entire thing might not be an issue in the future as I think the global "function frame" is an ugly workaround to
> begin with.
> */
> var STRIDE = (8 + 2);
> var BOARD_SIZE = (8 + 4) * STRIDE;
> function fillArray(a, value) {
> for (var i = 0; i < a.length; ++i) a[i] = value;
> return a;
> }
> print(typeof BOARD_SIZE);
< number
> function create1DArray(dim, initValue) {
> return fillArray(new Array(dim), initValue);
> };
> print(typeof BOARD_SIZE);
< number
> var board = create1DArray(BOARD_SIZE, 0);

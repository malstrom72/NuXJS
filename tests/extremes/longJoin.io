// A string built past 2^27 characters fills the last of StringBuilder's buffers, and joining must keep all of it.
> var piece = "x";
> while (piece.length < 1048576) { piece += piece; }
> var parts = [];
> for (var i = 0; i < 130; ++i) { parts.push(piece); }
> print(parts.join("").length);
< 136314880

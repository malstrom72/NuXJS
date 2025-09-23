> function payload(index) {
>   return {
>     tag: "entry-" + index,
>     index: index,
>     wrap: { ok: true, id: index }
>   };
> }
> var table = {};
> for (var i = 0; i < 256; ++i) {
>   table["prop" + i] = payload(i);
> }
> gc();gc();gc();
> var ok = true;
> for (var i = 0; i < 256; ++i) {
>   var slot = table["prop" + i];
>   if (!slot || slot.index !== i || slot.tag !== "entry-" + i || !slot.wrap.ok || slot.wrap.id !== i) {
>     ok = false;
>     break;
>   }
> }
> print(ok)
< true
-
> var keys = [];
> for (var i = 0; i < 256; ++i) {
>   keys.push("prop" + i);
> }
> keys.sort(function (a, b) {
>   return table[b].index - table[a].index;
> });
> gc();gc();gc();
> var check = true;
> for (var j = 0; j < keys.length; ++j) {
>   var slot = table[keys[j]];
>   if (!slot.wrap.ok || slot.index !== 255 - j) {
>     check = false;
>     break;
>   }
> }
> print(check)
< true
-
> for (var i = 0; i < 128; ++i) {
>   delete table["prop" + i];
> }
> gc();gc();
> for (var i = 0; i < 128; ++i) {
>   table["prop" + i] = {
>     tag: "reseed-" + i,
>     index: i,
>     wrap: { ok: true, id: i * 7 }
>   };
> }
> gc();gc();
> var stable = true;
> for (var i = 0; i < 256; ++i) {
>   var slot = table["prop" + i];
>   if (!slot) {
>     stable = false;
>     break;
>   }
>   if (i < 128) {
>     if (slot.tag !== "reseed-" + i || slot.wrap.id !== i * 7) {
>       stable = false;
>       break;
>     }
>   } else if (slot.tag !== "entry-" + i || slot.wrap.id !== i) {
>     stable = false;
>     break;
>   }
> }
> print(stable)
< true
-

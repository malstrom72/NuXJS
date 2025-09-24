// CLI:
> try {
> new Function.prototype();
> print("constructed");
> } catch (e) {
> print(e.name);
> print(e.message);
> }
< TypeError
< Function.prototype is not a constructor

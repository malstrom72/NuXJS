> try { Object.prototype.valueOf.call(null); } catch (e) { print(e.name); }
< TypeError
-
> try { Object.prototype.valueOf.call(undefined); } catch (e) { print(e.name); }
< TypeError
-

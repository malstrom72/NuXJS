> try { Object.prototype.toString.call(undefined); } catch (e) { print(e.name); }
< TypeError
-
> try { Object.prototype.toString.call(null); } catch (e) { print(e.name); }
< TypeError
-

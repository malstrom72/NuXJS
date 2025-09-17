> try { print(String.prototype.replace.call(undefined, 'd', 'D')) } catch (e) { print(e.name) }
> try { print(String.prototype.replace.call(null, 'n', 'N')) } catch (e) { print(e.name) }

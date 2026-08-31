var e = new Error("boom");
Object.defineProperty(e, "name", { get: function() { return "Custom"; }, configurable: true });
e.message = "y";
print("String(e)=" + String(e));
print("e.name=" + e.name);
print("hasOwn name=" + e.hasOwnProperty("name"));

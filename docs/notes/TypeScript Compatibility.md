# TypeScript Compatibility

NuXJS builds in two editions: the **es5 build** (`NUXJS_ES5`) implements ECMAScript 5.1, and the **es3 build**
implements ECMAScript 3 with a few ES5 additions. When compiling TypeScript code for the engine, emit ES5 output for
the es5 build, or ES3 output for the es3 build. The recommended compiler is **TypeScript 4.4.4**: it is the last release that down-levels untagged template literals into plain `+` string concatenations. Starting with 4.5, TypeScript instead emits `String.prototype.concat()` calls (e.g. `"Hello, ".concat(name)`). NuXJS does implement `String.prototype.concat`, so that output still runs correctly - but the inline `+` form produced by 4.4.4 is faster on the engine, which is why 4.4.4 is preferred if you want to freely use the `${}` syntax in your sources.

(`--target ES3` itself remained available through TypeScript 5.4 - it was deprecated in 5.0 and stopped having any effect in 5.5 - but the template-literal emit style, not ES3 availability, is the reason for pinning to 4.4.4.)

The declarations are layered the way TypeScript's own `lib.*` files are. `docs/examples/lib.NuXJS.d.ts` contains a
trimmed version of the standard library declarations matching the **es3 build**; `docs/examples/lib.NuXJS.es5.d.ts`
re-opens the same interfaces and adds what the **es5 build** provides (`Array.prototype.map`, `Function.prototype.bind`,
the `Object` reflection statics, `String.prototype.trim`, `Date.now`, the URI handlers, accessor fields in
`PropertyDescriptor`). Pass the base file alone with `--lib` when targeting the es3 build - calling an es5-only member
is then a compile error rather than a runtime surprise - or both files when targeting the es5 build.

The es5 build provides the full ES5.1 library - `Array.prototype.map`, `Function.prototype.bind`, `Date.now`, the
`Object` reflection statics and so on - so no polyfills are needed there for ES5-level output. The **es3 build** does
not provide them, and neither build provides ES6 additions such as `Object.assign` or `Math.sign`; you may want those
for compatibility with third-party code. The following polyfills work well:

```ts
// Simple (not strictly identical) polyfill for ES6 Object.assign
Object.defineProperty(Object, "assign", {
	value: function (target: any, _varArgs: any) {
		for (let i = 1; i < arguments.length; ++i) {
			const o = arguments[i];
			for (let p in o) {
				if (o.hasOwnProperty(p)) {
					target[p] = o[p];
				}
			}
		}
		return target;
	},
	writable: true,
	configurable: true,
});

declare interface Array<T> {
	map<U>(callbackfn: (value: T, index: number, array: T[]) => U, thisArg?: any): U[];
}
if (!Array.prototype.map) {
	Array.prototype.map = function (callbackfn /*, thisArg*/) {
		let T, A, k;
		if (this == null) {
			throw new TypeError("this is null or not defined");
		}
		const O = Object(this);
		const len = O.length >>> 0;
		if (typeof callbackfn !== "function") {
			throw new TypeError(callbackfn + " is not a function");
		}
		if (arguments.length > 1) {
			T = arguments[1];
		}
		A = new Array(len);
		k = 0;
		while (k < len) {
			if (k in O) {
				const kValue = O[k];
				const mappedValue = callbackfn.call(T, kValue, k, O);
				Object.defineProperty(A, k, {
					value: mappedValue,
					writable: true,
					enumerable: true,
					configurable: true,
				});
			}
			k++;
		}
		return A;
	};
}

declare interface DateConstructor {
	now(): number;
}
Date.now = function now() {
	return new Date().getTime();
};

declare interface Math {
	sign(x: number): number;
	cbrt(x: number): number;
	log10(x: number): number;
}
Math.sign = function sign(x: number): number {
	return +(x > 0) - +(x < 0) || +x;
};
Math.cbrt = function cbrt(x: number): number {
	return x < 0 ? -Math.pow(-x, 1 / 3) : Math.pow(x, 1 / 3);
};
Math.log10 = function log10(x: number): number {
	return Math.log(x) * Math.LOG10E;
};
```

None of these functions are declared in `lib.NuXJS.d.ts`, so NuXJS does not depend on them. They simply make it easier to run code that expects these ES5/ES6 features.

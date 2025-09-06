# TypeScript Compatibility

NuXJS now implements most of ECMAScript 5.1. When compiling TypeScript code for the engine you should emit ES5 output. The TypeScript compiler supports `--target ES5` in current releases, so you can use the latest version.

The file `examples/lib.NuXJS.d.ts` contains a trimmed version of the standard library declarations that match the runtime features of NuXJS. Add it to your build with the `--lib` option to get accurate type checking.

NuXJS now ships ES5.1 built‑ins like `Array.prototype.map` and `Date.now`, but still lacks newer helpers such as `Object.assign` or `Math.sign`. These functions are not referenced by `lib.NuXJS.d.ts`, so TypeScript does not require them, but you may want them for compatibility with third‑party code. The following polyfills cover a few ES6 conveniences:

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

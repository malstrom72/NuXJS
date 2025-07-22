# TypeScript Compatibility

NuXJS targets ECMAScript 3 with a few ES5 additions. When compiling TypeScript code for the engine you must emit ES3 output. The last TypeScript release that supports `--target ES3` is **4.4.4**, which still optimizes template string literals into efficient concatenations so you can freely use the `${}` syntax in your sources.

The file `examples/lib.NuXJS.d.ts` contains a trimmed version of the standard library declarations that match the runtime features of NuXJS. Add it to your build with the `--lib` option to get accurate type checking.

NuXJS itself does not provide modern built‑ins such as `Object.assign` or `Array.prototype.map`. These helpers are not referenced by `lib.NuXJS.d.ts`, so TypeScript does not require them, but you may want them for compatibility with third‑party code. The following polyfills work well:

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
    configurable: true
});

declare interface Array<T> {
    map<U>(callbackfn: (value: T, index: number, array: T[]) => U, thisArg?: any): U[];
}
if (!Array.prototype.map) {
    Array.prototype.map = function (callbackfn/*, thisArg*/) {
        let T, A, k;
        if (this == null) {
            throw new TypeError('this is null or not defined');
        }
        const O = Object(this);
        const len = O.length >>> 0;
        if (typeof callbackfn !== 'function') {
            throw new TypeError(callbackfn + ' is not a function');
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
                    configurable: true
                });
            }
            k++;
        }
        return A;
    };
}

declare interface DateConstructor {
    now(): number;
};
Date.now = function now() { return new Date().getTime(); }

declare interface Math {
    sign(x: number): number;
    cbrt(x: number): number;
    log10(x: number): number;
};
Math.sign = function sign(x: number): number { return (+(x > 0) - +(x < 0)) || +x; }
Math.cbrt = function cbrt(x: number): number { return x < 0 ? -Math.pow(-x, 1 / 3) : Math.pow(x, 1 / 3); }
Math.log10 = function log10(x: number): number { return Math.log(x) * Math.LOG10E; };
```

None of these functions are declared in `lib.NuXJS.d.ts`, so NuXJS does not depend on them. They simply make it easier to run code that expects these ES5/ES6 features.

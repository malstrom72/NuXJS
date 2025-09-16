> (function() {
>     print("*** prototypes ***");
>     
>     function sort(a) {
>         for (i = 0; i < a.length - 1; ++i) {
>             for (j = i + 1; j < a.length; ++j) {
>                 if (a[j] < a[i]) {
>                     a[i] = [ a[j], a[j] = a[i] ][0];
>                 }
>             }
>         }
>         return a;
>     }
>     var a = sort([ "pok", "adf", "viusdh", "oqritj", "qthreguajf", "avpok", "pok" ]);
>     for (var i = 0; i < a.length; ++i) print(a[i]);
>     
>     function contents(o) {
>         var keys = [ ];
>         for (var i in o) {
>             keys[keys.length] = i;
>         }
>         sort(keys);
>         var s = "{ ";
>         for (var i = 0; i < keys.length; ++i) {
>             s += keys[i] + ": " + o[keys[i]] + (i < keys.length - 1 ? ", " : ""); 
>         }
>         return s + " }";
>     }
>     print(contents({}));
>     print(contents({ "kzxcjvn": "oaierjf", "goiegjf": "odisjv", "kjscnv": "oeriuf", "asdf": "poqker" }));
>     
>     function ChainA(a, b, c, d) { this.shadowProperty = "ChainA value"; this.toString = function() { return this.shadowProperty; }; };
>     ChainA.prototype.rootProperty = "Root value";
>     print("typeof ChainA.prototype.constructor: " + typeof ChainA.prototype.constructor);
>     ChainA.prototype.constructor = 12345;
>     print("ChainA.prototype.constructor: " + ChainA.prototype.constructor);
>     print("contents(ChainA.prototype): " + contents(ChainA.prototype));
>     print("delete ChainA.prototype.constructor: " + delete ChainA.prototype.constructor);
>     print("delete ChainA.prototype: " + delete ChainA.prototype);
>     ChainA.prototype.constructor = 12345;
>     print("contents(ChainA.prototype): " + contents(ChainA.prototype));
>     
>     function ChainB() { this.chainAProperty = this.shadowProperty = "ChainB value"; };
>     ChainB.prototype = new ChainA();
>     function ChainC() { this.chainBProperty = this.shadowProperty = "ChainC value"; };
>     ChainC.prototype = new ChainB();
>     
> /* FIX : reenable
>     function Damaged() { }
>     Damaged.prototype = 12345;
>     var damaged = new Damaged;
>     Object.prototype.sdfnkdan = 'o3htieofd';
>     print("damaged.sdfnkdan="+damaged.sdfnkdan);
>     print("delete Object.prototype.sdfnkdan="+(delete Object.prototype.sdfnkdan));
> */
>     var chain = new ChainC();
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("chain.chainBProperty: " + chain.chainBProperty);
>     print("chain.chainAProperty: " + chain.chainAProperty);
>     print("chain.rootProperty: " + chain.rootProperty);
>     print('rootProperty' in chain);
>     print("chain: " + chain);
>     print("'shadowProperty' in chain: " + ('shadowProperty' in chain));
>     print("delete chain.shadowProperty: " + delete chain.shadowProperty);
>     print("'shadowProperty' in chain: " + ('shadowProperty' in chain));
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("delete chain.shadowProperty: " + delete chain.shadowProperty);
>     print("'shadowProperty' in chain: " + ('shadowProperty' in chain));
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("chain: " + chain);
>     
>     var chain = new ChainB();
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("chain.chainBProperty: " + chain.chainBProperty);
>     print("chain.chainAProperty: " + chain.chainAProperty);
>     print("chain.rootProperty: " + chain.rootProperty);
>     print("chain: " + chain);
>     print("delete chain.shadowProperty: " + delete chain.shadowProperty);
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("delete chain.shadowProperty: " + delete chain.shadowProperty);
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("chain: " + chain);
>     print("'shadowProperty' in chain: " + ('shadowProperty' in chain));
>     print("delete ChainB.prototype.shadowProperty: " + delete ChainB.prototype.shadowProperty);
>     print("'shadowProperty' in chain: " + ('shadowProperty' in chain));
>     print("chain.shadowProperty: " + chain.shadowProperty);
>     print("chain: " + chain);
>     
>     ChainB.prototype.toString = undefined;
>     chain = new ChainC;
>     print(contents(chain));
>     print(delete ChainC.prototype.shadowProperty);
>     print(contents(chain));
>     print(delete chain.shadowProperty);
>     print(contents(chain));
> })();
< *** prototypes ***
< adf
< avpok
< oqritj
< pok
< pok
< qthreguajf
< viusdh
< {  }
< { asdf: poqker, goiegjf: odisjv, kjscnv: oeriuf, kzxcjvn: oaierjf }
< typeof ChainA.prototype.constructor: function
< ChainA.prototype.constructor: 12345
< contents(ChainA.prototype): { rootProperty: Root value }
< delete ChainA.prototype.constructor: true
< delete ChainA.prototype: false
< contents(ChainA.prototype): { constructor: 12345, rootProperty: Root value }
< chain.shadowProperty: ChainC value
< chain.chainBProperty: ChainC value
< chain.chainAProperty: ChainB value
< chain.rootProperty: Root value
< true
< chain: ChainC value
< 'shadowProperty' in chain: true
< delete chain.shadowProperty: true
< 'shadowProperty' in chain: true
< chain.shadowProperty: ChainB value
< delete chain.shadowProperty: true
< 'shadowProperty' in chain: true
< chain.shadowProperty: ChainB value
< chain: ChainB value
< chain.shadowProperty: ChainB value
< chain.chainBProperty: undefined
< chain.chainAProperty: ChainB value
< chain.rootProperty: Root value
< chain: ChainB value
< delete chain.shadowProperty: true
< chain.shadowProperty: ChainA value
< delete chain.shadowProperty: true
< chain.shadowProperty: ChainA value
< chain: ChainA value
< 'shadowProperty' in chain: true
< delete ChainB.prototype.shadowProperty: true
< 'shadowProperty' in chain: false
< chain.shadowProperty: undefined
< chain: undefined
< { chainAProperty: ChainB value, chainBProperty: ChainC value, constructor: 12345, rootProperty: Root value, shadowProperty: ChainC value, toString: undefined }
< true
< { chainAProperty: ChainB value, chainBProperty: ChainC value, constructor: 12345, rootProperty: Root value, shadowProperty: ChainC value, toString: undefined }
< true
< { chainAProperty: ChainB value, chainBProperty: ChainC value, constructor: 12345, rootProperty: Root value, toString: undefined }
-

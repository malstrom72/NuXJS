> out: { break out; switch (x) { case 0: print("HEJ"); break; } }
-
> out: { break out; for (a[f(1)] in {}) { } }
-
> out: { break out; for (i = 0; i < 100; ++i) { } }
-
> function f(a, b) {
> 	switch (a) {
> 		case 0: {
> 			switch (b) {
> 				case 0: return;
> 				default: {
> 					return
> 				}
> 			}
> 			break;
> 		}
> 		default: return;
> 	}	
> }
-

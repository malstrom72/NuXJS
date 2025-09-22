// Reproduces the assertion in String::toUTF8String by calling a string
// containing a lone high surrogate as a function. The runtime tries to
// stringify the offending value while building the TypeError message,
// hits the surrogate assumption and aborts.
> ("\ud9dd")()
-

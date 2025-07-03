mandelbrot = function() {
	var I, R, s, b, n, out = "";
	eval('for(var i=-1, s=""; i<1; i+=0.06, out += s + "\\n", s="") for (var r=-2;(I=i,(R=r)<1);r+=0.03,s+=String.fromCharCode(n+31)) for(n=0;(b=I*I,26>n++&&R*R+b<4);I=2*R*I+i,R=R*R-b+r);');
	return out;
}
for (var i = 0; i < 100; ++i) s = mandelbrot();
print(s)

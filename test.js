f=function() {
a=3
g();
}
g=function() {
b=5
a=null;
h();
}
h=function() {
a.x=null;
}
f()
print(a);


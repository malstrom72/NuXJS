> glob5 = 'abcd';
> print(delete glob5);
> print(typeof glob5);
> glob5 = 'efgh';
< true
< undefined
-
> var glob4;
> print(delete glob4);
> print(typeof glob4);
< false
< undefined
-
> var glob1 = 'glob';
> print('glob1' in this);
< true
-
> if (false) { var glob2 = 'glob'; }
> print('glob2' in this);
< true
-
> this.glob1 = 'eh';
> print(delete glob1);
> print(typeof glob1);
< false
< string
-
> this.glob3 = 'eh';
> print(delete glob3);
> print(typeof glob3);
< true
< undefined
-

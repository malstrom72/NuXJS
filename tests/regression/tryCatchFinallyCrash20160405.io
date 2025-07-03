> var c2=0,fin2=0;
> do{
>   try{
>     throw "ex1";
>   }
>   catch(er1){
>     c2+=1;
>     break;
>   }
>   finally{
>     fin2=1;
>     continue;
>   }
>   c2+=2;
>   fin2=-1;
> }
> while(c2<2);
> print(fin2);
> print(c2);
< 1
< 2
-

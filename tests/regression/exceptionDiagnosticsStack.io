> __printExceptionMetadata__ = true;
> function levelTwo() { throw new Error("boom"); }
> function levelOne() { levelTwo(); }
> levelOne();
< !!!! Error: boom
< !!!! location: <anonymous>:1:25
< !!!! stack: Error: boom
<     at levelTwo (<anonymous>:1:25)
<     at levelOne (<anonymous>:1:12)
<     at <anonymous>:4:11
-

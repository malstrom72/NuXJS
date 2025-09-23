> __printExceptionMetadata__ = true;
> function levelTwo() { throw new Error("boom"); }
> function levelOne() { levelTwo(); }
> levelOne();
< !!!! Error: boom
< !!!! location: <anonymous>
< !!!! stack: Error: boom
-

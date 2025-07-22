a) Function has fast native virtual calls (as today):

    1) problem with pointing right into dynamic sized vstack
    2) difficult to make callbacks from C++ work as expected (natives will execute immediately in called order, scripts will execute on next processor run in reverse called order)

b) Function is always script, thunk to native call:

    1) more expensive to make native calls
    2) slightly more complicated to create simple native function objects (needs a thunk)

c) Native calls get their own scope containing the arguments, scopes can have different ways of executing their code

    1) very similar to b) (so also expensive to make native calls) but doesn't require thunking vm code

d) Function is always script, "inlined" native calls (% syntax):

    1) inlined native calls also must not have their arguments pointed to on the vstack (if we don't cominbe with f) or g) )
    2) slightly more complicated to create simple native function objects (needs a thunk)
    3) more compiler code and from tests we only see performance boost on very intensive native callback tight loops

e) Native calls have their variables copied on the C++ stack

    1) slightly more expensive than current solution, doesn't solve the callback order problem (of a) )
    2) need to store vsp in frame

f) value-stack never grows, each scope have their own fixed-size value stack instead

    1) doesn't solve the callback order problem (of a) )
    2) wastes more memory as value-stacks elements aren't reused as much
    3) on the good side we don't need the complicated stack-growing logic and any vstack-indexes can all be direct pointers
    4) GlobalScope needs a vstack. FunctionScope could use its already existing "indexed" array for the vstack.

g) go back to fixed size value-stack

    1) doesn't solve the callback order problem (of a) )
    2) imposes a new limitation to the vm


    fixes crash bug     fixes callback order        quick native call   zero memory native call
    ---------------     --------------------        -----------------   -----------------------
a)  no                  no                          yes                 yes
b)  yes                 yes                         no                  no
c)  yes                 yes                         no                  no
d)  no                  yes                         yes                 yes
e)  yes                 no                          yes                 no
f)  yes                 no                          yes                 yes
g)  yes                 no                          yes                 yes





todo:

                Scope(Heap& heap, Scope* parentScope, const CodeDefinition* codeDefinition)
                        : super(heap), vstackPointer(parentScope->vstackPointer)
                        , indexedPointer(parentScope->indexedPointer), parentScope(parentScope)
                        , codeDefinition(codeDefinition) { };

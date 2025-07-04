# Memory Management

 A _Heap_ in _NuXJScript_ is a shallow class that implements a simple "mark and sweep" ("stop-the-world") garbage
collector. It also maintains "memory pools" for improved performance but uses the standard C++ heap for allocating
larger objects and for expanding the pools. An application may spawn and use several Javascript engines simultaneously
and **normally each engine (or _Runtime_) has its own _Heap_**. _Heap_ can be sub-classed for custom allocation methods.

 Virtually every object that is dynamically allocated in _NuXJScript_ inherits from _GCItem_. A _GCItem_ normally 
belongs to one of two lists inside a _Heap_: **the list of root items or the list of managed items**. You place them
there by passing the list to the _GCItem_ constructor (e.g. `GCItem(myHeap.managed())`) or by calling
`GCList::claim(...)`. (You obtain the list of root items with `Heap::roots()` and the list of managed items with
`Heap::managed()`.)

 Managed items are subject to garbage collection (via the `Heap::gc()` routine). When a managed item is not reachable
directly or indirectly from any of the root items it will be deleted from the heap. Thus, **managed items must be
dynamically allocated**. You need to allocate such items on a _Heap_ using the overloaded `new` operator like this:
`new(myHeap) MyItem(myHeap.managed())`.

 **Root items do not need to be allocated on a _Heap_.** They can be constructed and destructed in any way you wish.
E.g. it is ok to have root items on the C++ stack. Obviously it is important to assure that other items do not reference
root items when they go out of scope / are deallocated. You can move an item from one list to the other by calling
`GCList::claim(...)`. E.g. to turn a root item that was allocated with `new(heap)` into a managed item, write:
`myHeap.managed().claim(myFormerRootItem)`.

 **In rare circumstances it is ok to not place a _GCItem_ on a heap at all**. The item will in this case never be a
candidate for garbage collection, but it will also never mark any of its references. In other words, this item must be a
terminal leaf that has no further unique references. (One use case of this is for global constant Strings, e.g. `const
String MAGNUS_STRING("Magnus")`.)

 When a _GCItem_ is destructed (regardless if it is from automatic garbage collection or not) it is removed from the
list it belongs to. This enables heaps to contain a mixture of automatically garbage collected and manually memory
managed items. It also means that **it is always ok to manually delete an item** (including managed items) once you are
done with it **provided that you can guarantee that it can no longer be reached** of course. This might ease the burden
on the garbage collector and speed up allocation.

 **Every sub-class of _GCItem_ is responsible for overriding `gcMarkReferences(Heap& heap)` to mark all _GCItems_ it
references** (via the overloaded `gcMark(heap, ...)` functions). Remember to also call the super-class's
`gcMarkReferences` in the overriden method. **If `gcMarkReferences` is implemented incorrectly, items that are still in
use may get garbage collected** (= deadly sin).

Garbage collection is either invoked manually with `Heap::gc()` or automatically via `Runtime::autoGC()`. **Automatic
garbage collection occurs when the number of bytes on a heap reaches a threshold that is two times the heap's size after
the last garbage collection.** It is also possible to impose a hard limit on the heap's size.

## Creating Strings

Strings store UTF‑16 data. When a new string should live on a heap, allocate it
with `new(heap) String(heap.managed(), text)`. Temporary root strings can be
constructed on the stack using `String(heap.roots(), ...)`. To concatenate two
existing strings and return a managed string pointer use
`String::concatenate(heap, left, right)`.

# Source Code Conventions

- `const String&` arguments never saves pointer to the argument, temporary (unmanaged) instances of `String()` are
  allowed.
- `getXXX()` implies that there will be an assertion failure if the value is not of type XXX.
- `asXXX()` implies that 0 will be returned if the value is not of type XXX.
- `toXXX()` implies that the value will be converted to type XXX if necessary and an exception might be thrown if it is
  not possible.

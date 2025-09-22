# NuXJS Benchmark Sampling Profile

## Benchmark setup
- Built `output/NuXJS` in release mode with debug information and frame pointers (`CPP_OPTIONS="-g -fno-omit-frame-pointer"`).
- Sampling command: `/usr/lib/linux-tools-6.8.0-83/perf record -F 99 --call-graph fp --all-user --output perf.data -- ./externals/PikaCmd/PikaCmd tools/benchmark.pika - --runs 1`.
- The run produced 9 727 samples across the full benchmark suite (median of all tests 2.55 s with single execution per case).

## Top self-time functions

Self % | Function                                                                                  
------ | ------------------------------------------------------------------------------------------
26.05  | NuXJS::Processor::innerRun()                                                              
7.64   | NuXJS::Processor::pop2push1(NuXJS::Value const&)                                          
5.26   | NuXJS::Processor::push(NuXJS::Value const&)                                               
4.19   | NuXJS::Table::find(NuXJS::String const*, unsigned int)                                    
3.59   | 0x00000000000ac51a                                                                        
3.55   | NuXJS::GCList::deleteAll()                                                                
2.89   | NuXJS::Heap::allocate(unsigned long)                                                      
2.19   | NuXJS::Heap::gc()                                                                         
1.86   | NuXJS::Table::lookup(NuXJS::String const*)                                                
1.86   | NuXJS::Value::toDouble() const                                                            
1.78   | NuXJS::gcMark(NuXJS::Heap&, NuXJS::GCItem const*)                                         
1.76   | NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const 
1.67   | NuXJS::JSObject::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const
1.52   | NuXJS::Object::getProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const     
1.05   | NuXJS::JSArray::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const 

## VM opcode sample distribution

Self % | Line | Opcode(s)                                              
------ | ---- | -------------------------------------------------------
1.44   | 2491 | READ_LOCAL_OP                                          
1.41   | 2493 | WRITE_LOCAL_POP_OP                                     
0.68   | 2495 | READ_NAMED_OP                                          
0.66   | 2492 | WRITE_LOCAL_OP                                         
0.50   | 2612 | JF_OP                                                  
0.39   | 2690 | DELETE_OP                                              
0.36   | 2551 | OBJ_TO_PRIMITIVE_OP, OBJ_TO_NUMBER_OP, OBJ_TO_STRING_OP
0.31   | 2579 | ADD_OP                                                 
0.28   | 2577 | INC_OP                                                 
0.27   | 2578 | DEC_OP                                                 
0.25   | 2515 | GET_PROPERTY_OP                                        
0.23   | 2490 | CONST_OP                                               
0.16   | 2614 | JF_OR_POP_OP                                           
0.16   | 2581 | MUL_OP                                                 
0.15   | 2580 | SUB_OP                                                 
0.14   | 2680 | PUSH_ELEMENTS_OP                                       
0.14   | 2600 | GT_OP                                                  
0.10   | 2507 | CHECK_OBJECT_COERCIBLE_OP                              
0.10   | 2542 | CHECK_RESOLVE_PROPERTY_OP                              
0.08   | 2617 | PUSH_BACK_OP                                           

## Notes
- Percentages above are based on sampled CPU time and indicate where execution spent time within the NuXJS binary during the one-pass benchmark suite.
- Opcode entries represent groups where multiple opcodes share the same handler (e.g., object-to-primitive conversions). Lower-percentage opcodes (<0.01 %) are omitted for brevity but remain in `opcode_samples.tsv`.
- Address-only entries (e.g., `0x00000000000ac51a`) correspond to unresolved libc allocation helpers that back `NuXJS::Heap::allocate`.

## O3 + symbols rerun

### Benchmark setup
- Rebuilt `output/NuXJS` with maximum optimization and symbols (`CPP_OPTIONS="-O3 -g -fno-omit-frame-pointer"`).
- Sampling command: `/usr/lib/linux-tools-6.8.0-83/perf record -F 99 --call-graph fp --all-user --output perf-o3.data -- ./externals/PikaCmd/PikaCmd tools/benchmark.pika - --runs 1`.
- The run produced 7 375 samples (median of all benchmark cases 1.68 s with single execution per case).

### Top self-time functions (O3 build)

Self % | Function
------ | ------------------------------------------------------------------------------------------
37.22  | NuXJS::Processor::innerRun()
7.40   | NuXJS::Table::find(NuXJS::String const*, unsigned int)
5.44   | NuXJS::Heap::gc()
4.53   | 0x00000000000ac51a
2.60   | operator new(unsigned long, NuXJS::Heap*)
2.47   | NuXJS::FunctionScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const
2.39   | NuXJS::JSObject::getOwnProperty(NuXJS::Runtime&, NuXJS::Value const&, NuXJS::Value*) const
2.06   | NuXJS::Table::gcMarkReferences(NuXJS::Heap&) const
1.71   | NuXJS::Table::lookup(NuXJS::String const*)
1.71   | NuXJS::Value::toDouble() const
1.57   | NuXJS::Runtime::GlobalScope::readVar(NuXJS::Runtime&, NuXJS::String const*, NuXJS::Value*) const
1.15   | NuXJS::Value::add(NuXJS::Heap&, NuXJS::Value const&) const
1.15   | operator delete(void*, NuXJS::Heap*)
0.92   | NuXJS::Table::rebuild(unsigned int)
0.88   | NuXJS::Heap::~Heap()
0.88   | NuXJS::Value::isLessThan(NuXJS::Value const&) const

### VM opcode sample distribution (O3 build)

Self % | Line | Opcode(s)
------ | ---- | -------------------------------------------------------
0.71   | 2497 | READ_NAMED_OP
0.69   | 2492 | WRITE_LOCAL_OP
0.66   | 2577 | INC_OP
0.62   | 2554 | OBJ_TO_PRIMITIVE_OP, OBJ_TO_NUMBER_OP, OBJ_TO_STRING_OP
0.58   | 2491 | READ_LOCAL_OP
0.47   | 2581 | MUL_OP
0.43   | 2612 | JF_OP
0.38   | 2579 | ADD_OP
0.31   | 2598 | LT_OP
0.27   | 2516 | GET_PROPERTY_OP
0.23   | 2580 | SUB_OP
0.20   | 2493 | WRITE_LOCAL_POP_OP
0.19   | 2614 | JF_OR_POP_OP
0.16   | 2508 | CHECK_OBJECT_COERCIBLE_OP
0.15   | 2586 | AND_OP
0.12   | 2617 | PUSH_BACK_OP
0.09   | 2624 | CALL_OP
0.08   | 2649 | CALL_EVAL_OP
0.08   | 2742 | TYPEOF_NAMED_OP

### Notes
- `NuXJS::Processor::pop2push1` no longer appears in the top sample list because the `-O3` build inlines it into the arithmetic opcodes.
- Control-flow opcodes (`JF_OP`, `JF_OR_POP_OP`) grew relative to the size-optimized build because arithmetic helpers became cheaper after inlining.
- Object property access (`READ_NAMED_OP`, `GET_PROPERTY_OP`, and the object-to-primitive conversion group) continue to dominate the interpreter’s dynamic instruction mix.

### Optimization opportunities highlighted by the O3 profile

1. **Property access caches.** `NuXJS::Table::find`, `NuXJS::FunctionScope::readVar`, and `NuXJS::JSObject::getOwnProperty` collectively absorb more than 12 % of the sampled time, indicating that hash probes and scope walks remain the costliest non-dispatch work. Adding monomorphic property caches or inline-array lookups for frequently accessed identifiers would let the interpreter bypass repeated `Table::find` / `lookup` calls on hot paths.
2. **Faster allocation paths.** `NuXJS::Heap::gc`, the heap-specific `operator new`/`delete`, and the unresolved `malloc` helper together contribute roughly 13 % of the samples. Introducing a bump-pointer arena for short-lived temporaries (with bulk freeing when scopes exit) would reduce allocator traffic and delay full GC cycles triggered by transient objects.
3. **Arithmetic specialization.** Although arithmetic helpers inline under `-O3`, `Value::add`, `Value::isLessThan`, and `Value::toDouble` still consume ~3 % of the profile. Providing number-specialized fast paths—e.g., caching tagged-double operations or hoisting type checks out of loops—would shrink the remaining conversion overhead in math-heavy kernels.
4. **Dispatch reduction.** `NuXJS::Processor::innerRun` accounts for 37 % of samples even after inlining, reflecting both opcode work and the per-iteration dispatch cost. Forming superinstructions (e.g., `READ_LOCAL`+`ADD`+`WRITE_LOCAL_POP`) or a threaded-code dispatcher could cut down on `switch` branch mispredictions and keep the CPU in the opcode bodies longer.

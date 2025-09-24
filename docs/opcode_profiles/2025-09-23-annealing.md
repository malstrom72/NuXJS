# Opcode Profile Summary

Total opcode executions: 120,869,755
Total recorded transitions: 118,511,118

## Hottest opcodes

| Rank | Opcode | Count | Share |
| --- | --- | ---: | ---: |
| 1 | READ_LOCAL_TO_NUMBER | 18,794,167 | 15.55% |
| 2 | CONST | 14,436,184 | 11.94% |
| 3 | READ_NAMED | 12,510,730 | 10.35% |
| 4 | USHR | 10,076,016 | 8.34% |
| 5 | WRITE_LOCAL_POP | 9,718,471 | 8.04% |
| 6 | OBJ_TO_NUMBER | 8,793,085 | 7.27% |
| 7 | POP | 7,792,798 | 6.45% |
| 8 | OR | 6,000,856 | 4.96% |
| 9 | XOR | 5,433,888 | 4.50% |
| 10 | WRITE_NAMED_POP | 3,717,149 | 3.08% |
| 11 | READ_LOCAL | 3,361,513 | 2.78% |
| 12 | TYPEOF_NAMED | 2,716,947 | 2.25% |
| 13 | RETURN | 2,358,637 | 1.95% |
| 14 | CALL | 1,358,758 | 1.12% |
| 15 | VOID | 1,358,491 | 1.12% |
| 16 | SHL | 1,358,482 | 1.12% |
| 17 | AND | 1,358,472 | 1.12% |
| 18 | GT | 1,358,472 | 1.12% |
| 19 | JT | 1,358,472 | 1.12% |
| 20 | CHECK_OBJECT_COERCIBLE | 1,001,469 | 0.83% |

## Hottest transitions

| Rank | From | To | Count | P(Next) |
| --- | --- | --- | ---: | ---: |
| 1 | CONST | USHR | 10,076,016 | 0.6980 |
| 2 | READ_NAMED | OBJ_TO_NUMBER | 8,792,832 | 0.7028 |
| 3 | READ_LOCAL_TO_NUMBER | CONST | 7,359,236 | 0.3916 |
| 4 | READ_LOCAL_TO_NUMBER | READ_LOCAL_TO_NUMBER | 7,359,142 | 0.3916 |
| 5 | WRITE_LOCAL_POP | READ_LOCAL_TO_NUMBER | 7,359,092 | 0.7572 |
| 6 | OR | WRITE_LOCAL_POP | 6,000,600 | 1.0000 |
| 7 | USHR | OR | 6,000,600 | 0.5955 |
| 8 | OBJ_TO_NUMBER | CONST | 5,075,620 | 0.5772 |
| 9 | POP | READ_NAMED | 5,075,542 | 0.6513 |
| 10 | OBJ_TO_NUMBER | READ_NAMED | 2,717,109 | 0.3090 |
| 11 | TYPEOF_NAMED | POP | 2,716,947 | 1.0000 |
| 12 | XOR | READ_LOCAL_TO_NUMBER | 2,716,944 | 0.5000 |
| 13 | USHR | XOR | 2,716,944 | 0.2696 |
| 14 | RETURN | POP | 2,358,523 | 1.0000 |
| 15 | POP | READ_LOCAL | 1,358,555 | 0.1743 |
| 16 | READ_LOCAL | POP | 1,358,498 | 0.4041 |
| 17 | VOID | RETURN | 1,358,485 | 1.0000 |
| 18 | POP | VOID | 1,358,485 | 0.1743 |
| 19 | CONST | SHL | 1,358,482 | 0.0941 |
| 20 | READ_NAMED | WRITE_NAMED_POP | 1,358,475 | 0.1086 |

## Top successors per opcode

### READ_LOCAL_TO_NUMBER (18,794,167 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | CONST | 7,359,236 | 0.3916 |
| 2 | READ_LOCAL_TO_NUMBER | 7,359,142 | 0.3916 |
| 3 | XOR | 1,358,472 | 0.0723 |
| 4 | AND | 1,358,472 | 0.0723 |
| 5 | GT | 1,358,472 | 0.0723 |

### CONST (14,436,184 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | USHR | 10,076,016 | 0.6980 |
| 2 | SHL | 1,358,482 | 0.0941 |
| 3 | LT | 1,000,201 | 0.0693 |
| 4 | CONST | 1,000,131 | 0.0693 |
| 5 | CALL_METHOD | 1,000,108 | 0.0693 |

### READ_NAMED (12,510,730 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | OBJ_TO_NUMBER | 8,792,832 | 0.7028 |
| 2 | WRITE_NAMED_POP | 1,358,475 | 0.1086 |
| 3 | CALL | 1,358,472 | 0.1086 |
| 4 | CHECK_OBJECT_COERCIBLE | 1,000,807 | 0.0800 |
| 5 | READ_NAMED | 101 | 0.0000 |

### USHR (10,076,016 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | OR | 6,000,600 | 0.5955 |
| 2 | XOR | 2,716,944 | 0.2696 |
| 3 | READ_LOCAL_TO_NUMBER | 1,358,472 | 0.1348 |

### WRITE_LOCAL_POP (9,718,471 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | READ_LOCAL_TO_NUMBER | 7,359,092 | 0.7572 |
| 2 | TYPEOF_NAMED | 1,358,472 | 0.1398 |
| 3 | READ_NAMED | 1,000,380 | 0.1029 |
| 4 | READ_LOCAL | 256 | 0.0000 |
| 5 | JMP | 210 | 0.0000 |

### OBJ_TO_NUMBER (8,793,085 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | CONST | 5,075,620 | 0.5772 |
| 2 | READ_NAMED | 2,717,109 | 0.3090 |
| 3 | INC | 1,000,100 | 0.1137 |
| 4 | OR | 167 | 0.0000 |
| 5 | READ_LOCAL_TO_NUMBER | 89 | 0.0000 |

### POP (7,792,798 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | READ_NAMED | 5,075,542 | 0.6513 |
| 2 | READ_LOCAL | 1,358,555 | 0.1743 |
| 3 | VOID | 1,358,485 | 0.1743 |
| 4 | JMP | 196 | 0.0000 |
| 5 | POP | 7 | 0.0000 |

### OR (6,000,856 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | WRITE_LOCAL_POP | 6,000,600 | 1.0000 |
| 2 | SET_PROPERTY_POP | 250 | 0.0000 |
| 3 | CONST | 4 | 0.0000 |
| 4 | READ_NAMED | 2 | 0.0000 |

### XOR (5,433,888 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | READ_LOCAL_TO_NUMBER | 2,716,944 | 0.5000 |
| 2 | WRITE_LOCAL_POP | 1,358,472 | 0.2500 |
| 3 | WRITE_NAMED_POP | 1,358,472 | 0.2500 |

### WRITE_NAMED_POP (3,717,149 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | TYPEOF_NAMED | 1,358,474 | 0.3655 |
| 2 | POP | 1,358,473 | 0.3655 |
| 3 | JMP | 1,000,100 | 0.2691 |
| 4 | READ_NAMED | 101 | 0.0000 |
| 5 | CONST | 1 | 0.0000 |

### READ_LOCAL (3,361,513 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | POP | 1,358,498 | 0.4041 |
| 2 | PUSH_BACK | 1,000,142 | 0.2975 |
| 3 | WRITE_LOCAL_POP | 1,000,103 | 0.2975 |
| 4 | READ_LOCAL | 788 | 0.0002 |
| 5 | CHECK_OBJECT_COERCIBLE | 638 | 0.0002 |

### TYPEOF_NAMED (2,716,947 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | POP | 2,716,947 | 1.0000 |

### RETURN (2,358,634 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | POP | 2,358,523 | 1.0000 |
| 2 | CALL | 100 | 0.0000 |
| 3 | WRITE_LOCAL | 7 | 0.0000 |
| 4 | WRITE_LOCAL_POP | 2 | 0.0000 |
| 5 | CONST | 1 | 0.0000 |

### CALL (226 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | ADD_PROPERTY | 123 | 0.5442 |
| 2 | POP | 100 | 0.4425 |
| 3 | READ_LOCAL | 1 | 0.0044 |
| 4 | SET_PROPERTY | 1 | 0.0044 |
| 5 | PUSH_BACK | 1 | 0.0044 |

### VOID (1,358,491 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | RETURN | 1,358,485 | 1.0000 |
| 2 | DECLARE | 3 | 0.0000 |
| 3 | CALL_METHOD | 2 | 0.0000 |
| 4 | X_EQ | 1 | 0.0000 |

### SHL (1,358,482 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | XOR | 1,358,472 | 1.0000 |
| 2 | WRITE_LOCAL | 10 | 0.0000 |

### AND (1,358,472 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | WRITE_LOCAL_POP | 1,358,472 | 1.0000 |

### GT (1,358,472 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | JT | 1,358,472 | 1.0000 |

### JT (1,358,472 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | READ_LOCAL | 1,000,100 | 0.7362 |
| 2 | READ_NAMED | 358,372 | 0.2638 |

### CHECK_OBJECT_COERCIBLE (1,001,469 transitions)
| Rank | Successor | Count | P(Next) |
| --- | --- | ---: | ---: |
| 1 | CONST | 1,000,758 | 0.9993 |
| 2 | READ_LOCAL | 548 | 0.0005 |
| 3 | READ_NAMED | 158 | 0.0002 |
| 4 | READ_LOCAL_TO_PRIMITIVE | 5 | 0.0000 |

## Transition probability matrix (top 10 opcodes)

| From/To | READ_LOCAL_TO_NUMBER | CONST | READ_NAMED | USHR | WRITE_LOCAL_POP | OBJ_TO_NUMBER | POP | OR | XOR | WRITE_NAMED_POP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| READ_LOCAL_TO_NUMBER | 0.3916 | 0.3916 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0723 | 0.0000 |
| CONST | 0.0000 | 0.0693 | 0.0000 | 0.6980 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| READ_NAMED | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.7028 | 0.0000 | 0.0000 | 0.0000 | 0.1086 |
| USHR | 0.1348 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.5955 | 0.2696 | 0.0000 |
| WRITE_LOCAL_POP | 0.7572 | 0.0000 | 0.1029 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| OBJ_TO_NUMBER | 0.0000 | 0.5772 | 0.3090 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| POP | 0.0000 | 0.0000 | 0.6513 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| OR | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 1.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| XOR | 0.5000 | 0.0000 | 0.0000 | 0.0000 | 0.2500 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.2500 |
| WRITE_NAMED_POP | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.3655 | 0.0000 | 0.0000 | 0.0000 |

## Greedy clustering candidate layout

Covered transitions inside clusters: 118,511,118 (100.00%)
Covered transitions between sequential opcodes in the flattened order: 49,739,729 (41.97%)

### Cluster 1 (58 opcodes)

- Entry executions: 120,869,755
- Internal transition weight: 118,511,118 (100.00%)

`SET_PROPERTY`, `X_EQ`, `NEW_RESULT`, `MINUS`, `JT_OR_POP`, `PUSH_ELEMENTS_OP`, `PRE_EQ`, `NEW_ARRAY`, `EQ`, `DECLARE`, `READ_LOCAL_TO_PRIMITIVE`, `ADD`, `THIS`, `SUB`, `WRITE_LOCAL`, `NEW_OBJECT`, `GET_ENUMERATOR`, `GEQ`, `LEQ`, `GEN_FUNC`, `SET_PROPERTY_POP`, `REPUSH_2`, `REPUSH`, `NEXT_PROPERTY`, `INC`, `PUSH_BACK`, `LT`, `JF`, `CHECK_OBJECT_COERCIBLE`, `AND`, `WRITE_NAMED_POP`, `READ_LOCAL`, `RETURN`, `XOR`, `TYPEOF_NAMED`, `POP`, `READ_NAMED`, `OBJ_TO_NUMBER`, `WRITE_LOCAL_POP`, `READ_LOCAL_TO_NUMBER`, `CONST`, `USHR`, `OR`, `VOID`, `SHL`, `CALL`, `GT`, `JT`, `CALL_METHOD`, `JMP`, `OBJ_TO_STRING`, `GET_PROPERTY`, `CHECK_RESOLVE_PROPERTY`, `X_NEQ`, `ADD_PROPERTY`, `JF_OR_POP`, `DEC`, `NEW`

### Cluster 2 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`CALL_EVAL`

### Cluster 3 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`CATCH_SCOPE`

### Cluster 4 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`DELETE`

### Cluster 5 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`DELETE_NAMED`

### Cluster 6 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`DIV`

### Cluster 7 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`IN`

### Cluster 8 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`INSTANCE_OF`

### Cluster 9 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`INV`

### Cluster 10 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`JSR`

### Cluster 11 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`MOD`

### Cluster 12 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`MUL`

### Cluster 13 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`NEQ`

### Cluster 14 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`NEW_REG_EXP`

### Cluster 15 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`NOT`

### Cluster 16 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`OBJ_TO_PRIMITIVE`

### Cluster 17 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`PLUS`

### Cluster 18 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`POP_FRAME`

### Cluster 19 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`POST_SHUFFLE`

### Cluster 20 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`READ_LOCAL_TO_STRING`

### Cluster 21 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`SHR`

### Cluster 22 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`SWAP`

### Cluster 23 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`THROW`

### Cluster 24 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`TRIED`

### Cluster 25 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`TRY`

### Cluster 26 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`TYPEOF`

### Cluster 27 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`WITH_SCOPE`

### Cluster 28 (1 opcodes)

- Entry executions: 0
- Internal transition weight: 0 (0.00%)

`WRITE_NAMED`

### Flattened opcode order

| Position | Opcode |
| ---: | --- |
| 1 | SET_PROPERTY |
| 2 | X_EQ |
| 3 | NEW_RESULT |
| 4 | MINUS |
| 5 | JT_OR_POP |
| 6 | PUSH_ELEMENTS_OP |
| 7 | PRE_EQ |
| 8 | NEW_ARRAY |
| 9 | EQ |
| 10 | DECLARE |
| 11 | READ_LOCAL_TO_PRIMITIVE |
| 12 | ADD |
| 13 | THIS |
| 14 | SUB |
| 15 | WRITE_LOCAL |
| 16 | NEW_OBJECT |
| 17 | GET_ENUMERATOR |
| 18 | GEQ |
| 19 | LEQ |
| 20 | GEN_FUNC |
| 21 | SET_PROPERTY_POP |
| 22 | REPUSH_2 |
| 23 | REPUSH |
| 24 | NEXT_PROPERTY |
| 25 | INC |
| 26 | PUSH_BACK |
| 27 | LT |
| 28 | JF |
| 29 | CHECK_OBJECT_COERCIBLE |
| 30 | AND |
| 31 | WRITE_NAMED_POP |
| 32 | READ_LOCAL |
| 33 | RETURN |
| 34 | XOR |
| 35 | TYPEOF_NAMED |
| 36 | POP |
| 37 | READ_NAMED |
| 38 | OBJ_TO_NUMBER |
| 39 | WRITE_LOCAL_POP |
| 40 | READ_LOCAL_TO_NUMBER |
| 41 | CONST |
| 42 | USHR |
| 43 | OR |
| 44 | VOID |
| 45 | SHL |
| 46 | CALL |
| 47 | GT |
| 48 | JT |
| 49 | CALL_METHOD |
| 50 | JMP |
| 51 | OBJ_TO_STRING |
| 52 | GET_PROPERTY |
| 53 | CHECK_RESOLVE_PROPERTY |
| 54 | X_NEQ |
| 55 | ADD_PROPERTY |
| 56 | JF_OR_POP |
| 57 | DEC |
| 58 | NEW |
| 59 | CALL_EVAL |
| 60 | CATCH_SCOPE |
| 61 | DELETE |
| 62 | DELETE_NAMED |
| 63 | DIV |
| 64 | IN |
| 65 | INSTANCE_OF |
| 66 | INV |
| 67 | JSR |
| 68 | MOD |
| 69 | MUL |
| 70 | NEQ |
| 71 | NEW_REG_EXP |
| 72 | NOT |
| 73 | OBJ_TO_PRIMITIVE |
| 74 | PLUS |
| 75 | POP_FRAME |
| 76 | POST_SHUFFLE |
| 77 | READ_LOCAL_TO_STRING |
| 78 | SHR |
| 79 | SWAP |
| 80 | THROW |
| 81 | TRIED |
| 82 | TRY |
| 83 | TYPEOF |
| 84 | WITH_SCOPE |
| 85 | WRITE_NAMED |

## Simulated annealing refinement

Iterations: 50,000
Accepted moves: 11,004 (22.01%)
Improving moves: 64 (0.58%)
Temperature schedule: 1.0000 → 0.0010

Sequential coverage (greedy seed): 49,739,729 (41.97%)
Sequential coverage (best annealed): 56,175,621 (47.40%)
Coverage improvement over greedy: 6,435,892 (5.43%)

### Annealed opcode order

| Position | Opcode |
| ---: | --- |
| 1 | DELETE |
| 2 | X_NEQ |
| 3 | JF_OR_POP |
| 4 | X_EQ |
| 5 | JT_OR_POP |
| 6 | GEQ |
| 7 | NEW |
| 8 | NEW_ARRAY |
| 9 | GET_ENUMERATOR |
| 10 | TRIED |
| 11 | MUL |
| 12 | OBJ_TO_PRIMITIVE |
| 13 | INC |
| 14 | MOD |
| 15 | INV |
| 16 | LEQ |
| 17 | WITH_SCOPE |
| 18 | SHR |
| 19 | PUSH_ELEMENTS_OP |
| 20 | DIV |
| 21 | AND |
| 22 | JMP |
| 23 | REPUSH |
| 24 | NEXT_PROPERTY |
| 25 | JSR |
| 26 | IN |
| 27 | LT |
| 28 | JF |
| 29 | GEN_FUNC |
| 30 | CALL |
| 31 | ADD_PROPERTY |
| 32 | SHL |
| 33 | XOR |
| 34 | WRITE_NAMED_POP |
| 35 | TYPEOF_NAMED |
| 36 | POP |
| 37 | READ_NAMED |
| 38 | OBJ_TO_NUMBER |
| 39 | WRITE_LOCAL_POP |
| 40 | READ_LOCAL_TO_NUMBER |
| 41 | CONST |
| 42 | USHR |
| 43 | OR |
| 44 | SET_PROPERTY_POP |
| 45 | PLUS |
| 46 | DELETE_NAMED |
| 47 | GT |
| 48 | JT |
| 49 | SET_PROPERTY |
| 50 | CALL_METHOD |
| 51 | OBJ_TO_STRING |
| 52 | GET_PROPERTY |
| 53 | NEW_OBJECT |
| 54 | POST_SHUFFLE |
| 55 | CATCH_SCOPE |
| 56 | SWAP |
| 57 | CALL_EVAL |
| 58 | POP_FRAME |
| 59 | TYPEOF |
| 60 | NOT |
| 61 | THIS |
| 62 | CHECK_OBJECT_COERCIBLE |
| 63 | READ_LOCAL |
| 64 | PUSH_BACK |
| 65 | NEQ |
| 66 | READ_LOCAL_TO_STRING |
| 67 | READ_LOCAL_TO_PRIMITIVE |
| 68 | ADD |
| 69 | PRE_EQ |
| 70 | EQ |
| 71 | TRY |
| 72 | DEC |
| 73 | WRITE_LOCAL |
| 74 | WRITE_NAMED |
| 75 | THROW |
| 76 | CHECK_RESOLVE_PROPERTY |
| 77 | REPUSH_2 |
| 78 | NEW_REG_EXP |
| 79 | MINUS |
| 80 | INSTANCE_OF |
| 81 | DECLARE |
| 82 | VOID |
| 83 | RETURN |
| 84 | NEW_RESULT |
| 85 | SUB |


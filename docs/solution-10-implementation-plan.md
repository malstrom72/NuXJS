# Solution 10 – Minimal Implementation Plan

Goal: keep the existing packed closure operands `(level << 16) | (varIndex & 0xFFFF)` while adding a single runtime guard that falls back to a name lookup whenever dynamic scope features (`eval`, `with`, `catch`) invalidate cached slots.

1. **Compiler**
	- Reuse the current packing helper and emit packed operands for every closure opcode.
	- Flag functions that executed dynamic scope features so the VM can detect them quickly (a single bit on the `Code` object is enough).

2. **Runtime**
	- When a closure opcode runs, read the packed operand into `level` and `varIndex` just like today.
	- If the enclosing function is flagged for dynamic scope usage, resolve the binding by walking the recorded ancestor chain and doing a slow name lookup.
	- Otherwise, keep the existing fast path that uses the cached slot pointer.

3. **Tooling & Tests**
	- Update the disassembler so it prints the packed operands directly; no side tables or diagnostics.
	- Add one regression test per slow-path trigger (`eval`, `with`, `catch`) that confirms the fallback still produces the correct binding.
	- Run `timeout 180 ./build.sh` before landing.

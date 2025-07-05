# Examples

This folder contains small programs showing how to embed the NuXJS engine. They build on Linux or Windows; the `.cmd` scripts mirror the `.sh` versions.

All examples can be compiled manually with:

```bash
./tools/BuildCpp.sh debug ./output/<example> examples/<example>.cpp src/NuXJScript.cpp src/stdlibJS.cpp
```

Instead of compiling them one by one, run `tools/runExamples.sh` (or `runExamples.cmd` on Windows) to build and execute every sample automatically. The script prints each program's output and reports failures.

The available examples are:

- **callback_example.cpp** – JavaScript calling back into C++.
- **object_creation_example.cpp** – Building objects and arrays from C++.
- **time_memory_limits_example.cpp** – Enforcing memory and execution time caps.
- **asynchronous_example.cpp** – Using a `Processor` to run in small time slices.
- **property_enumeration_example.cpp** – Iterating properties including the prototype chain.
- **error_handling_example.cpp** – Translating exceptions between languages.
- **custom_object_example.cpp** – Defining a native `Counter` object.
- **json_conversion_example.cpp** – Converting to and from JSON.

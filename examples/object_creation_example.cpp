#include <iostream>
#include "../src/NuXJScript.h"

using namespace NuXJS;

int main() {
	Heap heap;
	Runtime rt(heap);
	rt.setupStandardLibrary();

	// Create an object with nested array
	Var user = rt.newObjectVar();
	user["name"] = std::wstring(L"Alice");
	user["age"] = 30;

	Var hobbies = rt.newArrayVar();
	hobbies[0] = std::wstring(L"coding");
	hobbies[1] = std::wstring(L"music");
	user["hobbies"] = hobbies;

	// Expose object to JavaScript
	Var globals = rt.getGlobalsVar();
	globals["user"] = user;

	heap.gc(); // for testing purposes only

	// JavaScript function that modifies the object
	rt.run(
		"function addHobby(obj, hobby) {\n" \
		"    obj.hobbies.push(hobby);\n" \
		"    obj.age += 1;\n" \
		"    return obj;\n" \
		"}"
	);

	Var updated = globals["addHobby"](user, std::wstring(L"photography"));

	// Print the updated object via JSON.stringify
	Var stringify = globals["JSON"]["stringify"];
	heap.gc(); // for testing purposes only
	std::wstring text = stringify(updated).to<std::wstring>();
	std::wcout << L"Updated user: " << text << std::endl;

	heap.gc(); // for testing purposes only

	return 0;
}

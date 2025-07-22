for in null is ok:
		case GET_ENUMERATOR_OP: {
	#if (STRICTLY_ES3)
		if ((o = convertToObject(vsp[0], false)) == 0) { // FIX : so common!
			break;
		}
	#endif

prototype isn't enumerable:

	void ExtensibleFunction::createPrototypeObject(Engine& engine, Object* forObject, bool dontEnumPrototype) const {
		GCHeap& heap = engine.getHeap();
		ScriptObject* prototype = heap.govern(new (&heap.pool) ScriptObject(heap, &engine.objectPrototype));
		prototype->setOwnProperty(engine, Value(&CONSTRUCTOR_STRING), Value(const_cast<ExtensibleFunction*>(this)), DONT_ENUM_FLAG);
	#if (STRICTLY_ES3)
		forObject->setOwnProperty(engine, Value(&PROTOTYPE_STRING), Value(prototype), (dontEnumPrototype ? (DONT_ENUM_FLAG | DONT_DELETE_FLAG) : DONT_DELETE_FLAG));
	#else
		forObject->setOwnProperty(engine, Value(&PROTOTYPE_STRING), Value(prototype), DONT_ENUM_FLAG | DONT_DELETE_FLAG);
	#endif
	}

function name and length property differences:

	#if (STRICTLY_ES3)
		completeObject->setOwnProperty(engine, Value(&NAME_STRING), Value(codeDefinition->getName()), DONT_ENUM_FLAG);
		completeObject->setOwnProperty(engine, Value(&LENGTH_STRING), Value(codeDefinition->getArgumentsCount()), READ_ONLY_FLAG | DONT_ENUM_FLAG | DONT_DELETE_FLAG);
	#else
		completeObject->setOwnProperty(engine, Value(&NAME_STRING), Value(codeDefinition->getName()), READ_ONLY_FLAG | DONT_ENUM_FLAG);
		completeObject->setOwnProperty(engine, Value(&LENGTH_STRING), Value(codeDefinition->getArgumentsCount()), READ_ONLY_FLAG | DONT_ENUM_FLAG);
	#endif

arguments toString says Arguments and not Object:

	#if (STRICTLY_ES3)
	const String* Arguments::toString(GCHeap& heap) const {
		return heap.govern(new (&heap.pool) String(String(BRACKET_OBJECT_STRING, O_BJECT_STRING, &heap.pool), END_BRACKET_STRING, &heap.pool));
	}
	#endif

	toString: $unconstructable(function toString() {
		var s;
		return '[object ' + (((s = $getInternalProperty(this, 'class')) === 'Arguments') ? 'Object' : s) + ']'
	}),

argument elements are enumerable:

	Flags Arguments::getOwnProperty(Engine& engine, const Value& key, Value* v) const {
		const Value* p = findProperty(key);
		return (p == 0 ? super::getOwnProperty(engine, key, v) : ((void)(*v = *p)
	#if (STRICTLY_ES3)
				, (STANDARD_FLAGS | DONT_ENUM_FLAG | EXISTS_FLAG)));
	#else
				, (STANDARD_FLAGS | EXISTS_FLAG)));
	#endif
	}

	#if (STRICTLY_ES3)
		return (completeObject == 0 ? super::getPropertyEnumerator(engine) : completeObject->getPropertyEnumerator(engine));
	#else
		GCHeap& heap = engine.getHeap();
		StringListEnumerator* list = heap.govern(new (&heap.pool) StringListEnumerator(argumentsCount));
		for (UInt32 i = 0; i < argumentsCount; ++i) {
			if (!deletedArguments[i]) {
				list->add(String::fromInt(heap, i));
			}
		}
		return (completeObject == 0 ? static_cast<Enumerator*>(list)
				: heap.govern(new (&heap.pool) JoiningEnumerator(engine, list, completeObject)));
	#endif

# Legacy Exception Conversion Checklist

The following list mirrors `docs/LegacyExceptionInventory.json` and records which
legacy tests now run with modern diagnostics. Each entry is checked once its
`// CLI:` directive no longer requests `--legacy-exceptions` and the expectations
have been regenerated with the interactive rewrite helper. All entries are now
also validated by `tools/test.pika -e` so the inventory records both conversion
and execution without the compatibility flag.

- [x] tests/conforming/mandelbrot.io
- [x] tests/conforming/unicodeIdentifiers.io
- [x] tests/erroneous/assignmentNullBaseBracketLeftFirst.io
- [x] tests/erroneous/assignmentPropertyKeyCoercionBeforeBaseCheck.io
- [x] tests/erroneous/assignmentUndefinedBaseBracketLeftFirst.io
- [x] tests/erroneous/badForInStatements.io
- [x] tests/erroneous/badInOperation.io
- [x] tests/erroneous/badNumericLiterals.io
- [x] tests/erroneous/escapedLFNotAllowed.io
- [x] tests/erroneous/forInNullUndefined.io
- [x] tests/erroneous/illegalReturn.io
- [x] tests/erroneous/illegalUseOfKeywords.io
- [x] tests/erroneous/invalidCallApply.io
- [x] tests/erroneous/nonObjectPrototype.io
- [x] tests/erroneous/notAConstructor.io
- [x] tests/erroneous/notAFunction.io
- [x] tests/erroneous/oldBadTest.io
- [x] tests/erroneous/postfixIncrementNullBaseBracketLeftFirst.io
- [x] tests/erroneous/postfixIncrementUndefinedBaseBracketLeftFirst.io
- [x] tests/erroneous/prefixIncrementNullBaseBracketLeftFirst.io
- [x] tests/erroneous/prefixIncrementUndefinedBaseBracketLeftFirst.io
- [x] tests/erroneous/referenceError.io
- [x] tests/erroneous/switchSyntax.io
- [x] tests/erroneous/variousRunTimeErrors.io
- [x] tests/erroneous/withNullUndefined.io
- [x] tests/extremes/extremeProtoChain.io
- [x] tests/extremes/extremeRecursion.io
- [x] tests/extremes/extremeValueStack.io
- [x] tests/extremes/stackOverflow.io
- [x] tests/migrated/goodOldTests_deleteStatement.io
- [x] tests/regression/arrayPushLengthEdgeCases.io
- [x] tests/regression/badObjectLiteral20190507.io
- [x] tests/regression/badTokenParsing20191007.io
- [x] tests/regression/badZeroArgsNewCall.io
- [x] tests/regression/validArrayLengths.io
- [x] tests/stdlib/dates.io
- [x] tests/stdlib/regexps2.io
- [x] tests/unconforming/cantAssignObjectToArrayLength.io
- [x] tests/unsorted/20180412_231138.io
- [x] tests/unsorted/20180416_130544.io

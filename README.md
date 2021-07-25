Project: AvaTester

The point of AvaTester is to simplify unit testing:

1. Using the ava unit test system
2. No need to name individual tests, they're identified by line number
3. Duplicate line numbers won't cause an error
4. Strings are "normalized" before comparison:
	- leading and trailing whitespace is removed
	- runs of whitespace collapse to a single space char
	- empty lines are removed
	- you can override the `normalize()` method
5. You can define a `transformValue()` method

Examples (coffeescript syntax):
---------

import {AvaTester} from 'ava-tester'

tester = new AvaTester()

# --- tester.equal tests deep equality

tester.equal     7, 'abc', 'abc'
tester.equal     8, ['a','b'], [  'a',   'b',  ]
tester.truthy    9, 42
tester.falsy    10, null
tester.notequal 11, 'abc', 'def'
tester.fails    12, () -> throw new Error("bad")
tester.different 13, ['a'], ['a']

lItems = ['a', 'b']
tester.same 16, lItems, lItems

# --- Test creating custom tester -------------------------

class CapTester extends AvaTester

	transformValue: (input) ->
		return input.toUpperCase()

capTester = new CapTester()

capTester.equal 26, 'abc', 'ABC'
capTester.equal 27, 'ABC', 'ABC'
capTester.notequal 28, 'abc', 'abc'

# --- Test string normalization --------------------------

tester.equal 31, """
		line 1

		line     2

		line 3
		""", """
		line 1
		line 2
		line 3
		"""

Available Test Methods:

truthy
falsy
equal
notequal
same
different
fails

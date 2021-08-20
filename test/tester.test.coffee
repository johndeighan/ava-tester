# test.coffee

import {pass} from '@jdeighan/coffee-utils'
import {AvaTester} from '@jdeighan/ava-tester'

tester = new AvaTester

tester.equal     7, 'abc', 'abc'
tester.equal     8, ['a','b'], [  'a',   'b',  ]
tester.truthy    9, 42
tester.falsy    10, null
tester.notequal 11, 'abc', 'def'
tester.fails    12, () -> throw new Error("bad")
tester.different 13, ['a'], ['a']

lItems = ['a', 'b', 'c']
tester.same 16, lItems, lItems

# --- Duplicate line # should not be an error
tester.notequal 11, 'xxx', 'xxxx'

# ---------------------------------------------------------------------------
# --- Test creating custom tester

class CapTester extends AvaTester

	transformValue: (input) ->
		return input.toUpperCase()

capTester = new CapTester()

capTester.equal 26, 'abc', 'ABC'
capTester.equal 27, 'ABC', 'ABC'
capTester.notequal 28, 'abc', 'abc'

# ---------------------------------------------------------------------------
# --- Test string normalization

tester.equal 31, """
		line 1

		line     2

		line 3
		""", """
		line 1
		line 2
		line 3
		"""

# ---------------------------------------------------------------------------
# Test if negative line numbers generate error if env var FINALTEST is set

process.env.FINALTEST = 'yes'

tester.fails 56, () ->
	tester.equal -99, 2, 2

delete process.env.FINALTEST

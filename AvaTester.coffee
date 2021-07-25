# AvaTester.coffee

import {strict as assert} from 'assert'
import test from 'ava'

# --- Define some utilities
#        (later, get from coffee_utils.js)

`const undef = undefined`
defined = (x) -> x!=undef && x!=null
say = (x, label='') ->
	if label then console.log label
	if typeof x == 'object'
		console.dir x
	else
		console.log x
isString = (x) -> return typeof x == 'string' || x instanceof String
isFunction = (x) -> return typeof x == 'function'
isInteger = (x) -> return Number.isInteger(x)
stringToArray = (x) -> return if x==undef then [] else x.split(/\r?\n/)

# ---------------------------------------------------------------------------

export class AvaTester

	constructor: (whichTest='deepEqual') ->
		@hFound = {}
		@setWhichTest whichTest
		@justshow = false
		@testing = true

	# ........................................................................

	setWhichTest: (testName) ->
		@whichTest = testName
		return

	# ........................................................................

	transformValue: (input) ->
		return input

	# ........................................................................

	truthy: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'truthy'
		@test lineNum, input, expected, just_show

	# ........................................................................

	falsy: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'falsy'
		@test lineNum, input, expected, just_show

	# ........................................................................

	equal: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'deepEqual'
		@test lineNum, input, expected, just_show

	# ........................................................................

	notequal: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'notDeepEqual'
		@test lineNum, input, expected, just_show

	# ........................................................................

	same: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'is'
		@test lineNum, input, expected, just_show

	# ........................................................................

	different: (lineNum, input, expected, just_show=false) ->
		@setWhichTest 'not'
		@test lineNum, input, expected, just_show

	# ........................................................................

	fails: (lineNum, input, expected, just_show=false) ->
		if (expected != undef)
			error "AvaTester.fails(): expected value not allowed"
		@setWhichTest 'throws'
		@test lineNum, input, expected, just_show

	# ........................................................................

	normalize: (input) ->

		# --- Convert all whitespace to single space character
		#     Remove empty lines

		if isString(input)
			lLines = for line in stringToArray(input)
				line = line.trim()
				line.replace(/\s+/g, ' ')
			lLines = lLines.filter (line) -> line != ''
			return lLines.join('\n')
		else
			return input

	# ........................................................................

	test: (lineNum, input, expected, just_show=false) ->

		if not @testing
			return

		assert isInteger(lineNum), "AvaTester.test(): arg 1 must be an integer"
		@justshow = just_show

		lineNum = @getLineNum(lineNum)
		expected = @normalize(expected)

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichTest = @whichTest

		if (whichTest == 'throws')
			if @justshow
				say "line #{lineNum}"
				try
					got = @transformValue(input)
					say result, "GOT:"
				catch err
					say "GOT ERROR"
				say "EXPECTED ERROR"
		else
			got = @normalize(@transformValue(input))
			if lineNum < 0
				if @justshow
					say "line #{lineNum}"
					say got, "GOT:"
					say expected, "EXPECTED:"
				else
					test.only "line #{lineNum}", (t) ->
						t[whichTest] got, expected
				@testing = false
			else
				test "line #{lineNum}", (t) ->
					t[whichTest] got, expected
		return

	# ........................................................................

	getLineNum: (lineNum) ->

		# --- patch lineNum to avoid duplicates
		while @hFound[lineNum]
			if lineNum < 0
				lineNum -= 1000
			else
				lineNum += 1000
		@hFound[lineNum] = true
		return lineNum

# ---------------------------------------------------------------------------

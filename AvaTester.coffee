# AvaTester.coffee

import {strict as assert} from 'assert'
import test from 'ava'

import {
	undef,
	say,
	isString,
	isFunction,
	isInteger,
	stringToArray,
	} from '@jdeighan/coffee-utils'

# ---------------------------------------------------------------------------

export class AvaTester

	constructor: (whichTest='deepEqual', @fulltest=false) ->
		@hFound = {}
		@setWhichTest whichTest
		@justshow = false
		@testing = true
		@maxLineNum = undef

	# ........................................................................

	justshow: (flag) ->

		@justshow = flag

	# ........................................................................

	just_show: (flag) ->

		@justshow = flag

	# ........................................................................

	setMaxLineNum: (n) ->

		@maxLineNum = n

	# ........................................................................

	setWhichTest: (testName) ->
		@whichTest = testName
		return

	# ........................................................................

	transformValue: (input) ->
		return input

	# ........................................................................

	truthy: (lineNum, input, expected) ->
		@setWhichTest 'truthy'
		@test lineNum, input, expected

	# ........................................................................

	falsy: (lineNum, input, expected) ->
		@setWhichTest 'falsy'
		@test lineNum, input, expected

	# ........................................................................

	equal: (lineNum, input, expected) ->
		if isString(input) && isString(expected)
			@setWhichTest 'is'
		else
			@setWhichTest 'deepEqual'
		@test lineNum, input, expected

	# ........................................................................

	notequal: (lineNum, input, expected) ->
		@setWhichTest 'notDeepEqual'
		@test lineNum, input, expected

	# ........................................................................

	same: (lineNum, input, expected) ->
		@setWhichTest 'is'
		@test lineNum, input, expected

	# ........................................................................

	different: (lineNum, input, expected) ->
		@setWhichTest 'not'
		@test lineNum, input, expected

	# ........................................................................

	fails: (lineNum, func, expected) ->
		assert not expected?, "AvaTester: fails doesn't allow expected"
		assert isFunction(func), "AvaTester: fails requires a function"
		try
			func()
			ok = true
		catch err
			ok = false
		@setWhichTest 'falsy'
		@test lineNum, ok, expected

	# ........................................................................

	succeeds: (lineNum, func, expected) ->
		assert not expected?, "AvaTester: fails doesn't allow expected"
		assert isFunction(func), "AvaTester: fails requires a function"
		try
			func()
			ok = true
		catch err
			ok = false
		@setWhichTest 'truthy'
		@test lineNum, ok, expected

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

	test: (lineNum, input, expected) ->

		if not @testing || (@maxLineNum && (lineNum > @maxLineNum))
			return

		assert isInteger(lineNum), "AvaTester.test(): arg 1 must be an integer"

		lineNum = @getLineNum(lineNum)   # corrects for duplicates
		try
			got = @normalize(@transformValue(input))
			got_error = false
		catch err
			got_error = true
		expected = @normalize(expected)

		if @justshow
			say "line #{lineNum}"
			if got_error
				say "GOT ERROR"
			else
				say result, "GOT:"
			say expected, "EXPECTED:"
			return

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichTest = @whichTest

		if lineNum < 0
			test.only "line #{lineNum}", (t) ->
				t[whichTest] got, expected
			@testing = false
		else
			test "line #{lineNum}", (t) ->
				t[whichTest] got, expected
		return

	# ........................................................................

	getLineNum: (lineNum) ->

		if @fulltest && (lineNum < 0)
			error "AvaTester(): negative line number during full test!!!"

		# --- patch lineNum to avoid duplicates
		while @hFound[lineNum]
			if lineNum < 0
				lineNum -= 1000
			else
				lineNum += 1000
		@hFound[lineNum] = true
		return lineNum

# ---------------------------------------------------------------------------

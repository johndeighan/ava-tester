# AvaTester.coffee

import {strict as assert} from 'assert'
import test from 'ava'

import {
	undef, say, error, stringToArray,
	isString, isFunction, isInteger, isArray,
	} from '@jdeighan/coffee-utils'
import {debug, debugging, setDebugging} from '@jdeighan/coffee-utils/debug'

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

	same_list: (lineNum, list, expected) ->
		assert not list? || isArray(list), "AvaTester: not an array"
		assert not expected? || isArray(expected), "AvaTester: expected is not an array"

		@setWhichTest 'deepEqual'
		@test lineNum, list.sort(), expected.sort()

	# ........................................................................

	not_same_list: (lineNum, list, expected) ->
		assert not list? || isArray(list), "AvaTester: not an array"
		assert not expected? || isArray(expected), "AvaTester: expected is not an array"

		@setWhichTest 'notDeepEqual'
		@test lineNum, list.sort(), expected.sort()

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

		@lineNum = lineNum    # set an object property

		if (lineNum < 0) && process.env.FINALTEST
			error "Negative line numbers not allowed in FINALTEST"

		saveDebugging = undef
		if lineNum < -100000
			saveDebugging = debugging
			setDebugging(true)

		debug "enter AvaTester.test()"
		if not @testing || (@maxLineNum && (lineNum > @maxLineNum))
			debug "return immediately"
			if saveDebugging? then setDebugging(saveDebugging)
			return

		assert isInteger(lineNum), "AvaTester.test(): arg 1 must be an integer"

		lineNum = @getLineNum(lineNum)   # corrects for duplicates
		errMsg = undef
		try
			got = @transformValue(input)
			if isString(got)
				got = @normalize(got)
			debug got, "GOT:"
		catch err
			errMsg = err.message || 'UNKNOWN ERROR'
			debug "got ERROR: #{errMsg}"

		if isString(expected)
			expected = @normalize(expected)

		if @justshow
			say "line #{lineNum}"
			if errMsg
				say "GOT ERROR #{errMsg}"
			else
				say got, "GOT:"
			say expected, "EXPECTED:"
			debug "return = justshow set"
			if saveDebugging? then setDebugging(saveDebugging)
			return

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichTest = @whichTest
		debug "whichTest = #{whichTest}"

		if lineNum < 0
			test.only "line #{lineNum}", (t) ->
				t[whichTest] got, expected
			@testing = false
		else
			test "line #{lineNum}", (t) ->
				t[whichTest] got, expected
		debug "return from AvaTester.test()"
		if saveDebugging? then setDebugging(saveDebugging)
		return

	# ........................................................................

	transformValue: (input) ->
		return input

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

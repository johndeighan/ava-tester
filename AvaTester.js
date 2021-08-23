// Generated by CoffeeScript 2.5.1
  // AvaTester.coffee
import {
  strict as assert
} from 'assert';

import test from 'ava';

import {
  undef,
  say,
  error,
  stringToArray,
  isString,
  isFunction,
  isInteger,
  isArray
} from '@jdeighan/coffee-utils';

import {
  debug,
  debugging,
  setDebugging
} from '@jdeighan/coffee-utils/debug';

// ---------------------------------------------------------------------------
export var AvaTester = class AvaTester {
  constructor(whichTest = 'deepEqual', fulltest = false) {
    this.fulltest = fulltest;
    this.hFound = {};
    this.setWhichTest(whichTest);
    this.justshow = false;
    this.testing = true;
    this.maxLineNum = undef;
  }

  // ........................................................................
  justshow(flag) {
    return this.justshow = flag;
  }

  // ........................................................................
  just_show(flag) {
    return this.justshow = flag;
  }

  // ........................................................................
  setMaxLineNum(n) {
    return this.maxLineNum = n;
  }

  // ........................................................................
  setWhichTest(testName) {
    this.whichTest = testName;
  }

  // ........................................................................
  truthy(lineNum, input, expected) {
    this.setWhichTest('truthy');
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  falsy(lineNum, input, expected) {
    this.setWhichTest('falsy');
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  equal(lineNum, input, expected) {
    if (isString(input) && isString(expected)) {
      this.setWhichTest('is');
    } else {
      this.setWhichTest('deepEqual');
    }
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  notequal(lineNum, input, expected) {
    this.setWhichTest('notDeepEqual');
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  same(lineNum, input, expected) {
    this.setWhichTest('is');
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  different(lineNum, input, expected) {
    this.setWhichTest('not');
    return this.test(lineNum, input, expected);
  }

  // ........................................................................
  fails(lineNum, func, expected) {
    var err, ok;
    assert(expected == null, "AvaTester: fails doesn't allow expected");
    assert(isFunction(func), "AvaTester: fails requires a function");
    try {
      func();
      ok = true;
    } catch (error1) {
      err = error1;
      ok = false;
    }
    this.setWhichTest('falsy');
    return this.test(lineNum, ok, expected);
  }

  // ........................................................................
  succeeds(lineNum, func, expected) {
    var err, ok;
    assert(expected == null, "AvaTester: fails doesn't allow expected");
    assert(isFunction(func), "AvaTester: fails requires a function");
    try {
      func();
      ok = true;
    } catch (error1) {
      err = error1;
      ok = false;
    }
    this.setWhichTest('truthy');
    return this.test(lineNum, ok, expected);
  }

  // ........................................................................
  same_list(lineNum, list, expected) {
    assert((list == null) || isArray(list), "AvaTester: not an array");
    assert((expected == null) || isArray(expected), "AvaTester: expected is not an array");
    this.setWhichTest('deepEqual');
    return this.test(lineNum, list.sort(), expected.sort());
  }

  // ........................................................................
  not_same_list(lineNum, list, expected) {
    assert((list == null) || isArray(list), "AvaTester: not an array");
    assert((expected == null) || isArray(expected), "AvaTester: expected is not an array");
    this.setWhichTest('notDeepEqual');
    return this.test(lineNum, list.sort(), expected.sort());
  }

  // ........................................................................
  normalize(input) {
    var lLines, line;
    // --- Convert all whitespace to single space character
    //     Remove empty lines
    if (isString(input)) {
      lLines = (function() {
        var i, len, ref, results;
        ref = stringToArray(input);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          line = ref[i];
          line = line.trim();
          results.push(line.replace(/\s+/g, ' '));
        }
        return results;
      })();
      lLines = lLines.filter(function(line) {
        return line !== '';
      });
      return lLines.join('\n');
    } else {
      return input;
    }
  }

  // ........................................................................
  test(lineNum, input, expected) {
    var err, errMsg, got, saveDebugging, whichTest;
    if ((lineNum < 0) && process.env.FINALTEST) {
      error("Negative line numbers not allowed in FINALTEST");
    }
    saveDebugging = undef;
    if (lineNum < -100000) {
      saveDebugging = debugging;
      setDebugging(true);
    }
    debug("enter AvaTester.test()");
    if (!this.testing || (this.maxLineNum && (lineNum > this.maxLineNum))) {
      debug("return immediately");
      if (saveDebugging != null) {
        setDebugging(saveDebugging);
      }
      return;
    }
    assert(isInteger(lineNum), "AvaTester.test(): arg 1 must be an integer");
    lineNum = this.getLineNum(lineNum); // corrects for duplicates
    errMsg = undef;
    try {
      got = this.transformValue(input);
      if (isString(got)) {
        got = this.normalize(got);
      }
      debug(got, "GOT:");
    } catch (error1) {
      err = error1;
      errMsg = err.message || 'UNKNOWN ERROR';
      debug(`got ERROR: ${errMsg}`);
    }
    if (isString(expected)) {
      expected = this.normalize(expected);
    }
    if (this.justshow) {
      say(`line ${lineNum}`);
      if (errMsg) {
        say(`GOT ERROR ${errMsg}`);
      } else {
        say(got, "GOT:");
      }
      say(expected, "EXPECTED:");
      debug("return = justshow set");
      if (saveDebugging != null) {
        setDebugging(saveDebugging);
      }
      return;
    }
    // --- We need to save this here because in the tests themselves,
    //     'this' won't be correct
    whichTest = this.whichTest;
    debug(`whichTest = ${whichTest}`);
    if (lineNum < 0) {
      test.only(`line ${lineNum}`, function(t) {
        return t[whichTest](got, expected);
      });
      this.testing = false;
    } else {
      test(`line ${lineNum}`, function(t) {
        return t[whichTest](got, expected);
      });
    }
    debug("return from AvaTester.test()");
    if (saveDebugging != null) {
      setDebugging(saveDebugging);
    }
  }

  // ........................................................................
  transformValue(input) {
    return input;
  }

  // ........................................................................
  getLineNum(lineNum) {
    if (this.fulltest && (lineNum < 0)) {
      error("AvaTester(): negative line number during full test!!!");
    }
    // --- patch lineNum to avoid duplicates
    while (this.hFound[lineNum]) {
      if (lineNum < 0) {
        lineNum -= 1000;
      } else {
        lineNum += 1000;
      }
    }
    this.hFound[lineNum] = true;
    return lineNum;
  }

};

// ---------------------------------------------------------------------------

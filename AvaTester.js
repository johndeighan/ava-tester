// Generated by CoffeeScript 2.5.1
  // AvaTester.coffee
import {
  strict as assert
} from 'assert';

import test from 'ava';

import {
  undef,
  say,
  isString,
  isFunction,
  isInteger,
  stringToArray
} from '@jdeighan/coffee-utils';

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
  transformValue(input) {
    return input;
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
  fails(lineNum, input, expected) {
    if (expected !== undef) {
      error("AvaTester.fails(): expected value not allowed");
    }
    this.setWhichTest('throws');
    return this.test(lineNum, input, expected);
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
    var err, got, whichTest;
    if (!this.testing || (this.maxLineNum && (lineNum > this.maxLineNum))) {
      return;
    }
    assert(isInteger(lineNum), "AvaTester.test(): arg 1 must be an integer");
    lineNum = this.getLineNum(lineNum);
    expected = this.normalize(expected);
    // --- We need to save this here because in the tests themselves,
    //     'this' won't be correct
    whichTest = this.whichTest;
    if (whichTest === 'throws') {
      if (this.justshow) {
        say(`line ${lineNum}`);
        try {
          got = this.transformValue(input);
          say(result, "GOT:");
        } catch (error1) {
          err = error1;
          say("GOT ERROR");
        }
        say("EXPECTED ERROR");
      }
    } else {
      got = this.normalize(this.transformValue(input));
      if (lineNum < 0) {
        if (this.justshow) {
          say(`line ${lineNum}`);
          say(got, "GOT:");
          say(expected, "EXPECTED:");
        } else {
          test.only(`line ${lineNum}`, function(t) {
            return t[whichTest](got, expected);
          });
        }
        this.testing = false;
      } else {
        test(`line ${lineNum}`, function(t) {
          return t[whichTest](got, expected);
        });
      }
    }
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

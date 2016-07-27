assert = require "luassert"
concat = table.concat

is_like = (state, arguments) ->
  expected = arguments[1]\trim!
  (value) ->
    assert.equal value\trim!, expected

assert\register "assertion", "is_like", is_like

pattern_escapes = {
  "(": "%(",
  ")": "%)",
  ".": "%.",
  "%": "%%",
  "+": "%+",
  "-": "%-",
  "*": "%*",
  "?": "%?",
  "[": "%[",
  "]": "%]",
  "^": "%^",
  "$": "%$",
  "\0": "%z"
}

escape_pattern = (str) -> str\gsub(".", pattern_escapes)

export *

trim = (str) ->
  t = str\match "^%s*()"
  t > #str and "" or str\match(".*%S", t)

string.split = (str, delim) ->
  return {} if str == ""
  str ..= delim
  delim = escape_pattern(delim)
  [m for m in str\gmatch("(.-)"..delim)]

string.trim = (str) ->
  stripped = {}
  lines = str\split "\n"
  for line in *lines
    trimmed = trim line
    empty = trimmed\match "^%s*$"
    unless empty
      stripped[#stripped + 1] = trimmed
  concat stripped, "\n"

moon = require 'moon'

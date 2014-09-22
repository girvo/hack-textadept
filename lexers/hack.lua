-- Copyright 2006-2014 Mitchell mitchell.att.foicica.com. See LICENSE.
-- Adapted from php.lua by Josh Girvin <josh@jgirvin.com>
-- PHP/Hack LPeg lexer.

local l = require('lexer')
local token, word_match = l.token, l.word_match
local P, R, S, V = lpeg.P, lpeg.R, lpeg.S, lpeg.V

local M = {_NAME = 'hack'}

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = (P('//') + '#') * l.nonnewline^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, block_comment + line_comment)

-- Strings.
local sq_str = l.delimited_range("'")
local dq_str = l.delimited_range('"')
local bt_str = l.delimited_range('`')
local heredoc = '<<<' * P(function(input, index)
  local _, e, delimiter = input:find('([%a_][%w_]*)[\n\r\f]+', index)
  if delimiter then
    local _, e = input:find('[\n\r\f]+'..delimiter, e)
    return e and e + 1
  end
end)
local string = token(l.STRING, sq_str + dq_str + bt_str + heredoc)
-- TODO: interpolated code.

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match{
  'and', 'array', 'as', 'break', 'case',
  'cfunction', 'class', 'const', 'continue', 'declare', 'default',
  'die', 'directory', 'do', 'double', 'echo', 'else', 'elseif',
  'empty', 'enddeclare', 'endfor', 'endforeach', 'endif',
  'endswitch', 'endwhile', 'eval', 'exit', 'extends', 'false',
  'for', 'foreach', 'function', 'global', 'if', 'include',
  'include_once', 'isset', 'list', 'new', 'null', 'namespace',
  'object', 'old_function', 'or', 'parent', 'print',
  'require', 'require_once', 'resource', 'return', 'static',
  'stdclass', 'switch', 'true', 'unset', 'use', 'var',
  'while', 'xor', '__class__', '__file__', '__function__',
  '__line__', '__sleep', '__wakeup', 'yield', 'await', 'async'
})

-- Types.
local types = token(l.TYPE, word_match{
  'array', 'ArrayAccess', 'Awaitable', 'bool', 'boolean', 'callable', 
  'contained', 'Continuation', 'double', 'float', 'ImmMap', 'ImmSet', 
  'ImmVector', 'Indexish', 'int', 'integer', 'Iterable', 'Iterator', 
  'IteratorAggregate', 'KeyedIterable', 'KeyedIterator', 'KeyedTraversable', 
  'Map', 'mixed', 'newtype', 'null', 'num', 'object', 'Pair', 'real', 'Set', 
  'shape', 'string', 'stringish', 'Traversable', 'tuple', 'type', 
  'Vector', 'void'
})

-- Variables.
local word = (l.alpha + '_' + R('\127\255')) * (l.alnum + '_' + R('\127\255'))^0
local variable = token(l.VARIABLE, '$' * word)

-- Identifiers.
local identifier = token(l.IDENTIFIER, word)

-- Operators.
local operator = token(l.OPERATOR, S('!@%^*&()-+=|/.,;:<>[]{}') + '?' * -P('>'))

-- Classes.
local class_sequence = token(l.KEYWORD, P('class')) * ws^1 *
                       token(l.CLASS, l.word)

M._rules = {
  {'whitespace', ws},
  {'class', class_sequence},
  {'keyword', keyword},
  {'type', types},
  {'identifier', identifier},
  {'string', string},
  {'variable', variable},
  {'comment', comment},
  {'number', number},
  {'operator', operator},
}

-- Embedded in HTML.
local html = l.load('html')

-- Embedded hack.
local hack_start_rule = token('hack_tag', '<?' * ('hh' * l.space)^-1)
local hack_end_rule = token('hack_tag', '?>')
l.embed_lexer(html, M, hack_start_rule, hack_end_rule)

M._tokenstyles = {
  hack_tag = l.STYLE_EMBEDDED
}

local _foldsymbols = html._foldsymbols
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '<%?'
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '%?>'
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '//'
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '#'
_foldsymbols.hack_tag = {['<?'] = 1, ['?>'] = -1}
_foldsymbols[l.COMMENT]['//'] = l.fold_line_comments('//')
_foldsymbols[l.COMMENT]['#'] = l.fold_line_comments('#')
M._foldsymbols = _foldsymbols

return M

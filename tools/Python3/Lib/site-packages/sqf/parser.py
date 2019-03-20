from collections import defaultdict
import re

import sqf.base_type
from sqf.base_tokenizer import tokenize

from sqf.exceptions import SQFParenthesisError, SQFParserError
from sqf.types import Statement, Code, Number, Boolean, Variable, Array, String, Keyword, Namespace, Preprocessor, ParserType
from sqf.keywords import KEYWORDS, NAMESPACES, PREPROCESSORS
from sqf.parser_types import Comment, Space, Tab, EndOfLine, BrokenEndOfLine, EndOfFile, ParserKeyword
from sqf.interpreter_types import DefineStatement, DefineResult, IfDefStatement, IfDefResult
from sqf.parser_exp import parse_exp


def rindex(the_list, value):
    return len(the_list) - the_list[::-1].index(value) - 1


_LEVELS = {'[]': 0, '()': 0, '{}': 0, '#include': 0, '#define': 0, 'ifdef': 0, 'ifdef_open_close': 0}


STOP_KEYWORDS = {
    'single': (ParserKeyword(';'),),
    'both': (ParserKeyword(';'), ParserKeyword(',')),
}

OPEN_PARENTHESIS = (ParserKeyword('['), ParserKeyword('('), ParserKeyword('{'))
CLOSE_PARENTHESIS = (ParserKeyword(']'), ParserKeyword(')'), ParserKeyword('}'))


def get_coord(tokens):
    return sqf.base_type.get_coord(''.join([str(x) for x in tokens]))


def add_coords(coord1, tokens):
    coord2 = get_coord(tokens)
    return coord1[0] + coord2[0], coord1[1] + coord2[1] - 1


def identify_token(token):
    """
    The function that converts a token from tokenize to a BaseType.
    """
    if isinstance(token, (Comment, String)):
        return token
    if token == ' ':
        return Space()
    if token == '\t':
        return Tab()
    if token == '\\\n':
        return BrokenEndOfLine()
    if token in ('(', ')', '[', ']', '{', '}', ',', ';'):
        return ParserKeyword(token)
    if token in ('\n', '\r\n'):
        return EndOfLine(token)
    if token in ('true', 'false'):
        return Boolean(token == 'true')
    try:
        return Number(int(token))
    except ValueError:
        pass
    try:
        return Number(float(token))
    except ValueError:
        pass
    if token in PREPROCESSORS:
        return Preprocessor(token)
    if token.lower() in NAMESPACES:
        return Namespace(token)
    elif token.lower() in KEYWORDS:
        return Keyword(token)
    else:
        return Variable(token)


def replace_in_expression(expression, args, arg_indexes, all_tokens):
    """
    Recursively replaces matches of `args` in expression (a list of Types).
    """
    replacing_expression = []
    for token in expression:
        if isinstance(token, Statement):
            new_expression = replace_in_expression(token.content, args, arg_indexes, all_tokens)
            token = Statement(new_expression, ending=token.ending, parenthesis=token.parenthesis)
            replacing_expression.append(token)
        else:
            for arg, arg_index in zip(args, arg_indexes):
                if str(token) == arg:
                    replacing_expression.append(all_tokens[arg_index])
                    break
            else:
                replacing_expression.append(token)
    return replacing_expression


def parse_strings_and_comments(all_tokens):
    """
    Function that parses the strings of a script, transforming them into `String`.
    """
    string = ''  # the buffer for the activated mode
    tokens = []  # the final result
    in_double = False
    mode = None  # [None, "string_single", "string_double", "comment_line", "comment_bulk"]

    for i, token in enumerate(all_tokens):
        if mode == "string_double":
            string += token
            if token == '"':
                if in_double:
                    in_double = False
                elif not in_double and i != len(all_tokens) - 1 and all_tokens[i+1] == '"':
                    in_double = True
                else:
                    tokens.append(String(string))
                    mode = None
                    in_double = False
        elif mode == "string_single":
            string += token
            if token == "'":
                if in_double:
                    in_double = False
                elif not in_double and i != len(all_tokens) - 1 and all_tokens[i + 1] == "'":
                    in_double = True
                else:
                    tokens.append(String(string))
                    mode = None
                    in_double = False
        elif mode == "comment_bulk":
            string += token
            if token == '*/':
                mode = None
                tokens.append(Comment(string))
                string = ''
        elif mode == "comment_line":
            string += token
            if token in ('\n', '\r\n'):
                mode = None
                tokens.append(Comment(string))
                string = ''
        else:  # mode is None
            if token == '"':
                string = token
                mode = "string_double"
            elif token == "'":
                string = token
                mode = "string_single"
            elif token == '/*':
                string = token
                mode = "comment_bulk"
            elif token == '//':
                string = token
                mode = "comment_line"
            else:
                tokens.append(token)

    if mode in ("comment_line", "comment_bulk"):
        tokens.append(Comment(string))
    elif mode is not None:
        raise SQFParserError(get_coord(tokens), 'String is not closed')

    return tokens


def _analyze_simple(tokens):
    return Statement(tokens)


def _analyze_tokens(tokens):
    ending = None
    if tokens and tokens[-1] in STOP_KEYWORDS['both']:
        ending = tokens[-1].value
        del tokens[-1]

    statement = parse_exp(tokens, container=Statement)
    if isinstance(statement, Statement):
        statement.ending = ending
    else:
        statement = Statement([statement], ending=ending)

    return statement


def _analyze_array(tokens, analyze_tokens, tokens_until):
    result = []
    part = []
    first_comma_found = False
    for token in tokens:
        if token == ParserKeyword(','):
            first_comma_found = True
            if not part:
                raise SQFParserError(get_coord(tokens_until), 'Array cannot have an empty element')
            result.append(analyze_tokens(part))
            part = []
        else:
            part.append(token)

    # an empty array is a valid array
    if part == [] and first_comma_found:
        raise SQFParserError(get_coord(tokens_until), 'Array cannot have an empty element')
    elif tokens:
        result.append(analyze_tokens(part))
    return result


def _analyze_define(tokens):
    assert(tokens[0] == Preprocessor('#define'))

    valid_indexes = [i for i in range(len(tokens)) if not isinstance(tokens[i], ParserType)]

    if len(valid_indexes) < 2:
        raise SQFParserError(get_coord(str(tokens[0])), '#define needs at least one argument')
    variable = str(tokens[valid_indexes[1]])
    if len(valid_indexes) == 2:
        return DefineStatement(tokens, variable)
    elif len(valid_indexes) >= 3 and valid_indexes[1] + 1 == valid_indexes[2] and isinstance(tokens[valid_indexes[2]], Statement) and tokens[valid_indexes[2]].parenthesis:
        args = str(tokens[valid_indexes[2]])[1:-1].split(',')
        remaining = tokens[valid_indexes[3]:]
        return DefineStatement(tokens, variable, remaining, args=args)
    elif len(valid_indexes) >= 3:
        remaining = tokens[valid_indexes[2]:]
        return DefineStatement(tokens, variable, remaining)


def find_match_if_def(all_tokens, i, defines, token):
    found = False
    define_statement = None
    arg_indexes = []
    if i + 1 < len(all_tokens) and str(all_tokens[i + 1]) == '(':
        possible_args = defines[str(token)]
        arg_indexes = []
        for arg_number in possible_args:
            if arg_number == 0:
                continue

            for arg_i in range(arg_number + 1):
                if arg_i == arg_number:
                    index = i + 2 + 2 * arg_i - 1
                else:
                    index = i + 2 + 2 * arg_i

                if index >= len(all_tokens):
                    break
                arg_str = str(all_tokens[index])

                if arg_i == arg_number and arg_str != ')':
                    break
                elif not re.match('(.*?)', arg_str):
                    break
                if arg_i != arg_number:
                    arg_indexes.append(index)
            else:
                define_statement = defines[str(token)][arg_number]
                found = True
                break
    elif 0 in defines[str(token)]:
        define_statement = defines[str(token)][0]
        arg_indexes = []
        found = True

    return found, define_statement, arg_indexes


def get_ifdef_variable(tokens, ifdef_i, coord_until_here):
    variable = None
    eol_i = None
    for i, token in enumerate(tokens[ifdef_i:]):
        if type(token) == EndOfLine:
            eol_i = ifdef_i + i
            break
        if type(token) in (Variable, Keyword):
            variable = str(token)
    if variable is not None and eol_i is not None:
        return variable, eol_i
    raise SQFParserError(add_coords(coord_until_here, tokens[:ifdef_i]), '#ifdef statement must contain a variable')


def parse_ifdef_block(expression, defines, coord_until_here):
    """
    Given a IfDefStatement and the defines, converts the statement.tokens into
    a list of tokens that can be analyzed after processing the #ifdef statement.
    `position_until_here` used to compute position of errors
    """
    assert(isinstance(expression, IfDefStatement))
    tokens = expression.tokens
    try:
        ifdef_i = rindex(tokens, Preprocessor('#ifdef'))
        is_ifdef = True
    except ValueError:
        ifdef_i = rindex(tokens, Preprocessor('#ifndef'))
        is_ifdef = False
    try:
        else_i = rindex(tokens, Preprocessor('#else'))
    except ValueError:
        else_i = None
    endif_i = rindex(tokens, Preprocessor('#endif'))
    try:
        # if there is an if_def statement before #endif, the remaining tokens are transferred to it
        nested_if_def = next(i for i, x in enumerate(tokens) if type(x) == IfDefStatement and i < endif_i)
    except StopIteration:
        nested_if_def = None

    variable, eol_i = get_ifdef_variable(tokens, ifdef_i, coord_until_here)

    is_def = (variable in defines)

    replacing_expression = []
    if is_def and is_ifdef or not is_def and not is_ifdef:
        if else_i is None:
            to = endif_i
            if nested_if_def is not None and nested_if_def < endif_i:
                to = nested_if_def + 1
            replacing_expression = tokens[eol_i:to]
        else:
            to = else_i
            if nested_if_def is not None and nested_if_def < else_i:
                to = nested_if_def + 1
            replacing_expression = tokens[eol_i:to]
    elif else_i is not None:
        replacing_expression = tokens[else_i + 1:endif_i]

    try:
        # if there is an if_def statement after the #endif, the remaining tokens are transferred to it
        if_def_i = next(i for i, x in enumerate(tokens) if type(x) == IfDefStatement and i > endif_i)
        next_if_def = tokens[if_def_i]
        replacing_expression.append(next_if_def)
        remaining_tokens = tokens[if_def_i + 1:]
        next_if_def.tokens.extend(remaining_tokens)
        expression._tokens = tokens[:if_def_i + 1]
    except StopIteration:
        replacing_expression += tokens[endif_i + 1:]

    return replacing_expression


def is_finish_ifdef_condition(tokens, lvls):
    return lvls['ifdef'] == sum(1 for token in tokens if token == Preprocessor('#endif')) > 0 and \
        lvls['ifdef_open_close'] == 0


def is_finish_ifdef_parenthesis(token, lvls):
    for lvl_type in ('()', '[]', '{}'):
        if lvls[lvl_type] != 0 and token == ParserKeyword(lvl_type[1]):
            return True
    return False


def finish_ifdef(tokens, all_tokens, start, statements):
    tokens.insert(0, all_tokens[start - 1])  # pick the token that triggered the statement
    assert (len(statements) == 0)
    return IfDefStatement(tokens)


def is_end_statement(token, stop_statement):
    return token in STOP_KEYWORDS[stop_statement] or isinstance(token, EndOfFile)


def parse_block(all_tokens, analyze_tokens, start=0, initial_lvls=None, stop_statement='both', defines=None):
    if not initial_lvls:
        initial_lvls = _LEVELS
    if defines is None:
        defines = defaultdict(dict)
    lvls = initial_lvls.copy()

    statements = []
    tokens = []
    i = start
    if not all_tokens:
        return Statement([]), 0

    while i < len(all_tokens):
        token = all_tokens[i]

        # begin #ifdef controls
        if lvls['ifdef'] and token in OPEN_PARENTHESIS:
            lvls['ifdef_open_close'] += 1

        stop = False
        if token in (Preprocessor('#ifdef'), Preprocessor('#ifndef')):
            stop = True
            lvls['ifdef'] += 1
            expression, size = parse_block(all_tokens, _analyze_simple, i + 1, lvls, stop_statement,
                                           defines=defines)
            lvls['ifdef'] -= 1
            if lvls['ifdef'] == 0:
                assert (isinstance(expression, IfDefStatement))
                replacing_expression = parse_ifdef_block(expression, defines, get_coord(all_tokens[:i - 1]))

                new_all_tokens = sqf.base_type.get_all_tokens(tokens + replacing_expression)

                result, _ = parse_block(new_all_tokens, analyze_tokens, 0, None, stop_statement,
                                        defines=defines)

                expression.prepend(tokens)

                expression = IfDefResult(expression, result.tokens)
                statements.append(expression)

                len_expression = len(expression.get_all_tokens())

                i += len_expression - len(tokens) - 1
                tokens = []
            else:
                tokens.append(expression)
                i += size + 1
        # finish ifdef
        elif is_finish_ifdef_condition(tokens, lvls) and (
                    is_end_statement(token, stop_statement) or
                    is_finish_ifdef_parenthesis(token, lvls)
                ) or lvls['ifdef'] > 1 and token == Preprocessor('#endif'):

            if token != EndOfFile() and token not in CLOSE_PARENTHESIS:
                tokens.append(token)

            if_def = finish_ifdef(tokens, all_tokens, start, statements)
            return if_def, i - start
        # parse during ifdef
        elif lvls['ifdef'] != 0:
            stop = True
            tokens.append(token)

        # end ifdef controls
        if lvls['ifdef'] and token in (STOP_KEYWORDS['single'] + CLOSE_PARENTHESIS):
            lvls['ifdef_open_close'] -= 1
            if lvls['ifdef_open_close'] < 0:
                lvls['ifdef_open_close'] = 0

        if stop:
            pass
        # try to match a #defined and get the arguments
        elif str(token) in defines:  # is a define
            stop, define_statement, arg_indexes = find_match_if_def(all_tokens, i, defines, token)

            if stop:
                arg_number = len(define_statement.args)

                extra_tokens_to_move = 1 + 2 * (arg_number != 0) + 2 * arg_number - 1 * (arg_number != 0)

                replaced_expression = all_tokens[i:i + extra_tokens_to_move]

                # the `all_tokens` after replacement
                replacing_expression = replace_in_expression(define_statement.expression, define_statement.args,
                                                             arg_indexes, all_tokens)

                new_all_tokens = all_tokens[:i - len(tokens)] + tokens + replacing_expression + all_tokens[
                                                                                                i + extra_tokens_to_move:]

                new_start = i - len(tokens)

                expression, size = parse_block(new_all_tokens, analyze_tokens, new_start, lvls,
                                               stop_statement, defines=defines)

                # the all_tokens of the statement before replacement
                original_tokens_taken = len(replaced_expression) - len(replacing_expression) + size

                original_tokens = all_tokens[i - len(tokens):i - len(tokens) + original_tokens_taken]

                if isinstance(expression, Statement):
                    expression = expression.content[0]

                if type(original_tokens[-1]) in (EndOfLine, Comment, EndOfFile):
                    del original_tokens[-1]
                    original_tokens_taken -= 1

                expression = DefineResult(original_tokens, define_statement, expression)
                statements.append(expression)

                i += original_tokens_taken - len(tokens) - 1

                tokens = []
        if stop:
            pass
        elif token == ParserKeyword('['):
            lvls['[]'] += 1
            expression, size = parse_block(all_tokens, analyze_tokens, i + 1, lvls, stop_statement='single', defines=defines)
            lvls['[]'] -= 1
            tokens.append(expression)
            i += size + 1
        elif token == ParserKeyword('('):
            lvls['()'] += 1
            expression, size = parse_block(all_tokens, analyze_tokens, i + 1, lvls, stop_statement, defines=defines)
            lvls['()'] -= 1
            tokens.append(expression)
            i += size + 1
        elif token == ParserKeyword('{'):
            lvls['{}'] += 1
            expression, size = parse_block(all_tokens, analyze_tokens, i + 1, lvls, stop_statement, defines=defines)
            lvls['{}'] -= 1
            tokens.append(expression)
            i += size + 1

        elif token == ParserKeyword(']'):
            if lvls['[]'] == 0:
                raise SQFParenthesisError(get_coord(all_tokens[:i]), 'Trying to close right parenthesis without them opened.')

            if statements:
                if isinstance(statements[0], DefineResult):
                    statements[0]._tokens = [Array(_analyze_array(statements[0]._tokens, analyze_tokens, all_tokens[:i]))]
                    return statements[0], i - start
                else:
                    raise SQFParserError(get_coord(all_tokens[:i]), 'A statement %s cannot be in an array' % Statement(statements))

            return Array(_analyze_array(tokens, analyze_tokens, all_tokens[:i])), i - start
        elif token == ParserKeyword(')'):
            if lvls['()'] == 0:
                raise SQFParenthesisError(get_coord(all_tokens[:i]), 'Trying to close parenthesis without opened parenthesis.')

            if tokens:
                statements.append(analyze_tokens(tokens))

            return Statement(statements, parenthesis=True), i - start
        elif token == ParserKeyword('}'):
            if lvls['{}'] == 0:
                raise SQFParenthesisError(get_coord(all_tokens[:i]), 'Trying to close brackets without opened brackets.')

            if tokens:
                statements.append(analyze_tokens(tokens))

            return Code(statements), i - start
        # end of statement when not in preprocessor states
        elif all(lvls[lvl_type] == 0 for lvl_type in ('#define', '#include')) and is_end_statement(token, stop_statement):
            if type(token) != EndOfFile:
                tokens.append(token)
            if tokens:
                statements.append(analyze_tokens(tokens))

            tokens = []
        elif token in (Preprocessor('#define'), Preprocessor('#include')):
            # notice that `token` is ignored here. It will be picked up in the end
            if tokens:
                # a pre-processor starts a new statement
                statements.append(analyze_tokens(tokens))
                tokens = []

            lvls[token.value] += 1
            expression, size = parse_block(all_tokens, analyze_tokens, i + 1, lvls, stop_statement, defines=defines)
            lvls[token.value] -= 1

            statements.append(expression)
            i += size
        elif type(token) in (EndOfLine, Comment, EndOfFile) and any(lvls[x] != 0 for x in {'#define', '#include'}):
            tokens.insert(0, all_tokens[start - 1])  # pick the token that triggered the statement
            if tokens[0] == Preprocessor('#define'):
                define_statement = _analyze_define(tokens)
                defines[define_statement.variable_name][len(define_statement.args)] = define_statement
                statements.append(define_statement)
            else:
                statements.append(analyze_tokens(tokens))

            return Statement(statements), i - start
        elif type(token) != EndOfFile:
            tokens.append(token)
        i += 1

    if is_finish_ifdef_condition(tokens, lvls):
        return finish_ifdef(tokens, all_tokens, start, statements), i - start

    for lvl_type in ('[]', '()', '{}', 'ifdef'):
        if lvls[lvl_type] != 0:
            message = 'Parenthesis "%s" not closed' % lvl_type[0]
            if lvl_type == 'ifdef':
                message = '#ifdef statement not closed'

            raise SQFParenthesisError(get_coord(all_tokens[:start - 1]), message)

    if tokens:
        statements.append(analyze_tokens(tokens))

    return Statement(statements), i - start


def parse(script):
    tokens = [identify_token(x) for x in parse_strings_and_comments(tokenize(script))]

    result = parse_block(tokens + [EndOfFile()], _analyze_tokens)[0]

    result.set_position((1, 1))

    return result

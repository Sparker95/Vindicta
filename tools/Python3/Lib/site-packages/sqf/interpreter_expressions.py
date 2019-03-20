import math

from sqf.common_expressions import TryCatchExpression, ForEachExpression, \
    WhileDoExpression, ForFromToDoExpression, ForSpecDoExpression, SwitchDoExpression, \
    IfThenSpecExpression, IfThenElseExpression, IfThenExpression, IfThenExitWithExpression
from sqf.types import Keyword, Namespace, Number, Array, Code, Type, Boolean, String, Nothing, Variable
from sqf.exceptions import SQFParserError
from sqf.keywords import OP_ARITHMETIC, OP_COMPARISON, OP_LOGICAL
from sqf.expressions import BinaryExpression, UnaryExpression
from sqf.interpreter_types import SwitchType


OP_OPERATIONS = {
    # Arithmetic
    Keyword('+'): lambda x, y: x + y,
    Keyword('-'): lambda x, y: x - y,
    Keyword('*'): lambda x, y: x * y,
    Keyword('/'): lambda x, y: x / y,
    Keyword('%'): lambda x, y: x % y,
    Keyword('mod'): lambda x, y: x % y,
    Keyword('^'): lambda x, y: x ** y,
    Keyword('max'): lambda x, y: max(x, y),
    Keyword('floor'): lambda x: math.floor(x),

    # Comparison
    Keyword('=='): lambda x, y: x == y,
    Keyword('!='): lambda x, y: x != y,
    Keyword('<'): lambda x, y: x < y,
    Keyword('>'): lambda x, y: x < y,
    Keyword('<='): lambda x, y: x <= y,
    Keyword('>='): lambda x, y: x >= y,

    # Logical
    Keyword('&&'): lambda x, y: x and y,
    Keyword('and'): lambda x, y: x and y,
    Keyword('||'): lambda x, y: x or y,
    Keyword('or'): lambda x, y: x or y,
}


class ComparisonExpression(BinaryExpression):

    def __init__(self, op, lhs_rhs_type):
        assert(op in OP_COMPARISON)
        assert (issubclass(lhs_rhs_type, Type))
        super().__init__(lhs_rhs_type, op, lhs_rhs_type, Boolean, self._action)

    def _action(self, lhs, rhs, _):
        return OP_OPERATIONS[self.keyword](lhs.value, rhs.value)


class ArithmeticExpression(BinaryExpression):

    def __init__(self, op):
        assert (op in OP_ARITHMETIC)
        super().__init__(Number, op, Number, Number, self._action)

    def _action(self, lhs, rhs, _):
        return OP_OPERATIONS[self.keyword](lhs.value, rhs.value)


class LogicalExpression(BinaryExpression):
    def __init__(self, op, rhs_type):
        assert (op in OP_LOGICAL)
        assert (rhs_type in (Boolean, Code))
        super().__init__(Boolean, op, rhs_type, Boolean, self._action)

    def _action(self, lhs, rhs, interpreter):
        if isinstance(rhs, Code):
            result = interpreter.execute_code(rhs)
            if type(result) not in (Boolean, Nothing):
                interpreter.exception(SQFParserError(rhs.position, 'code return must be a Boolean (returns %s)' % type(result).__name__))
                return None
        else:
            result = rhs

        return OP_OPERATIONS[self.keyword](lhs.value, result.value)


class Action:
    def __init__(self, action):
        self.action = action

    def __call__(self, *args):
        result = None
        # interpreter = args[-1]
        all_args = args[:-1]
        return self.action(*all_args)


def _select(lhs, rhs, interpreter):
    index = int(round(rhs.value))
    try:
        return lhs[index]
    except IndexError:
        interpreter.exception(SQFParserError(
            lhs.position, 'selecting element %d of array of size %d' % (index, len(lhs))))


def _select_array(lhs, rhs, interpreter):
    start = rhs.value[0].value
    count = rhs.value[1].value

    if start > len(lhs.value):
        interpreter.exception(SQFParserError(lhs.position, 'Selecting element past size'))

    return lhs.value[start:start + count]


def _subtract_arrays(lhs, rhs):
    rhs_set = set([rhs_i.value for rhs_i in rhs.value])
    return [lhs_i for lhs_i in lhs if lhs_i.value not in rhs_set]


def _find(lhs_v, rhs_v):
    try:
        index = next(i for i, v in enumerate(lhs_v.value) if v == rhs_v)
    except StopIteration:
        index = -1
    return index


def _pushBack(lhs_v, rhs_v):
    lhs_v.append(rhs_v)
    return len(lhs_v.value) - 1


def _pushBackUnique(lhs_v, rhs_v):
    if rhs_v in lhs_v.value:
        return -1
    else:
        lhs_v.append(rhs_v)
        return len(lhs_v.value) - 1


def _setVariable(lhs_v, rhs_v, interpreter):
    namespace_name = lhs_v.value
    assert(isinstance(rhs_v, Array))

    if len(rhs_v) not in [2, 3]:
        interpreter.exception(SQFParserError(
            rhs_v.position, 'setVariable requires array of 2-3 elements (has %d)' % (len(rhs_v))))

    # get the variable name
    if not isinstance(rhs_v.value[0], (String, Nothing)):
        interpreter.exception(SQFParserError(
            rhs_v.value[0].position, 'setVariable array first element must be a string (is %s)' % type(rhs_v.value[0]).__name__))

    variable_name = rhs_v.value[0].value
    # get the value
    rhs_assignment = rhs_v.value[1]

    scope = interpreter.get_scope(variable_name, namespace_name)
    scope[variable_name] = rhs_assignment


def _getVariableString(lhs_v, rhs_v, interpreter):
    variable = Variable(rhs_v.value)
    variable.position = rhs_v.position
    return interpreter.value(variable, lhs_v.value)


def _getVariableArray(lhs_v, rhs_v, interpreter):
    # get the variable name
    if len(rhs_v) != 2:
        interpreter.exception(SQFParserError(
            rhs_v.position, 'getVariable requires array of 2 elements (has %d)' % (len(rhs_v))))

    if not isinstance(rhs_v.value[0], (String, Nothing)):
        interpreter.exception(SQFParserError(
            rhs_v.value[0].position, 'getVariable array first element must be a string (is %s)' % type(rhs_v.value[0]).__name__))

    variable = Variable(rhs_v.value[0].value)
    variable.position = rhs_v.value[0].position
    outcome = interpreter.value(variable, lhs_v.value)
    if outcome == Nothing():
        outcome = rhs_v.value[1]
    return outcome


def _addPublicVariableEventHandler(lhs_v, rhs_v, interpreter):
    interpreter.client.add_listening(lhs_v.value, rhs_v)


def _if_then_else_code(interpreter, condition, then, else_=None):
    """
    The equivalent Python code for a if-then-else SQF statement
    """
    assert(isinstance(condition, bool) and isinstance(then, Code))
    if condition:
        result = interpreter.execute_code(then)
    else:
        if else_ is not None:
            result = interpreter.execute_code(else_)
        else:
            result = Nothing()
    return result


def _if_then_else(if_instance, then_or_else, interpreter):
    condition = if_instance.condition.value
    if isinstance(then_or_else, Code):
        then = then_or_else
        else_ = None
    else:
        then = then_or_else.then
        else_ = then_or_else.else_

    return _if_then_else_code(interpreter, condition, then, else_)


def parse_switch(interpreter, code):
    conditions = []
    default_used = False

    for statement in code.base_tokens:
        base_tokens = statement.base_tokens

        # evaluate all the base_tokens, trying to obtain their values
        values = []
        for token in base_tokens:
            v = interpreter.value(token)
            values.append(v)

        if type(values[0]) != SwitchType:
            interpreter.exception(SQFParserError(
                statement.position, 'Switch code can only start with "case" or "default"'))

        if values[0].keyword == Keyword('default'):
            if default_used:
                interpreter.exception(SQFParserError(code.position, 'Switch code contains more than 1 `default`'))
            default_used = True
            assert(isinstance(values[0].result, Code))
            conditions.append(('default', values[0].result))
        else:
            case_condition = values[0].result
            if len(values) == 1:
                conditions.append((case_condition, None))
            else:
                assert (len(values) == 3 and values[1] == Keyword(':'))
                outcome_statement = values[2]
                conditions.append((case_condition, outcome_statement))

    return conditions


def execute_switch(interpreter, result, conditions):
    try:
        default = next(o for c, o in conditions if c == 'default')
    except StopIteration:
        default = None

    final_outcome = None

    execute_next = False
    for condition, outcome in conditions:
        if condition == 'default':
            continue
        condition_outcome = interpreter.value(condition)

        if outcome is not None and execute_next:
            final_outcome = interpreter.execute_code(outcome)
            break
        elif condition_outcome == result:
            if outcome is not None:
                final_outcome = interpreter.execute_code(outcome)
                break
            else:
                execute_next = True

    if final_outcome is None:
        if default is not None:
            final_outcome = interpreter.execute_code(default)
        else:
            final_outcome = Boolean(True)

    return final_outcome


def _foreach_loop(interpreter, code, elements):
    outcome = Nothing()
    for i, x in enumerate(elements):
        outcome = interpreter.execute_code(code, extra_scope={'_x': x, '_forEachIndex': Number(i)})
    return outcome


def _forvar_loop_code(interpreter, token_name, start, stop, step, code):
    outcome = Nothing()
    outcome.position = code.position

    for i in range(start, stop + 1, step):
        outcome = interpreter.execute_code(code, extra_scope={token_name: Number(i)})
    return outcome


def _forvar_loop(for_instance, code, interpreter):
    return _forvar_loop_code(interpreter,
                             for_instance.variable.value,
                             for_instance.from_.value,
                             for_instance.to.value, for_instance.step.value, code)


def _forspecs_loop_code(interpreter, start_code, stop_code, increment_code, do_code):
    outcome = Nothing()
    outcome.position = start_code.position

    interpreter.execute_code(start_code)
    while True:
        condition_outcome = interpreter.execute_code(stop_code)
        if condition_outcome.value is False:
            break

        outcome = interpreter.execute_code(do_code)
        interpreter.execute_code(increment_code)
    return outcome


def _forspecs_loop(forspec_type, do_code, interpreter):
    return _forspecs_loop_code(interpreter, forspec_type.array[0],
                               forspec_type.array[1], forspec_type.array[2], do_code)


def _while_loop(interpreter, condition_code, do_code):
    outcome = Nothing()
    while True:
        condition_outcome = interpreter.execute_code(condition_code)
        if condition_outcome.value is False:
            break
        outcome = interpreter.execute_code(do_code)
    return outcome


INTERPRETER_EXPRESSIONS = [
    TryCatchExpression(),

    ForEachExpression(lambda lhs, rhs, i: _foreach_loop(i, lhs, rhs.value)),
    WhileDoExpression(lambda lhs, rhs, i: _while_loop(i, lhs.condition, rhs)),

    ForFromToDoExpression(_forvar_loop),
    ForSpecDoExpression(_forspecs_loop),
    SwitchDoExpression(lambda lhs, rhs, i: execute_switch(i, lhs.result, parse_switch(i, rhs))),

    IfThenSpecExpression(lambda if_type, array, i: _if_then_else_code(i, if_type.condition.value, array.value[0], array.value[1])),
    IfThenElseExpression(_if_then_else),
    IfThenExpression(_if_then_else),
    IfThenExitWithExpression(),

    # params
    UnaryExpression(Keyword('params'), Array, Nothing, lambda rhs_v, i: i.add_params(rhs_v)),
    BinaryExpression(Type, Keyword('params'), Array, Nothing, lambda lhs_v, rhs_v, i: i.add_params(rhs_v)),

    # Unary
    UnaryExpression(Keyword('-'), Number, Number, Action(lambda x: -x.value)),
    UnaryExpression(Keyword('floor'), Number, Number, Action(lambda x: math.floor(x.value))),
    UnaryExpression(Keyword('reverse'), Array, Nothing, Action(lambda rhs_v: rhs_v.reverse())),
    # Binary
    BinaryExpression(Array, Keyword('set'), Array,
                     Nothing, Action(lambda lhs_v, rhs_v: lhs_v.set(rhs_v))),

    # Array related
    BinaryExpression(Array, Keyword('resize'), Number,
                     Nothing, Action(lambda lhs_v, rhs_v: lhs_v.resize(rhs_v.value))),
    UnaryExpression(Keyword('count'), Array, Number, Action(lambda x: len(x.value))),
    BinaryExpression(Type, Keyword('in'), Array, Boolean, Action(lambda x, array: x in array.value)),

    BinaryExpression(Array, Keyword('select'), Number, None, _select),
    BinaryExpression(Array, Keyword('select'), Boolean, None, _select),
    BinaryExpression(Array, Keyword('select'), Array, Array, _select_array),

    BinaryExpression(Array, Keyword('find'), Type, Number, Action(_find)),
    BinaryExpression(String, Keyword('find'), String, Number,
                     Action(lambda lhs_v, rhs_v: lhs_v.value.find(rhs_v.value))),

    BinaryExpression(Array, Keyword('pushBack'), Type, Number, Action(_pushBack)),
    BinaryExpression(Array, Keyword('pushBackUnique'), Type, Number, Action(_pushBackUnique)),
    BinaryExpression(Array, Keyword('append'), Array, Nothing, Action(lambda lhs_v, rhs_v: lhs_v.add(rhs_v.value))),

    UnaryExpression(Keyword('toArray'), String, Array,
                    Action(lambda rhs_v: [Number(ord(s)) for s in rhs_v.value])),
    UnaryExpression(Keyword('toString'), Array, String,
                    Action(lambda rhs_v: '"'+''.join(chr(s.value) for s in rhs_v.value)+'"')),

    # code and namespaces
    UnaryExpression(Keyword('call'), Code, None, lambda rhs_v, i: i.execute_code(rhs_v)),
    BinaryExpression(Type, Keyword('call'), Code, None, lambda lhs_v, rhs_v, i: i.execute_code(rhs_v, extra_scope={"_this": lhs_v})),

    BinaryExpression(Namespace, Keyword('setVariable'), Array, Nothing, _setVariable),

    BinaryExpression(Namespace, Keyword('getVariable'), String, None, _getVariableString),
    BinaryExpression(Namespace, Keyword('getVariable'), Array, None, _getVariableArray),

    BinaryExpression(String, Keyword('addPublicVariableEventHandler'), Code, None, _addPublicVariableEventHandler),

    BinaryExpression(Array, Keyword('+'), Array, Array, Action(lambda lhs_v, rhs_v: lhs_v.value + rhs_v.value)),
    BinaryExpression(Array, Keyword('-'), Array, Array, Action(_subtract_arrays)),

    BinaryExpression(String, Keyword('+'), String, String, Action(lambda lhs, rhs: lhs.container + lhs.value + rhs.value + lhs.container)),
]

for op in OP_COMPARISON:
    for lhs_rhs_type in [Number, String]:
        if lhs_rhs_type == Number or lhs_rhs_type == String and op in [Keyword('=='), Keyword('!=')]:
            INTERPRETER_EXPRESSIONS.append(ComparisonExpression(op, lhs_rhs_type))
for op in OP_ARITHMETIC:
    INTERPRETER_EXPRESSIONS.append(ArithmeticExpression(op))
for op in OP_LOGICAL:
    for rhs_type in (Boolean, Code):
        INTERPRETER_EXPRESSIONS.append(LogicalExpression(op, rhs_type))

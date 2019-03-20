from sqf.types import Keyword
from sqf.expressions import BinaryExpression, UnaryExpression
from sqf.database import EXPRESSIONS

# keywords that are not commands, but part of the language
KEYWORDS = {'=', '\\'}

PREPROCESSORS_UNARY = {'#ifdef', '#ifndef', '#undef', '#include'}
PREPROCESSORS_NULLARY = {'#else', '#endif'}
PREPROCESSORS = {'#define'}.union(PREPROCESSORS_UNARY).union(PREPROCESSORS_NULLARY)

KEYWORDS = KEYWORDS.union(PREPROCESSORS)


NULARY_OPERATORS = set()
UNARY_OPERATORS = set()
BINARY_OPERATORS = set()

for expression in EXPRESSIONS:
    if isinstance(expression, BinaryExpression):
        op = expression.types_or_values[1]
        BINARY_OPERATORS.add(op.value.lower())
    elif isinstance(expression, UnaryExpression):
        op = expression.types_or_values[0]
        UNARY_OPERATORS.add(op.value.lower())
    else:
        op = expression.types_or_values[0]
        NULARY_OPERATORS.add(op)

    KEYWORDS.add(op.value.lower())


OP_ARITHMETIC = [Keyword(s) for s in ('+', '-', '*', '/', '%', 'mod', '^', 'max', 'floor')]

OP_LOGICAL = [Keyword(s) for s in ('&&', 'and', '||', 'or')]

OP_COMPARISON = [Keyword(s) for s in ('==', 'isequalto', '!=', '<', '>', '<=', '>=', '>>')]

NAMESPACES = {'missionnamespace', 'profilenamespace', 'uinamespace', 'parsingnamespace'}

# namespaces are parsed as such
KEYWORDS = KEYWORDS - NAMESPACES

UNARY_OPERATORS.union({'#ifdef', '#ifndef', '#include'})

from sqf.types import Keyword, Number, Array, Code, Type, Boolean, String, Namespace
from sqf.interpreter_types import WhileType, ForType, ForSpecType, SwitchType, IfType, ElseType, TryType, WithType
from sqf.expressions import BinaryExpression, UnaryExpression


class WhileExpression(UnaryExpression):
    """
    Catches `While {}` expression and stores it as a WhileType
    """
    def __init__(self):
        super().__init__(Keyword('while'), Code, WhileType, lambda v, i: v)


class WhileDoExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(WhileType, Keyword('do'), Code, None, action)


class ForSpecExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('for'), Array, ForSpecType, lambda v, i: v)


class ForSpecDoExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(ForSpecType, Keyword('do'), Code, None, action)


class ForExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('for'), String, ForType, lambda rhs, i: rhs)


class ForFromExpression(BinaryExpression):
    def __init__(self):
        super().__init__(ForType, Keyword('from'), Number, ForType,
                         lambda lhs, rhs, i: (lhs.variable, rhs))


class ForFromToExpression(BinaryExpression):
    def __init__(self):
        super().__init__(ForType, Keyword('to'), Number, ForType,
                         lambda lhs, rhs, i: (lhs.variable, lhs.from_, rhs))


class ForFromToStepExpression(BinaryExpression):
    def __init__(self):
        super().__init__(ForType, Keyword('step'), Number, ForType,
                         lambda lhs, rhs, i: (lhs.variable, lhs.from_, lhs.to, rhs))


class ForFromToDoExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(ForType, Keyword('do'), Code, None, action)


class ForEachExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(Code, Keyword('forEach'), Array, None, action)


class SwitchExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('switch'), Type, SwitchType, lambda v, i: (self.keyword, v))


class CaseExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('case'), Type, SwitchType, lambda v, i: (self.keyword, v))


class DefaultExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('default'), Type, SwitchType, lambda v, i: (self.keyword, v))


class SwitchDoExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(SwitchType, Keyword('do'), Code, None, action)


class IfExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('if'), Boolean, IfType, lambda v, i: v)


class IfThenExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(IfType, Keyword('then'), Code, None, action)


class ElseExpression(BinaryExpression):
    def __init__(self):
        super().__init__(Code, Keyword('else'), Code, ElseType, lambda lhs, rhs, i: (lhs, rhs))


class IfThenElseExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(IfType, Keyword('then'), ElseType, None, action)


class IfThenSpecExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(IfType, Keyword('then'), Array, None, action)


class IfThenExitWithExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(IfType, Keyword('exitwith'), Code, None, action)


class TryExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('try'), Code, TryType, lambda v, i: v)


class TryCatchExpression(BinaryExpression):
    def __init__(self, action=None):
        super().__init__(TryType, Keyword('catch'), Code, None, action)


class WithExpression(UnaryExpression):
    def __init__(self):
        super().__init__(Keyword('with'), Namespace, WithType, lambda v, i: v)


class WithDoExpression(BinaryExpression):
    def __init__(self, action=None):
        if action is None:
            action = lambda lhs, rhs, i: i.execute_code(rhs, namespace_name=lhs.namespace.value)
        super().__init__(WithType, Keyword('do'), Code, None, action)


COMMON_EXPRESSIONS = [
    CaseExpression(),
    DefaultExpression(),

    WithExpression(),
    WithDoExpression(),

    TryExpression(),
    TryCatchExpression(),

    ForEachExpression(),
    WhileExpression(),
    WhileDoExpression(),

    ForExpression(),
    ForFromExpression(),
    ForFromToExpression(),
    ForFromToStepExpression(),
    ForFromToDoExpression(),
    ForSpecExpression(),
    ForSpecDoExpression(),
    SwitchExpression(),
    SwitchDoExpression(),

    IfExpression(),
    ElseExpression(),
    IfThenSpecExpression(),
    IfThenElseExpression(),
    IfThenExpression(),
    IfThenExitWithExpression(),

    UnaryExpression(Keyword('params'), Array, Boolean, lambda rhs_v, i: i.add_params(rhs_v)),
    BinaryExpression(Type, Keyword('params'), Array, Boolean, lambda lhs_v, rhs_v, i: i.add_params(rhs_v, lhs_v)),

    UnaryExpression(Keyword('call'), Code, None, lambda rhs_v, i: i.execute_code(rhs_v)),
    BinaryExpression(Type, Keyword('call'), Code, None, lambda lhs_v, rhs_v, i: i.execute_code(rhs_v, extra_scope={"_this": lhs_v})),
]

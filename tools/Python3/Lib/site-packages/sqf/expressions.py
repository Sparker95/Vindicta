from sqf.types import Keyword, Nothing, Anything, Type
from sqf.interpreter_types import InterpreterType


class Expression:
    """
    A generic class to represent an expression. The expression matches according to the
    types of their elements, listed in `types`.
    """
    def __init__(self, types_or_values, return_type):
        self.types_or_values = tuple(types_or_values)
        self.return_type = return_type
        for t_or_v in self.types_or_values:
            assert (isinstance(t_or_v, (Type, Keyword)) or issubclass(t_or_v, Type))
        assert(return_type is None or issubclass(return_type, Type))

    def is_match(self, values, exact=True):
        """
        Given a list of values, returns a list of matches when the values
        match or not each condition of the expression
        """
        if len(values) != len(self.types_or_values):
            return False

        for i, (t_or_v, value) in enumerate(zip(self.types_or_values, values)):
            if isinstance(t_or_v, (Type, Keyword)):  # it is a value
                if value != t_or_v:
                    return False
            else:  # it is a type
                if not (isinstance(value, t_or_v) or
                            (not exact and type(value) == Anything and
                             not issubclass(t_or_v, InterpreterType))):
                    return False
        return True

    def is_signature_match(self, values):
        return self.is_match(values, exact=False)

    def execute(self, values, interpreter):
        raise NotImplementedError

    def __repr__(self):
        return '<%s %s>' % (self.__class__.__name__, self.types_or_values)

    def __eq__(self, other):
        if issubclass(other.__class__, Expression):
            return self.types_or_values == other.types_or_values
        else:
            return False

    @property
    def keyword(self):
        raise NotImplementedError

    def _result_to_typed_result(self, value):
        if self.return_type is None:
            return value
        elif self.return_type in (Anything, Nothing):
            return self.return_type()
        else:
            if isinstance(value, tuple):
                return self.return_type(*value)
            else:
                return self.return_type(value)


class UnaryExpression(Expression):
    def __init__(self, op, rhs_type, return_type, action=None):
        assert (isinstance(op, Keyword))
        super().__init__([op, rhs_type], return_type)
        if action is None and return_type is None:
            action = lambda rhs, i: i.private_default_class()
        elif action is None:
            action = lambda rhs, i: None
        self.action = action

    def execute(self, values, interpreter):
        result = self.action(values[1], interpreter)
        return self._result_to_typed_result(result)

    @property
    def keyword(self):
        return self.types_or_values[0]


class BinaryExpression(Expression):
    def __init__(self, lhs_type, op, rhs_type, return_type, action=None):
        assert(isinstance(op, Keyword))
        super().__init__([lhs_type, op, rhs_type], return_type)
        if action is None and return_type is None:
            action = lambda lhs, rhs, i: i.private_default_class()
        elif action is None:
            action = lambda lhs, rhs, i: None
        self.action = action

    def execute(self, values, interpreter):
        result = self.action(values[0], values[2], interpreter)
        return self._result_to_typed_result(result)

    @property
    def keyword(self):
        return self.types_or_values[1]


class NullExpression(Expression):
    def __init__(self, op, return_type, action=None):
        assert(isinstance(op, Keyword))
        assert(return_type is not None)
        super().__init__([op], return_type)
        if action is None:
            action = lambda i: None
        self.action = action

    def execute(self, values, interpreter):
        result = self.action(interpreter)
        return self._result_to_typed_result(result)

    @property
    def keyword(self):
        return self.types_or_values[0]

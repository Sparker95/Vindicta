from sqf.types import Code, String, Number, Array, Type, Variable, Boolean, Namespace, _Statement, Nothing, Statement


class InterpreterType(Type):
    # type that is used by the interpreter (e.g. While type)
    pass


class _InterpreterType(InterpreterType):
    def __init__(self, token):
        assert (isinstance(token, Type))
        super().__init__()
        self.token = token

    @property
    def is_undefined(self):
        return self.token.is_undefined


class PrivateType(_InterpreterType):
    """
    A type to store the result of "private _x" as in "private _x = 2"
    """
    def __init__(self, variable):
        assert(isinstance(variable, Variable))
        super().__init__(variable)

    @property
    def variable(self):
        return self.token


class WhileType(_InterpreterType):
    def __init__(self, condition):
        assert(isinstance(condition, Code))
        super().__init__(condition)

    @property
    def condition(self):
        return self.token


class ForType(_InterpreterType):
    def __init__(self, variable=None, from_=None, to=None, step=None):
        if step is None:
            step = Number(1)
        if variable is None:
            variable = String()
        assert (variable is None or isinstance(variable, String))
        assert (from_ is None or isinstance(from_, Type))
        assert (to is None or isinstance(to, Type))
        assert (isinstance(step, Type))
        super().__init__(variable)
        self.from_ = from_
        self.to = to
        self.step = step

    @property
    def variable(self):
        return self.token

    @property
    def is_undefined(self):
        return self.variable.is_undefined or \
               self.from_ is not None and self.from_.is_undefined or \
               self.to is not None and self.to.is_undefined

    def copy(self, other):
        self.token = other.variable
        self.from_ = other.from_
        self.to = other.to
        self.step = other.step


class ForSpecType(_InterpreterType):
    def __init__(self, array):
        assert (isinstance(array, Array))
        super().__init__(array)

    @property
    def array(self):
        return self.token


class SwitchType(_InterpreterType):
    def __init__(self, keyword, result):
        super().__init__(result)
        self.keyword = keyword

    @property
    def result(self):
        return self.token


class IfType(_InterpreterType):
    def __init__(self, condition=None):
        if condition is None:
            condition = Boolean()
        super().__init__(condition)

    @property
    def condition(self):
        return self.token


class ElseType(_InterpreterType):
    def __init__(self, then=None, else_=None):
        super().__init__(then)
        if then is None:
            condition = Boolean()
        assert (isinstance(then, Code))
        assert (isinstance(else_, Code))
        self.else_ = else_

    @property
    def then(self):
        return self.token

    @property
    def is_undefined(self):
        return self.else_.is_undefined or self.then.is_undefined


class TryType(_InterpreterType):
    def __init__(self, code):
        assert (isinstance(code, Code))
        super().__init__(code)


class WithType(_InterpreterType):
    def __init__(self, namespace):
        assert (isinstance(namespace, Namespace))
        super().__init__(namespace)

    @property
    def namespace(self):
        return self.token


class DefineStatement(_Statement, InterpreterType):
    def __init__(self, tokens, variable_name, expression=None, args=None):
        assert(isinstance(variable_name, str))
        assert(isinstance(tokens, list))
        super().__init__(tokens)
        self.variable_name = variable_name
        if expression is None:
            expression = [Nothing()]
        self.expression = expression
        if args is None:
            args = []
        self.args = args

    def __repr__(self):
        return '#d<%s>' % self._as_str(repr)


class IfDefStatement(_Statement, InterpreterType):

    def __init__(self, tokens, statement_class=Statement):
        super().__init__(tokens)
        self.statement_class = statement_class

    def __repr__(self):
        return '#i<%s>' % self._as_str(repr)


class DefineResult(_Statement, InterpreterType):
    """
    A statement whose some token was replaced by a #define.
    The statement contain the original tokens, but also what define_statement was used,
    and what was the resulting statement after replacement.

    str(self) still returns the original tokens, but `result` can be used to evaluate the statement.
    """
    def __init__(self, tokens, define_statement, result):
        super().__init__(tokens)
        self.define_statement = define_statement
        assert (isinstance(result, (Type, Statement)))
        self.result = result

    def __repr__(self):
        return '#dR|%s -> %s|' % (self.tokens, (''.join('%s' % self.result)).replace('\n', '\\n'))


class IfDefResult(_Statement, InterpreterType):
    def __init__(self, ifdef_statement, result):
        super().__init__(ifdef_statement.tokens)
        self.ifdef_statement = ifdef_statement
        assert(isinstance(result, list))
        self.result = result  # a list of statements

    def __repr__(self):
        return '#iR|%s -> %s|' % (self.tokens, (''.join('%s' % self.result)).replace('\n', '\\n'))

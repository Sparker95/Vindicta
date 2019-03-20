from sqf.parser_types import ParserKeyword
from sqf.base_type import BaseType, ParserType, BaseTypeContainer


class Type(BaseType):
    """
    A type represents a type of variable. Every quantity that has a value is a type.
    """
    @property
    def is_undefined(self):
        """
        Represents whether its value is defined or not.
        """
        return self.value is None

    @property
    def value(self):
        return None


class ConstantValue(Type):
    """
    A constant (literal) value. For example, a number, a string, code.
    """
    def __init__(self, value=None):
        super().__init__()
        self._value = value

    @property
    def value(self):
        return self._value

    def __str__(self):
        return self.__class__.__name__


class Boolean(ConstantValue):
    def __init__(self, value=None):
        assert (value in (None, True, False))
        super().__init__(value)

    def __str__(self):
        if self.is_undefined:
            return 'undefined'
        if self._value:
            return 'true'
        else:
            return 'false'

    def __repr__(self):
        return 'B<%s>' % self


class String(ConstantValue):

    def __init__(self, value=None):
        self.container = None
        if value is not None:
            assert(isinstance(value, str))
            assert(value[0] == value[-1])
            assert (value[0] in ["'", '"'])
            self.container = value[0]
            super().__init__(value[1:-1])
        else:
            super().__init__(value)

    def __str__(self):
        if self.is_undefined:
            return "undefined"
        return "%s%s%s" % (self.container, self.value, self.container)

    def __repr__(self):
        return 's<%s>' % self


class Nothing(ConstantValue):
    """
    A type of unknown type
    """
    def __str__(self):
        return 'Nothing'

    def __repr__(self):
        return '<%s>' % self


class Anything(Type):
    """
    A type of unknown type
    """
    def __repr__(self):
        return '<Anything>'


class Number(ConstantValue):
    def __init__(self, value=None):
        assert(value is None or isinstance(value, (int, float)))
        super().__init__(value)

    def __str__(self):
        if self.is_undefined:
            return "undefined"
        if isinstance(self._value, int):
            return '%d' % self._value
        # todo: use a better representation of float
        return '%2.2f' % self._value

    def __repr__(self):
        return 'N%s' % self


class Variable(Type):
    """
    A variable that holds values. It has a name (e.g. "_x").
    """
    def __init__(self, name):
        super().__init__()
        self._name = name

    @property
    def name(self):
        return self._name

    @property
    def is_undefined(self):
        return False

    @property
    def is_global(self):
        return self.name[0] != '_'

    def __str__(self):
        return self._name

    def __repr__(self):
        return 'V<%s>' % self


class _Statement(BaseTypeContainer):
    def __init__(self, tokens, parenthesis=None, ending=None):
        assert (ending in (None, ',', ';'))
        assert (parenthesis in (None, '()', '[]', '{}'))
        assert (isinstance(tokens, list))
        for i, s in enumerate(tokens):
            assert(isinstance(s, (Type, Keyword, Preprocessor, Statement, ParserType)))

        self._parenthesis = parenthesis

        if self._parenthesis:
            tokens = [ParserKeyword(parenthesis[0])] + tokens + [ParserKeyword(parenthesis[1])]

        super().__init__(tokens)
        self._ending = None
        self.ending = ending

    def prepend(self, tokens):
        assert (isinstance(tokens, list))
        for i, s in enumerate(tokens):
            assert (isinstance(s, (Type, Keyword, Preprocessor, Statement, ParserType)))
        self._tokens = tokens + self._tokens

    @property
    def content(self):
        tokens = self.tokens.copy()
        if self.ending:
            del tokens[-1]
        if self.parenthesis:
            return tokens[1:-1]
        return tokens

    @staticmethod
    def is_base_token(token):
        # ignore tokens that are not relevant for the interpreter
        return not (isinstance(token, ParserType) or
                    isinstance(token, _Statement) and not token.parenthesis and not token.base_tokens)

    @property
    def ending(self):
        return self._ending

    @ending.setter
    def ending(self, ending):
        assert(ending in (None, ';', ','))
        if self._ending is not None:
            del self._tokens[-1]
        if ending is not None:
            self._tokens.append(ParserKeyword(ending))
        self._ending = ending

    def __len__(self):
        return len(self._tokens)

    def __getitem__(self, other):
        return self._tokens[other]

    def _as_str(self, func=str):
        return ''.join(func(item) for item in self._tokens)

    @property
    def parenthesis(self):
        return self._parenthesis


class Array(Type, BaseTypeContainer):

    def __init__(self, tokens=None):
        Type.__init__(self)
        if tokens is not None:
            self._values = tokens
        else:
            self._values = None
            tokens = []
        BaseTypeContainer.__init__(self, tokens)
        self.update_tokens()

    def update_tokens(self):
        self._tokens = [ParserKeyword('[')] + list(self._with_commas()) + [ParserKeyword(']')]

    def _with_commas(self):
        if self._values in [None, []]:
            return []
        it = iter(self._values)
        yield next(it)
        for x in it:
            yield ParserKeyword(',')
            yield x

    @property
    def is_undefined(self):
        return self._values is None

    def _as_str(self, func=str):
        if self.is_undefined:
            return '[undefined]'
        return ''.join(func(item) for item in self._tokens)

    def __len__(self):
        assert(not self.is_undefined)
        return len(self._values)

    def __getitem__(self, other):
        assert(not self.is_undefined)
        return self._values[other]

    @property
    def value(self):
        return self._values

    def __repr__(self):
        return '%s' % self._as_str(repr)

    def extend(self, index):
        assert (not self.is_undefined)
        new_tokens = [Nothing()] * (index - len(self._values) + 1)
        self._values += new_tokens
        self.update_tokens()

    def append(self, token):
        assert (not self.is_undefined)
        self._values.append(token)
        self.update_tokens()

    def resize(self, count):
        assert (not self.is_undefined)
        if count > len(self._values):
            self.extend(count - 1)
        else:
            self._values = self._values[:count]
            self.update_tokens()

    def reverse(self):
        assert (not self.is_undefined)
        self._values.reverse()
        self.update_tokens()

    def add(self, other):
        assert (not self.is_undefined)
        self._values += other
        self.update_tokens()

    def set(self, rhs_v):
        assert (not self.is_undefined)
        # https://community.bistudio.com/wiki/set
        assert(isinstance(rhs_v, Array))
        index = rhs_v.value[0].value
        value = rhs_v.value[1]

        if index >= len(self._values):
            self.extend(index)
        self._values[index] = value
        self.update_tokens()


class Statement(_Statement, BaseType):
    """
    The main class for holding statements. It is a BaseType because it can be nested, and
    it is a _Statement because it can hold elements.
    """
    def __init__(self, tokens, parenthesis=False, ending=None):
        if parenthesis:
            parenthesis = '()'
        else:
            parenthesis = None
        super().__init__(tokens, parenthesis, ending)

    def __repr__(self):
        return 'S<%s>' % self._as_str(repr)


class Code(_Statement, Type):
    """
    The class that holds (non-interpreted) code.
    """
    def __init__(self, tokens=None):
        Type.__init__(self)
        if tokens is not None:
            self._undefined = False
        else:
            self._undefined = True
            tokens = []
        _Statement.__init__(self, tokens, parenthesis='{}')

    @property
    def is_undefined(self):
        return self._undefined

    def __repr__(self):
        return '%s' % self._as_str(repr)


class Keyword(BaseType):
    def __init__(self, token):
        assert isinstance(token, str)
        super().__init__()
        self._token = token
        self._unique_token = self._token.lower()

    @property
    def value(self):
        return self._token

    @property
    def unique_token(self):
        return self._unique_token

    def __str__(self):
        return self._token

    def __repr__(self):
        return 'K<%s>' % self._token

    @property
    def _key(self):
        return self._unique_token,


class Namespace(Type):
    def __init__(self, token):
        assert isinstance(token, str)
        super().__init__()
        self._token = token
        self._unique_token = token.lower()

    @property
    def value(self):
        return self._token

    def __repr__(self):
        return 'NS<%s>' % self._token

    def __str__(self):
        return self._token

    @property
    def _key(self):
        return self._unique_token,


class Config(ConstantValue):
    pass


class Object(ConstantValue):
    pass


class File(Code):
    """
    Like code, but without parenthesis
    """
    def __init__(self, tokens):
        _Statement.__init__(self, tokens)

    def __repr__(self):
        return 'F<%s>' % self._as_str(repr)


class Preprocessor(Keyword):
    pass


class Script(ConstantValue):
    pass


class Control(ConstantValue):
    pass


class Group(ConstantValue):
    pass


class Display(ConstantValue):
    pass


class Side(ConstantValue):
    pass


class Task(ConstantValue):
    pass


class Location(ConstantValue):
    pass


class NetObject(ConstantValue):
    pass


class DiaryReport(ConstantValue):
    pass


class TeamMember(ConstantValue):
    pass

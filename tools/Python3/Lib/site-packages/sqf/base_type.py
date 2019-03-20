

def get_coord(string):
    lines = string.split('\n')
    line = len(lines)
    column = len(lines[-1]) + 1
    return line, column
assert(get_coord('aa') == (1, 3))


def get_all_tokens(nested_tokens):
    tokens = []
    for token in nested_tokens:
        if isinstance(token, BaseTypeContainer):
            tokens += get_all_tokens(token.tokens)
        else:
            tokens.append(token)
    return tokens


def get_diff(string):
    lines = string.split('\n')
    line = len(lines) - 1
    column = len(lines[-1])
    return line, column
assert(get_diff('') == (0, 0))
assert(get_diff('aa') == (0, 2))
assert(get_diff('aa\n') == (1, 0))
assert(get_diff('aa\na') == (1, 1))


class BaseType:
    """
    This class is used to count the string-coordinate (line, column) of any element in a statement.
    This is used for identifying, in a script, the line and column of an error.
    It also defines the __eq__
    """
    def __init__(self):
        self._position = None

    @property
    def _key(self):
        # idiom described in https://stackoverflow.com/a/2909119/931303
        return tuple(x for x in sorted(self.__dict__.items()) if x[0] != '_position')

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self._key == other._key

    def __ne__(self, other):
        return not self.__eq__(other)

    def __hash__(self):
        return hash(self._key)

    def set_position(self, position):
        assert (isinstance(position, tuple))
        assert (len(position) == 2)
        self._position = position

    @property
    def undefined_position(self):
        return self._position is None

    @property
    def position(self):
        if self.undefined_position:
            raise Exception(self, type(self))
        return self._position

    @position.setter
    def position(self, position):
        self.set_position(position)


class ParserType(BaseType):
    # base type ignored by the interpreter
    pass


class BaseTypeContainer(BaseType):
    """
    This is the base class for containers (e.g. statements, code).

    Relevant of this class:
        * `base_tokens` to get tokens that have functionality.
        * `string_up_to`: the string representation of this class up to an index.
    """
    def __init__(self, tokens):
        super().__init__()
        for i, s in enumerate(tokens):
            assert(isinstance(s, BaseType))
        self._tokens = tokens

    @staticmethod
    def is_base_token(token):
        raise NotImplementedError

    def _as_str(self, func=str):
        raise NotImplementedError

    def set_position(self, position):
        self._position = position
        for token in self._tokens:
            token.set_position(position)

            token_delta = get_diff(str(token))

            if token_delta[0] == 0:
                initial_column = position[1]
            else:
                initial_column = 1

            position = (
                position[0] + token_delta[0],
                initial_column + token_delta[1]
            )

    @BaseType.position.setter
    def position(self, position):
        super().set_position(position)

    @property
    def tokens(self):
        return self._tokens

    def get_all_tokens(self):
        return get_all_tokens(self.tokens)

    @property
    def base_tokens(self):
        return [token for token in self._tokens if self.is_base_token(token)]

    def __str__(self):
        return self._as_str()

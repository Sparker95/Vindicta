from sqf.base_type import ParserType
from sqf.keywords import BINARY_OPERATORS, UNARY_OPERATORS, OP_COMPARISON, PREPROCESSORS_UNARY


class EndToken:
    pass


def _normalize(item):
    return str(item).lower()


def nud(token, parser):
    n_token = _normalize(token)
    if n_token in UNARY_OPERATORS:
        return parser.container([token, parser.expression(100)])
    elif str(token) in PREPROCESSORS_UNARY:
        return parser.container([token, parser.expression(100)])
    elif str(token) == '#define':
        arg = parser.expression(100)
        args = parser.expression(100)
        func = parser.expression(100)
        return parser.container([token, arg, args, func])
    elif str(token).isupper():
        # heuristic to catch global defines with arguments
        if str(parser.next)[0] == '(':
            return parser.container([token, parser.expression(100)])
    return token


def get_lbp(token):
    n_token = _normalize(token)

    if token == EndToken:
        return 0
    elif n_token == '=':
        return 0.8
    elif n_token == 'private':
        return 0.9
    elif n_token in ('||', 'or'):
        return 1
    elif n_token in {'&&', 'and'}:
        return 2
    elif n_token in set(x.value for x in OP_COMPARISON):
        return 3
    elif n_token in {'*', '/', '%', 'mod', 'atan2'}:
        return 7
    elif n_token in {'+', 'max', 'min', '-'}:
        return 6
    elif n_token == 'else':
        return 5
    elif n_token in BINARY_OPERATORS:
        return 4
    elif n_token in UNARY_OPERATORS:
        return 9
    else:
        return 0.1


class Parser:

    def __init__(self, container):
        self.next = None
        self.container = container
        self.tokens = []
        self.cumulator = []
        self.iterator = self._iterator()

    def _iterator(self):
        for token in self.tokens:
            if isinstance(token, ParserType):
                self.cumulator.append(token)
            else:
                yield token
        yield EndToken

    def expression(self, rbp=0):
        current = self.next

        cum_prefix = self.cumulator
        self.cumulator = []

        try:
            self.next = next(self.iterator)
        except StopIteration:
            if len(cum_prefix + self.cumulator) == 1:
                return (cum_prefix + self.cumulator)[0]
            return self.container(cum_prefix + self.cumulator)

        left = nud(current, self)
        if cum_prefix + self.cumulator:
            left = self.container(cum_prefix + [left] + self.cumulator)
            self.cumulator = []

        while rbp < get_lbp(self.next):
            current = self.next
            self.next = next(self.iterator)
            if self.next is EndToken:
                return self.container([left, current])
            right = self.expression(get_lbp(current))
            left = self.container([left, current, right])

        return left

    def parse(self, tokens):
        if len(tokens) == 1:
            return tokens[0]
        self.tokens = tokens
        self.iterator = self._iterator()
        self.next = next(self.iterator)
        return self.expression()


def parse_exp(tokens, container=list):
    return Parser(container).parse(tokens)

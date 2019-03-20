from sqf.base_type import ParserType


class Comment(ParserType):

    def __init__(self, string):
        super().__init__()
        assert (string.startswith('/*') or string.startswith('//'))
        self._string = string

    def __str__(self):
        return self._string

    def __repr__(self):
        return ('C(%s)' % self).replace('\r\n', r'\r\n').replace('\n', r'\n')


class Space(ParserType):
    def __str__(self):
        return ' '

    def __repr__(self):
        return '\' \''


class Tab(ParserType):
    def __str__(self):
        return '\t'

    def __repr__(self):
        return '\\t'


class EndOfLine(ParserType):
    def __init__(self, value):
        super().__init__()
        assert(value in ['\n', '\r\n'])
        self.value = value

    def __str__(self):
        return self.value

    def __repr__(self):
        return '<EOL>'


class BrokenEndOfLine(ParserType):
    def __str__(self):
        return '\\\n'

    def __repr__(self):
        return '<\EOL>'


class EndOfFile(ParserType):
    def __str__(self):
        return ''

    def __repr__(self):
        return '<\EOF>'


class ParserKeyword(ParserType):
    def __init__(self, value):
        super().__init__()
        self.value = value

    def __str__(self):
        return self.value

    def __repr__(self):
        return self.value

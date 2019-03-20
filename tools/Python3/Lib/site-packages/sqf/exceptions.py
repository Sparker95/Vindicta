class SQFError(Exception):
    """
    Raised by the parser and analyzer
    """
    def __init__(self, position, message):
        assert(isinstance(position, tuple))
        self.position = position
        self.message = message.replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r")


class SQFParserError(SQFError):
    """
    Raised by the parser and analyzer
    """
    def __init__(self, position, message):
        super().__init__(position, "error:%s" % message)


class SQFParenthesisError(SQFParserError):
    pass


class SQFWarning(SQFError):
    """
    Something that the interpreter understands but that is a bad practice or potentially
    semantically incorrect.
    """
    def __init__(self, position, message):
        super().__init__(position, "warning:%s" % message)

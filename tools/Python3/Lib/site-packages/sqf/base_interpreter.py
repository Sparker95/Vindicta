from sqf.types import Statement, Code, Nothing, Anything, Variable, Array, String, Type, File
from sqf.keywords import Keyword
from sqf.exceptions import SQFParserError, SQFWarning
import sqf.namespace


class BaseInterpreter:
    """
    Base Interpreter used by the analyzer and interpreter
    """
    private_default_class = Anything

    def __init__(self, all_vars=None):
        self._namespaces = {
            'uinamespace': sqf.namespace.Namespace('uinamespace'),
            'parsingnamespace': sqf.namespace.Namespace('parsingnamespace'),
            'missionnamespace': sqf.namespace.Namespace('missionnamespace', all_vars),
            'profilenamespace': sqf.namespace.Namespace('profilenamespace')
        }

        self.current_namespace = self.namespace('missionnamespace')

    def exception(self, exception):
        """
        We can overwrite this method to handle exceptions differently
        """
        raise exception

    def set_global_variable(self, var_name, value):
        assert(isinstance(value, Type))
        self.namespace('missionNamespace').base_scope[var_name] = value

    def namespace(self, name):
        return self._namespaces[name.lower()]

    @property
    def current_scope(self):
        return self.current_namespace.current_scope

    def __getitem__(self, name):
        try:
            return self.get_scope(name)[name]
        except KeyError:
            return self.private_default_class()

    def __contains__(self, name):
        return name in self.get_scope(name)

    def _parse_params_args(self, arguments, base_token):
        """
        How param argument should be interpreted when it is not an array nor Nothing
        """
        return [arguments]

    def _add_params(self, token):
        self.add_privates([token[0]])

    def add_params(self, base_token, arguments=None):
        assert (isinstance(base_token, Array))

        if arguments is None or isinstance(arguments, Nothing):
            arguments = self['_this']
        if isinstance(arguments, Array) and not arguments.is_undefined:
            arguments = arguments.value
        else:
            arguments = self._parse_params_args(arguments, base_token)

        if len(arguments) > len(base_token):
            self.exception(
                SQFWarning(base_token.position,
                           '`params` lhs (%d elements) is larger than rhs (%d elements).'
                           ' Some arguments are ignored.' % (len(arguments), len(base_token))))

        for i, token in enumerate(base_token):
            if isinstance(token, String):
                if token.value == '':
                    continue
                self.add_privates([token])
                if i >= len(arguments):
                    self.exception(SQFWarning(token.position,
                                   '`params` mandatory argument %s is missing in rhs' % token))
                else:
                    self.current_scope[token.value] = arguments[i]
            elif isinstance(token, Array):
                if len(token) in (2, 3, 4):
                    if i < len(arguments) and not isinstance(arguments[i], Nothing):
                        argument = arguments[i]
                    else:
                        argument = token[1]

                    self._add_params(token)
                    self.current_scope[token[0].value] = argument
                else:
                    self.exception(
                        SQFParserError(base_token.position, '`params` array element must have 2-4 elements'))
            else:
                self.exception(SQFParserError(base_token.position, '`params` array element must be a string or array'))
        return True

    def value(self, token, namespace_name=None):
        if isinstance(token, Statement):
            return self.value(self.execute_single(statement=token))
        elif isinstance(token, Variable):
            scope = self.get_scope(token.name, namespace_name)
            try:
                value = scope[token.name]
            except KeyError:
                value = self.private_default_class()
            assert isinstance(value, Type)
            return value
        elif isinstance(token, (Type, Keyword)):
            return token
        else:
            raise NotImplementedError(repr(token))

    def get_variable(self, token):
        if isinstance(token, Statement):
            return self.get_variable(token.base_tokens[0])
        else:
            if not isinstance(token, Variable):
                return Nothing()
            return token

    def execute_token(self, token):
        """
        Given a single token, recursively evaluate it and return its value.
        """
        raise NotImplementedError

    def get_scope(self, name, namespace_name=None):
        if namespace_name is None:
            namespace = self.current_namespace
        else:
            namespace = self.namespace(namespace_name)
        return namespace.get_scope(name)

    def _add_private(self, variable):
        assert isinstance(variable, String)
        self.current_scope[variable.value] = Nothing()

    def add_privates(self, variables):
        """
        Privatizes a list of variables by initializing them on the scope (as Nothing).
        """
        for variable in variables:
            if not isinstance(variable, String):
                self.exception(SQFParserError(variable.position, 'Variable in private must be a string (is %s)' % type(variable)))
                continue

            if not variable.value.startswith('_'):
                self.exception(SQFParserError(variable.position, 'Cannot make global variable "%s" private (underscore missing?)' % variable.value))
                continue
            self._add_private(variable)

    def execute_other(self, statement):
        pass

    def execute_code(self, code, extra_scope=None, namespace_name='missionnamespace'):
        assert (isinstance(code, Code))

        # store the old namespace
        _previous_namespace = self.current_namespace

        # store the executing namespace
        namespace = self.namespace(namespace_name)
        # change to the executing namespace
        self.current_namespace = namespace

        if extra_scope is None:
            extra_scope = {}
        namespace.add_scope(extra_scope)

        # execute the code
        outcome = self.private_default_class()
        outcome.position = code.position
        for statement in code.base_tokens:
            token = self.execute_token(statement)
            if isinstance(token, tuple):
                token = token[0]
            outcome = self.value(token)

        # cleanup
        if not isinstance(code, File):  # so we have access to its scope
            # this has to be the executing namespace because "self.current_namespace" may change
            namespace.del_scope()
        self.current_namespace = _previous_namespace
        return outcome

    def execute_single(self, statement):
        """
        Executes a statement
        """
        raise NotImplementedError

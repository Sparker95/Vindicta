class Scope:
    """
    A scope is a dictionary that stores variables. Its level is controlled by a namespace
    and has no function to the scope itself.
    The values are case insensitive because SQF variables are case-insensitive.
    """
    def __init__(self, level, values=None):
        if values is None:
            values = {}
        self.values = {self.normalize(key): values[key] for key in values}
        self.level = level

    def __contains__(self, name):
        return self.normalize(name) in self.values

    def __getitem__(self, name):
        return self.values[self.normalize(name)]

    def __setitem__(self, name, value):
        self.values[self.normalize(name)] = value

    @staticmethod
    def normalize(name):
        return name.lower()


class Namespace:
    def __init__(self, name, all_vars=None):
        self._stack = [Scope(0, all_vars)]
        self.name = name

    def __repr__(self):
        return '<Namespace %s>' % self.name

    def __getitem__(self, name):
        return self.get_scope(name)[name]

    def __contains__(self, name):
        return name.lower() in self.get_scope(name)

    @property
    def current_scope(self):
        return self._stack[-1]

    @property
    def base_scope(self):
        return self._stack[0]

    def get_scope(self, name):
        if name.startswith('_'):
            for i in reversed(range(1, len(self._stack))):
                scope = self._stack[i]
                if name in scope:
                    return scope
            return self._stack[0]
        else:
            return self._stack[0]

    def add_scope(self, values=None):
        self._stack.append(Scope(len(self._stack), values))

    def del_scope(self):
        del self._stack[-1]

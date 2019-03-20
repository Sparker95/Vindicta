from sqf.interpreter import Interpreter, interpret
from sqf.types import Code, Array, String


class Client:
    def __init__(self, simulation):
        self._simulation = simulation
        self._interpreter = Interpreter()
        self._interpreter.client = self
        self._listening_variables = {}  # var_name: code

    @property
    def simulation(self):
        return self._simulation

    def add_listening(self, var_name, code):
        assert(isinstance(var_name, str) and isinstance(code, Code))
        self._listening_variables[var_name] = code

    def execute(self, code):
        interpret(code, self._interpreter)

    def set_variable(self, var_name, value, broadcast=True):
        self._interpreter.set_global_variable(var_name, value)

        if broadcast:
            if var_name in self._listening_variables:
                self._interpreter.execute_code(self._listening_variables[var_name],
                                               extra_scope={'_this': Array([String('"'+var_name+'"'), value])})

    @property
    def is_server(self):
        return self._simulation.server == self

    @property
    def is_dedicated(self):
        return self._simulation.is_dedicated


class Simulation:

    def __init__(self, is_dedicated=True):
        self._is_dedicated = is_dedicated
        self.server = Client(self)
        self._clients = []

        self._broadcasted = {}

    @property
    def is_dedicated(self):
        return self._is_dedicated

    @property
    def clients(self):
        return self._clients

    def add_client(self, client):
        assert self._is_dedicated

        self._clients.append(client)

        for var_name in self._broadcasted:
            client.set_variable(var_name, self._broadcasted[var_name], broadcast=False)

        return len(self._clients) - 1

    def broadcast(self, var_name, value, client_id=None):
        # client_id=None => to all
        # client_id=-1 => to the server
        if client_id is None:
            self._broadcasted[var_name] = value
            for client in self._clients + [self.server]:
                client.set_variable(var_name, value)
        elif client_id == -1:
            self.server.set_variable(var_name, value)
        else:
            self._clients[client_id].set_variable(var_name, value)

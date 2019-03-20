import collections

from sqf.types import Keyword


def get_keyword(types_or_values):
    try:
        return next(x.unique_token for x in types_or_values if isinstance(x, Keyword))
    except StopIteration:
        return None


def get_key(types_or_values):
    keyword = get_keyword(types_or_values)
    return keyword, len(types_or_values)


def build_database(expressions):
    database = collections.defaultdict(set)
    for i, exp in enumerate(expressions):
        key = get_key(exp.types_or_values)
        database[key].add(i)

    return database


def values_to_expressions(values, database, expressions):
    key = get_key(values)
    return [expressions[i] for i in database[key]]

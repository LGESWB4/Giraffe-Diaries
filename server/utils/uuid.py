import uuid

def make_uuid():
    return str(uuid.uuid4())

def make_uuid_with_prefix(prefix: str):
    return prefix + "-" + str(uuid.uuid4())

def make_uuid_with_prefix_and_suffix(prefix: str, suffix: str):
    return prefix + "-" + str(uuid.uuid4()) + suffix

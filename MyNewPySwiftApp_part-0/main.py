
def get_string() -> str:
    return "hello from python"
        
def get_string2() -> str:
    return "another string from python"


def multi_func(a, b):
    return a * b

def kw_func(**kw):
    print(kw)



class PyClass:

    def __init__(self, value):
        self.value = value
        
    def multi_func(self, a):
        return a * self.value

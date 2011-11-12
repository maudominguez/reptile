class ObjectSpace (object):

    def __init__(self, classSymbol):
        self.classSymbol = classSymbol
        self.fields = [None] * self.classSymbol.countInstVars()

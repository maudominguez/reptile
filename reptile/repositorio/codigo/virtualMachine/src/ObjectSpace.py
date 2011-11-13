from DefaultValues import *

class ObjectSpace (object):

    def __init__(self, classSymbol):
        self.classSymbol = classSymbol
        self.fields = [None] * self.classSymbol.countInstVars()
        self.initializeFields()

    def initializeFields(self):
        types = self.classSymbol.instVarsTypesList
        for i in range(len(types)):
            self.fields[i] = defaultValues(types[i])

from DefaultValues import *

class Frame (object):
    def __init__(self, methodSymbol, returnAddress):
        self.methodSymbol = methodSymbol
        self.returnAddress = returnAddress
        self.registers = [None] * self.methodSymbol.totalOfVars
        self.tempReturned = -1
        self.initializeVars()

    def initializeVars(self):
        types = self.methodSymbol.localVarsTypesList
        registerOfTheFirstLocal = self.methodSymbol.registerOfTheFirstLocal
        for i in range(len(types)):
            idxToInitialize = registerOfTheFirstLocal + i
            self.registers[idxToInitialize] = defaultValues(types[i])

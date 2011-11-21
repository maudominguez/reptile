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

        idxToInitialize = registerOfTheFirstLocal
        for i in range(len(types)):
            line = types[i].split()
            if(line[0] == "array"):
                parameterizedType = line[1]
                size = int(line[2])
                defaultValue = defaultValues(parameterizedType)
                for arrIdx in range(size):
                    self.registers[idxToInitialize] = defaultValue
                    idxToInitialize += 1

            else:
                self.registers[idxToInitialize] = defaultValues(line[0])
                idxToInitialize += 1


        """
        for i in range(len(types)):
            idxToInitialize = registerOfTheFirstLocal + i
            self.registers[idxToInitialize] = defaultValues(types[i])
        """
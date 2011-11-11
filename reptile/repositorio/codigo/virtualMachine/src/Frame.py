class Frame (object):
    def __init__(self, methodSymbol, returnAddress):
        self.methodSymbol = methodSymbol
        self.returnAddress = returnAddress
        self.registers = [None] * self.methodSymbol.totalOfVars
        self.tempReturned = -1
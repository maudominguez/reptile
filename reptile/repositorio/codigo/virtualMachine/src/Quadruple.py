class Quadruple (object):
    def __init__(self, opCode, op1 = None, op2 = None, op3 = None):
        self.opCode = opCode
        self.op1 = op1
        self.op2 = op2
        self.op3 = op3

    def __str__(self):
        res = self.opCode
        if(self.op1 is not None):
            res += " " + self.op1
        if(self.op2 is not None):
            res += " " + self.op2
        if(self.op3 is not None):
            res += " " + self.op3
        return res

        
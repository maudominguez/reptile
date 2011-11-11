from ClassSymbol import *
from MethodSymbol import *
from StackFrame import *
from Quadruple import *

class RVM (object):

    def __init__(self):
        self.classesDirectory = {}
        self.methodsDirectory = {}
        self.code = [] #list of quadruples
        self.startQuadruple = -1
        self.framesStack = [] #stack of frames
        self.framePointer = -1 #idx of current frame in framesStack

    def cpu(self):
        print("in cpu")
        
        

    def loadQuadruplesFromFile(self, inFile):
        nQuadruples = int(inFile.readline())
        for iQuad in range(nQuadruples):
            quadElems = inFile.readline().split()
            quadruple = Quadruple(quadElems[0])
            if(len(quadElems) >= 2):
                quadruple.op1 = quadElems[1]
            if(len(quadElems) >= 3):
                quadruple.op2 = quadElems[2]
            if(len(quadElems) >= 4):
                quadruple.op3 = quadElems[3]
            self.code.append(quadruple)

        

    def loadDirectoriesFromFile(self, inFile):
       
        self.startQuadruple = int(inFile.readline())
        nClasses = int(inFile.readline())

        for iClass in range(nClasses):
            className = inFile.readline().rstrip()
            classSymbol = ClassSymbol(className)
            nInstanceVars = int(inFile.readline().rstrip())
            if(nInstanceVars > 0):
                typesList = inFile.readline().split()
                for type in typesList:
                    classSymbol.addInstanceVarType(type)
            self.classesDirectory[classSymbol.name] = classSymbol

            nMethods = int(inFile.readline().rstrip())
            for iMethod in range(nMethods):
                methodName = inFile.readline().rstrip()

                totalOfVars = int(inFile.readline().rstrip())
                numberOfLocalVars = int(inFile.readline().rstrip())
                methodSymbol = MethodSymbol(methodName, totalOfVars, numberOfLocalVars)
                if(numberOfLocalVars > 0):
                    registerOfTheFirstLocal = int(inFile.readline().rstrip())
                    methodSymbol.registerOfTheFirstLocal = registerOfTheFirstLocal

                for x in range(numberOfLocalVars):
                    type = inFile.readline().rstrip()
                    methodSymbol.addLocalVarType(type)

                self.methodsDirectory[methodSymbol.name] = methodSymbol

    def printCode(self):
        for quadruple in self.code:
            print(quadruple)

    def printClassesDirectory(self):
        for key in self.classesDirectory:
            print(self.classesDirectory[key])

    def printMethodsDirectory(self):
        for key in self.methodsDirectory:
            print(self.methodsDirectory[key])

    def loadCodeFile(self):
        inFile = open ("code.txt", "r")
        self.loadDirectoriesFromFile(inFile)
        self.loadQuadruplesFromFile(inFile)
        inFile.close()


def main():
    virtualMachine = RVM()
    virtualMachine.loadCodeFile()
    virtualMachine.printClassesDirectory()
    virtualMachine.printMethodsDirectory()
    virtualMachine.printCode()

main()

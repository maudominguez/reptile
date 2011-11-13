
import RVM
import sys
from ClassSymbol import *
from MethodSymbol import *
from Frame import *
from Quadruple import *
from Quadruple import *
from ObjectSpace import *
from CallStack import *

class RVM (object):

    mainMethodName = "Main@main"
    mainClassName = "Main"
    firstRegisterInFrames = 10000

    def __init__(self):
        self.classesDirectory = {}
        self.methodsDirectory = {}
        self.code = [] #list of quadruples
        self.ip = -1    #qudruple pointer
        self.callStack = CallStack() #stack of frames
        self.mainClass = None
        self.mainMethod = None

    def cpu(self):
        
        """
        the first main frame should return to the HALT instruction, which is the last
        quadruple
        """
        HALTinstIdx = len(self.code) - 1
        mainMethodFrame = Frame(self.mainMethod, HALTinstIdx)
        mainObject = ObjectSpace(self.mainClass)
        mainMethodFrame.registers[0] = mainObject
        self.callStack.push(mainMethodFrame)

        quadruple = self.code[self.ip]
        toBeInvokedFrame = None
        while (quadruple.opCode != "HALT" and self.ip < len(self.code)):
            registers = self.callStack.peek().registers  #shortcut to current stack registers
            self.ip = self.ip + 1 #almost all the instructions should increment the ip
                                #if not, the instruction should take care of it
                
            if(quadruple.opCode == "+"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] + registers[offset(op2)]
            elif(quadruple.opCode == "-"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] - registers[offset(op2)]
            elif(quadruple.opCode == "*"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] * registers[offset(op2)]
            elif(quadruple.opCode == "/"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] / registers[offset(op2)]
            elif(quadruple.opCode == "or"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] or registers[offset(op2)]
            elif(quadruple.opCode == "and"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] and registers[offset(op2)]
            elif(quadruple.opCode == "=="):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] == registers[offset(op2)]
            elif(quadruple.opCode == "!="):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] != registers[offset(op2)]
            elif(quadruple.opCode == ">="):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] >= registers[offset(op2)]
            elif(quadruple.opCode == ">"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] > registers[offset(op2)]
            elif(quadruple.opCode == "<="):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] <= registers[offset(op2)]
            elif(quadruple.opCode == "<"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op3)] = registers[offset(op1)] < registers[offset(op2)]
            elif(quadruple.opCode == "PRINT"):
                op1 = int(quadruple.op1)
                print(str(registers[offset(op1)]), end = "")
            elif(quadruple.opCode == "PRINTLINE"):
                print()
            elif(quadruple.opCode == "READINT"):
                op1 = int(quadruple.op1)
                read = input()
                try:
                    tmp = int(read)
                except ValueError:
                    exit("ERROR Inesperado: Se leyo una literal no valida en readint(): " + read)
                registers[offset(op1)] = tmp
            elif(quadruple.opCode == "READDOUBLE"):
                op1 = int(quadruple.op1)
                read = input()
                try:
                    tmp = float(read)
                except ValueError:
                    exit("ERROR Inesperado: Se leyo una literal no valida en readdouble(): " + read)
                registers[offset(op1)] = tmp
            elif(quadruple.opCode == "READCHAR"):
                op1 = int(quadruple.op1)
                read = input()
                if(len(read) > 1):
                    exit("ERROR Inesperado: Se leyo mas de un caracter en readchar(): " + read)
                registers[offset(op1)] = read
            elif(quadruple.opCode == "GOTOFALSE"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                if(not registers[offset(op1)]):
                    self.ip = op2
            elif(quadruple.opCode == "GOTO"):
                op1 = int(quadruple.op1)
                self.ip = op1
            elif(quadruple.opCode == "CCONST"):
                op1 = quadruple.op1
                op2 = int(quadruple.op2)
                registers[offset(op2)] = chr(ord(op1))
            elif(quadruple.opCode == "DCONST"):
                op1 = float(quadruple.op1)
                op2 = int(quadruple.op2)
                registers[offset(op2)] = op1
            elif(quadruple.opCode == "ICONST"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                registers[offset(op2)] = op1
            elif(quadruple.opCode == "="):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                registers[offset(op2)] = registers[offset(op1)]
            elif(quadruple.opCode == "ERA"):
                op1 = quadruple.op1
                methodToBeInvoked = self.methodsDirectory[op1]
                toBeInvokedFrame = Frame(methodToBeInvoked, -1) #the return address of the invokedFrame should be set in the GOSUB/GOSUBVOID.
                                                                #here we leave it pending with a -1
            elif(quadruple.opCode == "PARAM"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                toBeInvokedFrame.registers[op2] = registers[offset(op1)]
            elif(quadruple.opCode == "GOSUB"):
                op1 = quadruple.op1
                op2 = int(quadruple.op2)
                invokedMethodSymbol = self.methodsDirectory[op1]
                callerFrame = self.callStack.peek()
                callerFrame.tempReturned = op2  #register that will be used to store the value that invokedFrame will return. No offseted yet
                toBeInvokedFrame.returnAddress = self.ip
                self.callStack.push(toBeInvokedFrame)
                self.ip = invokedMethodSymbol.firstQuadrupleIdx
            elif(quadruple.opCode == "GOSUBVOID"):
                op1 = quadruple.op1
                invokedMethodSymbol = self.methodsDirectory[op1]
                callerFrame = self.callStack.peek()
                toBeInvokedFrame.returnAddress = self.ip
                self.callStack.push(toBeInvokedFrame)
                self.ip = invokedMethodSymbol.firstQuadrupleIdx
            elif(quadruple.opCode == "RETURN"):
                op1 = int(quadruple.op1)
                returnValue = registers[offset(op1)]
                popedFrame = self.callStack.pop()
                callerFrame = self.callStack.peek()
                callerFrame.registers[offset(callerFrame.tempReturned)] = returnValue
                self.ip = popedFrame.returnAddress
            elif(quadruple.opCode == "RETURNVOID"):
                popedFrame = self.callStack.pop()
                self.ip = popedFrame.returnAddress
            elif(quadruple.opCode == "SHOULD_RETURN_SOMETHING_ERROR"):
                op1 = quadruple.op1
                exit("ERROR Inesperado: Metodo " + op1 + " no regreso nada...")
                #TODO throw exception
            elif(quadruple.opCode == "OBJECT"):
                op1 = int(quadruple.op1)
                op2 = quadruple.op2.strip()
                clase = self.classesDirectory[op2]
                obj = ObjectSpace(clase)
                registers[offset(op1)] = obj
            elif(quadruple.opCode == "PUTFIELD"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op2)].fields[op3] = registers[offset(op1)]
            elif(quadruple.opCode == "GETFIELD"):
                op1 = int(quadruple.op1)
                op2 = int(quadruple.op2)
                op3 = int(quadruple.op3)
                registers[offset(op1)] = registers[offset(op2)].fields[op3]
            else:
                print("Cuadruplo no reconocido: " + quadruple.opCode)
            quadruple = self.code[self.ip]

    def loadQuadruplesFromFile(self, inFile):
        nQuadruples = int(inFile.readline())
        for iQuad in range(nQuadruples):
            line = inFile.readline()
            if(line.startswith("CCONST")):
                start = line.find("'") + 1
                end = line.rfind("'")
                quadruple = Quadruple("CCONST", line[start:end], line.split()[-1])

            else:
                quadElems = line.split()
                quadruple = Quadruple(quadElems[0])
                if(len(quadElems) >= 2):
                    quadruple.op1 = quadElems[1]
                if(len(quadElems) >= 3):
                    quadruple.op2 = quadElems[2]
                if(len(quadElems) >= 4):
                    quadruple.op3 = quadElems[3]
            self.code.append(quadruple)

        

    def loadDirectoriesFromFile(self, inFile):
       
        self.ip = int(inFile.readline())
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
                firstQuadrupleIdx = int(inFile.readline().rstrip())
                totalOfVars = int(inFile.readline().rstrip())
                numberOfLocalVars = int(inFile.readline().rstrip())
                methodSymbol = MethodSymbol(methodName, firstQuadrupleIdx, totalOfVars, numberOfLocalVars)
                if(numberOfLocalVars > 0):
                    registerOfTheFirstLocal = int(inFile.readline().rstrip())
                    methodSymbol.registerOfTheFirstLocal = registerOfTheFirstLocal

                for x in range(numberOfLocalVars):
                    type = inFile.readline().rstrip()
                    methodSymbol.addLocalVarType(type)

                self.methodsDirectory[methodSymbol.name] = methodSymbol
        self.mainClass = self.classesDirectory[RVM.mainClassName]
        self.mainMethod = self.methodsDirectory[RVM.mainMethodName]

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
        toOpen = "../../../../bin/Debug/" + sys.argv[1] #TODO quitar la primera parte de la ruta
        inFile = open (toOpen, "r")
        self.loadDirectoriesFromFile(inFile)
        self.loadQuadruplesFromFile(inFile)
        inFile.close()

def offset(address):
    return address - RVM.firstRegisterInFrames

def main():
    #print("w = " + chr(ord("\n")))

    virtualMachine = RVM()
        
    virtualMachine.loadCodeFile()
    #virtualMachine.printClassesDirectory()
    #virtualMachine.printMethodsDirectory()
    #virtualMachine.printCode()
    virtualMachine.cpu()

if __name__ == '__main__':
    main()

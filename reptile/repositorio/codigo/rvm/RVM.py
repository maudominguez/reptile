from ClassSymbol import *
from MethodSymbol import *
from StackFrame import *

class RVM (object):

	def __init__(self):
		self.classesDirectory = {}
		self.methodsDirectory = {}
		self.calls = []
		self.framePointer = -1
		
	
	def loadCodeFile(self):
		inFile = open ("code.txt", "r")
		self.startQuadruple = inFile.readline()
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
		
		inFile.close()
		
		for key in self.classesDirectory:
			print(self.classesDirectory[key])
			
		for key in self.methodsDirectory:
			print(self.methodsDirectory[key])
			
	
def main():
	virtualMachine = RVM()
	virtualMachine.loadCodeFile()

main()

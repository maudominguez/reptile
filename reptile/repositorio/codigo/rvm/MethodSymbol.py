class MethodSymbol (object):
	def __init__(self, name, totalOfVars, numberOfLocalVars, registerOfTheFirstLocal = -1):
		self.name = name
		self.totalOfVars = totalOfVars
		self.numberOfLocalVars = numberOfLocalVars
		self.registerOfTheFirstLocal = registerOfTheFirstLocal
		self.localVarsTypesList = []
		
		
	def addLocalVarType(self, type):
		self.localVarsTypesList.append(type)
		
	def __str__(self):
		res = self.name + "\n"
		res += "types: "
		for localVarType in self.localVarsTypesList:
			res += localVarType + " "
		res += "\ntotal of vars: " + str(self.totalOfVars)
		res += "\nnumber of locals: " + str(self.numberOfLocalVars)
		res += "\nregister of the first local: " + str(self.registerOfTheFirstLocal)
		res += "\n"
		return res
		
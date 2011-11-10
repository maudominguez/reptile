class ClassSymbol (object):
	def __init__(self, name):
		self.name = name
		self.instVarsTypesList = []
		
	def addInstanceVarType(self, type):
		self.instVarsTypesList.append(type)
		
	def __str__(self):
		res = self.name + "\n"
		res += "types: "
		for type in self.instVarsTypesList:
			res += type + " "
		return res
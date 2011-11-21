grammar Reptile;

options
{
    language=CSharp2;
}

tokens
{

}

@header
{
	using System;
	using System.IO;
}

@rulecatch {
    catch (RecognitionException ex) {
        throw ex;
    }
}

@lexer::members {

public override void ReportError(RecognitionException e)
{
	//System.Console.WriteLine("PLACE: En ReportError");
	//DisplayRecognitionError(this.TokenNames, e);	//ADDED
	throw e;
}

/*
public override string GetErrorMessage(RecognitionException e, string[] tokenNames) {	//ADDED
	System.Console.WriteLine("EN GETERRORMESSAGE1");
	System.Console.WriteLine("La base me regresa " + base.GetErrorMessage(e, tokenNames));
	System.Console.WriteLine("Y la linea es " + Line);
	System.Console.WriteLine("Y la posicion del caracter es " + CharPositionInLine);
	System.Console.WriteLine("En el caracter " + GetCharErrorDisplay(e.Character));
	return "EN GETERRORMESSAGE LEXER";
}
*/
}

@members {
SymbolTable directory;
Stack<string> pOperadores = new Stack<string>();
Stack<VariableSymbol> pOperandos = new Stack<VariableSymbol>();
QuadruplesList quadruplesList = new QuadruplesList();
Stack<Quadruple> pSaltos = new Stack<Quadruple>();
Stack<ArrayVariableSymbol> pDimensionadas = new Stack<ArrayVariableSymbol>();
string mainClassName = "Main";
string mainMethodName = "main";
string nameProgram;

Scope actualScope;
ClassSymbol mainClass;

LinkedList<string> operadoresRelacionales = new LinkedList<string>(new string[] {"==", "!=", ">", "<", ">=", "<="});
LinkedList<string> masMenosOr = new LinkedList<string>(new string[] {"+", "-", "or"});
LinkedList<string> porEntreAnd = new LinkedList<string>(new string[] {"*", "/", "and"});

public override void ReportError(RecognitionException e)
{
	//System.Console.WriteLine("PLACE: En ReportError PARSER");
	//DisplayRecognitionError(this.TokenNames, e);	//ADDED
	throw e;
}

/*
public override string GetErrorMessage(RecognitionException e, string[] tokenNames) {	//ADDED
	return "EN GETERRORMESSAGE PARSER";
}
*/

protected override object RecoverFromMismatchedToken(IIntStream input, int ttype, BitSet follow)
{
	//Console.WriteLine("PLACE: En RecoverFromMismatchedToken");
      throw new MismatchedTokenException(ttype, input);
}

public override object RecoverFromMismatchedSet(IIntStream input, RecognitionException e, BitSet follow)
{
	//Console.WriteLine("PLACE: En RecoverFromMismatchedSet");
        throw e;
}

void createDirectories() {
	directory = new SymbolTable();
}

void defineMainClass() {
	mainClass = new ClassSymbol(mainClassName, null);
	directory.Add(mainClass.name, (ScopeWithMethods)mainClass);
}

void registerClass(string className, string superClase) {
	try {
		ClassSymbol clasePadre = null;
		if(superClase != null) {
			try {
				clasePadre = directory.findType(superClase);
			}
			catch(Exception exception) {
				manageException(exception);
			}
		}
		
		ClassSymbol newClass = new ClassSymbol(className, clasePadre);
		directory.Add(newClass.name, newClass);
		actualScope = newClass;
	}
	catch(Exception exception) {
		manageException(exception);	//manejarException
	}
}

//usado con metodos y variables
void registerVariableInScope(string variableName, ClassSymbol tipo) {
	VariableSymbol variable = new VariableSymbol(variableName, tipo);
	if(actualScope is MethodSymbol) {
		((MethodSymbol)actualScope).defineLocalVariable(variableName, variable);
	}
	else {
		actualScope.defineVariable(variable.name, variable);
	}
}

void registrarMetodo(ClassSymbol tipoRetorno, string methodName) {
	ScopeWithMethods scope = (ScopeWithMethods)actualScope;
	MethodSymbol methodSymbol = new MethodSymbol(methodName, tipoRetorno, scope);
	scope.defineMethod(methodName, methodSymbol);
	actualScope = methodSymbol;
}

void registerFormalParameter(string variableName, string tipo) {
	ClassSymbol tipoParam = directory.findType(tipo);
	VariableSymbol variableSymbol = new VariableSymbol(variableName, tipoParam);
	MethodSymbol methodSymbol = (MethodSymbol) actualScope;	//casting para poder llamar a defineParameter(..)
	methodSymbol.defineParameter(variableName, variableSymbol);
}

bool verifyVariableCanBeAccessed(string variable) {
	VariableSymbol varSymbol = actualScope.getVariableSymbol(variable);
	if(varSymbol == null) {
		generateVariableNotFoundError(variable);
		return false;
	}
	return true;
}

void generateVariableNotFoundError(string variable) {
		MethodSymbol m = (MethodSymbol)actualScope;
		Exception e = new Exception(m.fullyQualifiedName() + ": No se encontro la variable " + variable);
		manageException(e);
}

void verifyObjectAndInstVariableDefined(string objeto, string instVar) {
	verifyVariableCanBeAccessed(objeto);
	VariableSymbol obj = actualScope.getVariableSymbol(objeto);
	ClassSymbol tipo = obj.type;
	verifyInstVariableDefinedInClassSymbol(tipo, instVar);
}

void verifyInstVariableDefinedInClassSymbol(ClassSymbol tipo, string instVar) {
	VariableSymbol varDeInstancia = tipo.getVariableSymbol(instVar);
	if(varDeInstancia == null) {
		generateInstanceVariableNotFoundError(tipo.name, instVar);
	}
}

VariableSymbol getVariable(string variable) {
	verifyVariableCanBeAccessed(variable);
	return actualScope.getVariableSymbol(variable);
}

VariableSymbol getField(string objeto, string instVar) {
	verifyObjectAndInstVariableDefined(objeto, instVar);
	VariableSymbol obj = actualScope.getVariableSymbol(objeto);
	ClassSymbol tipo = obj.type;
	VariableSymbol varDeInstancia = tipo.getVariableSymbol(instVar);
	return varDeInstancia;
}

MethodSymbol getMethod(string objeto, string method) {
	verifyObjectAndMethodDefined(objeto, method);
	VariableSymbol obj = actualScope.getVariableSymbol(objeto);
	MethodSymbol methodSymbol = obj.type.getMethodSymbol(method);
	return methodSymbol;
}

void verifyObjectAndMethodDefined(string objeto, string method) {
	verifyVariableCanBeAccessed(objeto);
	VariableSymbol obj = actualScope.getVariableSymbol(objeto);
	ClassSymbol type = obj.type;
	verifyMethodDefinedInClassSymbol(type, method);
}

void verifyMethodDefinedInClassSymbol(ClassSymbol type, string method) {
	MethodSymbol methodSymbol = type.getMethodSymbol(method);
	if(methodSymbol == null) {
		string msg = "Metodo " + method + " no esta definido en la clase " + type.name + " ni en alguna superclase.";
		manageException(new Exception(msg));
	}
}

void generateInstanceVariableNotFoundError(string scope, string variable) {
	MethodSymbol m = (MethodSymbol)actualScope;
	Exception e = new Exception(m.fullyQualifiedName() + ": No se encontro la variable de instancia " + variable + " en " + scope);
	manageException(e);
}

void verifyInstanceVariableDefinedInThis(string var) {
	ScopeWithMethods enclosingScope = ((MethodSymbol)actualScope).enclosingScope;
	VariableSymbol instVariable = enclosingScope.getVariableSymbol(var);
	if(instVariable == null) {
		generateInstanceVariableNotFoundError(enclosingScope.name, var);
	}
}

VariableSymbol getInstanceVariable(string var) {
	verifyInstanceVariableDefinedInThis(var);
	ScopeWithMethods enclosingScope = ((MethodSymbol)actualScope).enclosingScope;
	ClassSymbol clase = (ClassSymbol)enclosingScope;
	return clase.getVariableSymbol(var);
}

/*
void verifyIsVector(string var) {
	if(verifyVariableCanBeAccessed(var)) {
		VariableSymbol arr = actualScope.getVariableSymbol(var);
		if(!arr.type.isVectorType()) {
			generateIsNotVectorError(arr.name);
		}
	}
}
*/
/*
void generateIsNotVectorError(string variable) {
	MethodSymbol m = (MethodSymbol)actualScope;
	Exception e = new Exception(m.fullyQualifiedName() + ": La variable " + variable + " no es de ninguna clase Vector y por tanto no tiene definido el operador [] .");
	manageException(e);
}
*/

public bool tiposSonCompatiblesEnOperacion() {
	VariableSymbol right = pOperandos.Pop();
	VariableSymbol left = pOperandos.Pop();
	pOperandos.Push(left);
	pOperandos.Push(right);
	string operador = pOperadores.Peek();
	ClassSymbol tipoResultado = directory.resultType(left.type, right.type, operador);
	if(tipoResultado.isVoidType()) {
		return false;
	}
	return true;
}

public void aplicaOperadorPendienteQueSea(LinkedList<string> operadoresBuscados) {
	if(pOperadores.Count > 0) {
		string operador = pOperadores.Peek();
		if(operadoresBuscados.Contains(operador)) {
			if(tiposSonCompatiblesEnOperacion()) {
				pOperadores.Pop();
				VariableSymbol right = pOperandos.Pop();
				VariableSymbol left = pOperandos.Pop();
				ClassSymbol tipoResultado = directory.resultType(left.type, right.type, operador);
				
				VariableSymbol temporal = getNewTemporalVarOfType(tipoResultado.name);
				quadruplesList.addEXPRESSION_OPER(operador, left.address.ToString(), right.address.ToString(), temporal.address.ToString());
				pOperandos.Push(temporal);
			}
			else {
				
				pOperadores.Pop();
				VariableSymbol right = pOperandos.Pop();
				VariableSymbol left = pOperandos.Pop();
				MethodSymbol m = (MethodSymbol)actualScope;
				manageException(new SemanticException(m.fullyQualifiedName() +": operador \"" + operador + "\" no es valido para " + 
					left.type.name + " " + left.name + ", " + right.type.name + " " + right.name));
			}
		}
	}
}

public void pushICONST(string iConst) {
	VariableSymbol temp = getNewTemporalVarOfType("int");
	pOperandos.Push(temp);
	quadruplesList.addICONST(iConst, temp.address.ToString());
}

public void pushCCONST(string cConst) {
	VariableSymbol temp = getNewTemporalVarOfType("char");
	pOperandos.Push(temp);
	quadruplesList.addCCONST(cConst, temp.address.ToString());
}

public void pushDCONST(string dConst) {
	VariableSymbol temp = getNewTemporalVarOfType("double");
	pOperandos.Push(temp);
	quadruplesList.addDCONST(dConst, temp.address.ToString());
}

public VariableSymbol getNewTemporalVarOfType(string type) {
	ClassSymbol tipo = directory.findType(type);
	VariableSymbol temp = ((MethodSymbol)actualScope).getNewTemporal(tipo);
	return temp;
}

/*
public string typeOfVector(string type) {
	if(type.Equals(SymbolTable.integerVectorName)) {
		return SymbolTable.integerName;
	}
	else if(type.Equals(SymbolTable.charVectorName)) {
		return SymbolTable.charName;
	}
	else if(type.Equals(SymbolTable.doubleVectorName)) {
		return SymbolTable.doubleName;
	}
	else {
		manageException(new Exception("El tipo " + type + " no es un tipo de vector conocido."));
		return "";
	}
}
*/

public void printQuadruplesList() {
	Console.WriteLine(quadruplesList.ToStringWithQuadrupleNumbers());
}

public void verifyMainMethodDefinedInMainClass() {
	MethodSymbol mainMethod = mainClass.getMethodSymbol(mainMethodName);
	if(mainMethod == null) {
		string errorMsg = "Debe definir al metodo void main() {..} en la clase Main";
		manageException(new Exception(errorMsg));
	}
	if(mainMethod.returnType.name != SymbolTable.voidName) {
		string errorMsg = "El tipo de retorno de main() {..} en la clase Main debe ser void";
		manageException(new Exception(errorMsg));
	}
	if(mainMethod.countParameters() > 1) {
		string errorMsg = "El metodo " + mainMethod.fullyQualifiedName() + " no puede recibir parametros.";
		manageException(new Exception(errorMsg));
	}
}

public static void manageException(Exception e) {
	throw new SemanticException("ERROR SEMANTICO: " + e.ToString() + "\n");
}
}

public program	:	{createDirectories(); defineMainClass();} programName classDecl* {actualScope = mainClass;} classMain;

programName
	:	'program' ID ';' {nameProgram = $ID.text;};

classMain
	:	'class' 'Main' '{' varDecl* methodDeclaration* {quadruplesList.addHALT();} '}' 
		{
		verifyMainMethodDefinedInMainClass();
		directory.printDirectory(); directory.printTypesDirectory(); printQuadruplesList();
		string outputFile = nameProgram + ".re";
		System.IO.File.WriteAllText(@outputFile, directory.formattedSymbolTable() + quadruplesList.countQuadruples() + "\n" + quadruplesList.ToString());
		};

classDecl
    :   'class' clase = ID (superClass)? {registerClass($clase.text, $superClass.superClase);} '{' varDecl* methodDeclaration* '}';

superClass returns[string superClase]:	'extends' ID {$superClase = $ID.text;};

vars
	:	'vars' ':' varDecl*;

varDecl
@init {
	ClassSymbol clase;
}
    :   (
    	(t = primitiveType | t = referenceType) {clase = directory.findType($t.tipo);} ID 
    	{registerVariableInScope($ID.text, clase);} 
    	| arrayVarDeclaration)
    	';' ;
    
primitiveType returns[string tipo]:	t = ('int'|'char' | 'double') {$tipo = $t.text;};

referenceType returns[string tipo]:	ID	{$tipo = $ID.text;}	;

arrayVarDeclaration
	:	 'array' '<' pt = primitiveType '>' '[' INT ']' ID
		{
		ClassSymbol arrayClassSymbol = SymbolTable.arrayClassSymbol;
		ClassSymbol parameterizedType = directory.findType($pt.tipo);
		int size = int.Parse($INT.text);
		if(size <= 0) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": Toda dimension del array " + $ID.text + " debe ser mayor o igual a 1.";
			manageException(new Exception(msg));
		}
		string variableName = $ID.text;
		
		ArrayVariableSymbol variable = new ArrayVariableSymbol(variableName, parameterizedType);
		variable.addDimension(size);
		if(actualScope is MethodSymbol) {
			((MethodSymbol)actualScope).defineLocalVariable(variable.name, variable);
		}
		else {
			actualScope.defineVariable(variable.name, variable);
		}
		}
		
	;

voidType returns[string tipo]:	t = 'void' {$tipo = $t.text;};

formalParamType returns[string tipo]:	(t = primitiveType	//char, int
					| t = referenceType) 	//CharVector, IntVector, DoubleVector, MiClase
					{$tipo = $t.tipo;};

methods
	:	'methods' ':' methodDeclaration*;

methodDeclaration
@init {
	ClassSymbol tipoRetorno;
	MethodSymbol method;
}
:	(tRet = primitiveType | tRet = referenceType | tRet = voidType) {tipoRetorno = directory.findType($tRet.tipo);} 
	ID 
	{
	registrarMetodo(tipoRetorno, $ID.text);
	method = (MethodSymbol)actualScope;
	} 
	'(' formalParameters? ')'
	'{' {method.firstQuadruple = quadruplesList.nextNumberOfQuadruple();} varDecl* someStatements '}' 
	
	{
	if(method.returnsVoid()) {
		quadruplesList.addRETURNVOID();
	}
	else {
		quadruplesList.addSHOULD_RETURN_SOMETHING_ERROR(method.fullyQualifiedName());
	}
	actualScope = ((MethodSymbol)actualScope).enclosingScope;
	}
	;
	
formalParam:	t = formalParamType ID {registerFormalParameter($ID.text, $t.tipo);};
	
formalParameters
:  t = formalParam (',' formalParam)* ;

someStatements
	:	statement*;

statement 
scope {
	bool inExpression;
}
:		{$statement::inExpression = false;}
		(
			assignment
		|	invoke ';'
		|	if_inst
		|	while_inst
		|	return_inst
		|	print
		| ';'
		);
			
assignment
scope {
	int caso;
	VariableSymbol par1;	//obj
	VariableSymbol par2;	//field
	ClassSymbol leftType;
}
	:	designator '=' 
		(
		expression
		| 'new' ID '(' ')' 
			{
			ClassSymbol tipo = directory.findType($ID.text);
			VariableSymbol temp = getNewTemporalVarOfType(tipo.name);
			pOperandos.Push(temp);
			quadruplesList.addOBJECT(temp.address.ToString(), tipo.name);
			
			}
		)
		{
		VariableSymbol right = pOperandos.Pop();
		if(!directory.validAssignment($assignment::leftType, right.type)) {
			MethodSymbol m = (MethodSymbol)actualScope;
			manageException(new Exception("En " + m.fullyQualifiedName() + ": No se puede asignar " + right.name + " a " + $assignment::par2.name + " porque el tipo " + 
						right.type.name + " no es asignable al tipo " + $assignment::leftType.name));
		}
		if($assignment::caso == 0) {	//ID = right
			quadruplesList.addASSIGNMENT(right.address.ToString(), $assignment::par2.address.ToString());
		}
		else if($assignment::caso == 1) {	//ID.ID = right
			quadruplesList.addPUTFIELD(right.address.ToString(), $assignment::par1.address.ToString(), $assignment::par2.address.ToString());
		}
		else if($assignment::caso == 2) {	//this.ID = bla
			MethodSymbol method = (MethodSymbol)actualScope;
			quadruplesList.addPUTFIELD(right.address.ToString(), method.getThisParameterAddress(), $assignment::par2.address.ToString());	
		}
		else if($assignment::caso == 3) {
			quadruplesList.addPUTARRAYELEM($assignment::par2.address.ToString(), right.address.ToString());
		}
		}
		';'
	;
	
designator
	:	
		v = ID //variable local del metodo
			{
			$assignment::caso = 0;
			verifyVariableCanBeAccessed($v.text); 
			$assignment::par2 = getVariable($ID.text);
			
			$assignment::leftType = $assignment::par2.type;
			}
		(
		{pOperandos.Push(getVariable($ID.text));} /*because it is needed by the array access rule*/
		arrayAccess	//all the necesary for the assignment is set in the array acess rule
		)?
			
		| obj = ID  '.' var = ID 
			{
			$assignment::caso = 1;
			verifyObjectAndInstVariableDefined($obj.text, $var.text); 
			$assignment::par1 = getVariable($obj.text);
			$assignment::par2 = getField($obj.text, $var.text);
			
			$assignment::leftType = $assignment::par2.type;
			} //objeto.variable
		| 'this' '.' var = ID
			{
			$assignment::caso = 2;
			verifyInstanceVariableDefinedInThis($var.text);
			$assignment::par2 = getInstanceVariable($var.text);
			
			$assignment::leftType = $assignment::par2.type;
			}    //this.variable
	
			/*
		| (ID '[' {pOperadores.Push("[");} expression ']' {pOperadores.Pop();})	//vector[exp]
			{
			$assignment::caso = 3;
			verifyIsVector($ID.text);
			VariableSymbol index = pOperandos.Pop();
			if(!index.type.name.Equals("int")) {
				manageException(new Exception("El subindice del Vector " + $ID.text + " debe ser de tipo int."));
			}
			else {
				$assignment::par2 = getVariable($ID.text);
				$assignment::par1 = index;
			}
			
			string tipo = typeOfVector($assignment::par2.type.name);
			$assignment::leftType = directory.findType(tipo);
			}
			*/
	;
	
arrayAccess
	:	(
		'['
		{
		bool inExpression = $statement::inExpression; //save the value here because it will be modified in the expression for the index
		VariableSymbol variable = pOperandos.Pop();
		MethodSymbol m = (MethodSymbol)actualScope;
		if(!(variable is ArrayVariableSymbol)) {
			string msg = "En " + m.fullyQualifiedName() + ": La variable " + variable.name
							+ " no es un array y por tanto no tiene definido el operador [] .";
			manageException(new Exception(msg));
		}
		ArrayVariableSymbol array = (ArrayVariableSymbol)variable;
		pDimensionadas.Push(((ArrayVariableSymbol)array));
		pOperadores.Push("[");
		}
		
		expression 
		
		{
		VariableSymbol index = pOperandos.Peek();
		if(!index.type.name.Equals(SymbolTable.integerName)) {
			manageException(new Exception("En " + m.fullyQualifiedName() + ": El subindice del array " + array.name
							+ " debe ser de tipo int. Se encontro tipo " + index.type.name));
		}
		//Here we are just checking for the dimension 0 because we are handling only vectors
		quadruplesList.addVERIFYARRAYACCESS(index.address.ToString(), array.getDimension(0).ToString());
		}
		
		']' {pOperadores.Pop();}
		{
		index = pOperandos.Pop();
		VariableSymbol arr = pDimensionadas.Pop();
		
		//get a constant with the base address
		VariableSymbol baseConst = getNewTemporalVarOfType(SymbolTable.integerName);
		quadruplesList.addICONST(arr.address.ToString(), baseConst.address.ToString());
		
		//get the address to deref
		VariableSymbol toDeref = getNewTemporalVarOfType(SymbolTable.integerName);
		quadruplesList.addEXPRESSION_OPER("+", index.address.ToString(), baseConst.address.ToString(), toDeref.address.ToString());
		
		
		if(inExpression) {
			//getting the value of an array element
			VariableSymbol dereferencedTemp = getNewTemporalVarOfType(array.parameterizedType.name);
			quadruplesList.addGETARRAYELEM(toDeref.address.ToString(), dereferencedTemp.address.ToString());
			pOperandos.Push(dereferencedTemp);
		}
		else {
			//this is an assigment of an array element
			$assignment::caso = 3;
			$assignment::par2 = toDeref;
			$assignment::leftType = array.parameterizedType;
			//Console.WriteLine("bla = " + $assignment::leftType.name);
		}
		}
		);

invoke
scope {
	MethodSymbol invokedMethod;
	VariableSymbol obj;
}
:	
		(objId = ID {$invoke::obj = getVariable($objId.text);}| 'this' {$invoke::obj = ((MethodSymbol)actualScope).getThisParameter();}) 
		'.' method = ID {$invoke::invokedMethod = getMethod($invoke::obj.name, $method.text);}
		{
		
		if($statement::inExpression && $invoke::invokedMethod.returnsVoid()) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": Llamada a metodo void " + $invoke::invokedMethod.fullyQualifiedName() + ". No es valido llamar a un metodo void"
									+ " como parte de una expresion.";
			manageException(new Exception(msg));
		}
		
		}
		actualParameters
		//miObjeto.metodo(param1, param2,...) 
		//this.metodo(param1,param2,...)
		;
		
actualParameters
	:	
		{pOperadores.Push("(");}
		'('
		{
		VariableSymbol formalParam;
		VariableSymbol actualParam;
		IEnumerator<VariableSymbol> paramIterator = $invoke::invokedMethod.getParamIterator();
		paramIterator.MoveNext();
		LinkedList<VariableSymbol> argsList = new LinkedList<VariableSymbol>();
		argsList.AddLast($invoke::obj);
		}

		(expression 
		{
		if(!paramIterator.MoveNext()) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": Parametros formales de mas en llamada a " + $invoke::invokedMethod.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		formalParam = paramIterator.Current;
		actualParam = pOperandos.Pop();
		if(!directory.validAssignment(formalParam.type, actualParam.type)) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": El tipo del argumento " + actualParam.name + " no es asignable al tipo del parametro formal " 
					+ formalParam.name + " en la llamada a " + $invoke::invokedMethod.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		argsList.AddLast(actualParam);
		}
		
		(',' expression 
		{
		if(!paramIterator.MoveNext()) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": Parametros formales de mas en llamada a " + $invoke::invokedMethod.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		formalParam = paramIterator.Current;
		actualParam = pOperandos.Pop();
		if(!directory.validAssignment(formalParam.type, actualParam.type)) {
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": El tipo del argumento " + actualParam.name + " no es asignable al tipo del parametro formal " 
					+ formalParam.name + " en la llamada a " + $invoke::invokedMethod.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		argsList.AddLast(actualParam);
		}
		)*)? ')'
		
		{pOperadores.Pop();}
		{
		if(paramIterator.MoveNext()) { 
			MethodSymbol m = (MethodSymbol)actualScope;
			string msg = "En " + m.fullyQualifiedName() + ": Faltan argumentos en la llamada a " + $invoke::invokedMethod.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		
		quadruplesList.addERA($invoke::invokedMethod.fullyQualifiedName());
		int paramCount = 0;
		foreach (VariableSymbol arg in argsList) {
			quadruplesList.addPARAM(arg.address.ToString(), paramCount.ToString());
			paramCount++;
		}
		
		if($invoke::invokedMethod.returnsVoid()) {
			quadruplesList.addGOSUBVOID($invoke::invokedMethod.fullyQualifiedName());
		}
		else {
			VariableSymbol varToStoreResult = ((MethodSymbol)actualScope).getNewTemporal($invoke::invokedMethod.returnType);
			quadruplesList.addGOSUB($invoke::invokedMethod.fullyQualifiedName(), varToStoreResult.address.ToString());
			pOperandos.Push(varToStoreResult);
		}
		}
		;

if_inst	
scope {
	bool elsePresent;
}
:	'if' '(' expression ')' 
		{
		$if_inst::elsePresent = false;
		VariableSymbol condition = pOperandos.Pop();
		if(!condition.type.name.Equals(SymbolTable.boolName)) {
			string msg = "En metodo " + ((MethodSymbol)actualScope).fullyQualifiedName() +  " condicion en if debe ser un valor bool.";
			manageException(new Exception(msg));
		}
		
		quadruplesList.addGOTOFALSE(condition.address.ToString(), "-");
		pSaltos.Push(quadruplesList.getLastQuadruple());
		}
		'{'  someStatements '}' 
		
		(
		{$if_inst::elsePresent = true;}
		'else' 
		{
		quadruplesList.addGOTO("-");
		Quadruple end = quadruplesList.getLastQuadruple();
		Quadruple falso = pSaltos.Pop();
		falso.operando2 = quadruplesList.nextNumberOfQuadruple().ToString();
		pSaltos.Push(end);
		}
		'{' someStatements '}'
		{
		Quadruple gotoEnd = pSaltos.Pop();
		gotoEnd.operando1 = quadruplesList.nextNumberOfQuadruple().ToString();
		}
		)?
		
		{
		if(!$if_inst::elsePresent) {
			Quadruple end = pSaltos.Pop();
			end.operando2 = quadruplesList.nextNumberOfQuadruple().ToString();
		}
		}
		;

while_inst
scope {
	int start;
}
:			{$while_inst::start = quadruplesList.nextNumberOfQuadruple();}
			'while' '(' expression ')' 
			{
			VariableSymbol condition = pOperandos.Pop();
			if(!condition.type.name.Equals(SymbolTable.boolName)) {
				string msg = "En metodo " + ((MethodSymbol)actualScope).fullyQualifiedName() +  " condicion en while debe ser un valor bool.";
				manageException(new Exception(msg));
			}
			quadruplesList.addGOTOFALSE(condition.address.ToString(), "-");
			pSaltos.Push(quadruplesList.getLastQuadruple());
			}
			'{' someStatements '}'
			{
			quadruplesList.addGOTO($while_inst::start.ToString());
			Quadruple start = pSaltos.Pop();
			start.operando2 = quadruplesList.nextNumberOfQuadruple().ToString();
			}
			;

return_inst
@init {
	bool returnsSomething = false;
	VariableSymbol varToReturn;
	MethodSymbol method;
}
:
		{method = (MethodSymbol)actualScope;}
		'return' 
		
		(
		//si estamos aqui es porque si vino una expresion despues del return
		{
		returnsSomething = true;
		if(method.returnsVoid()) {
			string msg = "Error en return: No se permite regresar un valor en el metodo void " + method.fullyQualifiedName();
			manageException(new Exception(msg));
		}
		}
		expression
		)?
		
		
		{
		if(!method.returnsVoid() && !returnsSomething) {
			string msg = "Error en return: " + method.fullyQualifiedName() + " debe regresar un valor tipo " + method.returnType.name;
			manageException(new Exception(msg));
		}
		if(method.returnsVoid()) {
			quadruplesList.addRETURNVOID();
		}
		else {
			varToReturn = pOperandos.Pop();
			if(!directory.validAssignment(method.returnType, varToReturn.type)) {
				string msg = "Error en return: Tipo " + varToReturn.type.name + " no se puede regresar como tipo " + method.returnType.name
						+ " en " + method.fullyQualifiedName();
				manageException(new Exception(msg));
			}
			quadruplesList.addRETURN(varToReturn.address.ToString());
		}
		
		}
		
		';'
		;

read	:	
		{
		VariableSymbol temp = null;
		}
		(
		'readint'
		{
		temp = getNewTemporalVarOfType(SymbolTable.integerName);
		quadruplesList.addREADINT(temp.address.ToString());
		}
		|'readchar'
		{
		temp = getNewTemporalVarOfType(SymbolTable.charName);
		quadruplesList.addREADCHAR(temp.address.ToString());
		}
		|'readdouble'
		{
		temp = getNewTemporalVarOfType(SymbolTable.doubleName);
		quadruplesList.addREADDOUBLE(temp.address.ToString());
		}
		
		) 
		'(' ')' {pOperandos.Push(temp);}
		;
		
print
scope {
	bool printline;
}
	:	('printline'{$print::printline = true;} | 'print' {$print::printline = false;}) '(' 
		(
		expression 
		{
		VariableSymbol varToPrint = pOperandos.Pop();
		MethodSymbol method = (MethodSymbol)actualScope;
		if(!SymbolTable.isPrimitiveType(varToPrint.type.name)) {
			string msg = "Error en " + method.fullyQualifiedName() + " en print(..). Se encontro tipo " + varToPrint.type.name + ", pero print(..) "
					+ "solo puede imprimir primitivos. ";
			manageException(new Exception(msg));
		}
		quadruplesList.addPRINT(varToPrint.address.ToString());
		}
		(',' expression
		{
		varToPrint = pOperandos.Pop();
		method = (MethodSymbol)actualScope;
		if(!SymbolTable.isPrimitiveType(varToPrint.type.name)) {
			string msg = "Error en " + method.fullyQualifiedName() + " en print(..). Se encontro tipo " + varToPrint.type.name + ", pero print(..) "
					+ "solo puede imprimir primitivos. ";
			manageException(new Exception(msg));
		}
		quadruplesList.addPRINT(varToPrint.address.ToString());
		}
		)*
		)?
		
		')' ';'
		{
		if($print::printline) {
			quadruplesList.addPRINTLINE();
		}
		}
		;

expression
	:	{$statement::inExpression = true;}
		es (relOp {pOperadores.Push($relOp.operador);} es {aplicaOperadorPendienteQueSea(operadoresRelacionales);})?;

es
	:	term {aplicaOperadorPendienteQueSea(masMenosOr);}
		(
			op = ('+' | '-' | 'or') {pOperadores.Push($op.text);} 
			term {aplicaOperadorPendienteQueSea(masMenosOr);}
		)*;
	
term	:	factor {aplicaOperadorPendienteQueSea(porEntreAnd);}
		(
			op = ('*' | '/' | 'and') {pOperadores.Push($op.text);} 
			factor {aplicaOperadorPendienteQueSea(porEntreAnd);}
		)*;

factor
	:	
		read
		| invoke
		| v = ID
		{
		VariableSymbol varSymbol = getVariable($v.text);
		pOperandos.Push(varSymbol);
		}
		arrayAccess?
		| obj = ID '.' var = ID
		{
		VariableSymbol objeto = getVariable($obj.text);
		VariableSymbol field = getField($obj.text, $var.text);
		VariableSymbol temp = getNewTemporalVarOfType(field.type.name);
		pOperandos.Push(temp);
		quadruplesList.addGETFIELD(temp.address.ToString(), objeto.address.ToString(), field.address.ToString());
		}
		
		| 'this' '.' var = ID
		{
		VariableSymbol field = getInstanceVariable($var.text);
		VariableSymbol temp = getNewTemporalVarOfType(field.type.name);
		pOperandos.Push(temp);
		MethodSymbol method = (MethodSymbol)actualScope;
		quadruplesList.addGETFIELD(temp.address.ToString(), method.getThisParameterAddress(), field.address.ToString());
		}	
			
			/*
		| ID '[' {pOperadores.Push("[");} expression ']' {pOperadores.Pop();} 
			{
			verifyIsVector($ID.text);
			VariableSymbol index = pOperandos.Pop();
			if(!index.type.name.Equals("int")) {
				MethodSymbol m = (MethodSymbol)actualScope;
				manageException(new Exception("En " + m.fullyQualifiedName() + ": El subindice del Vector " + $ID.text 
							+ " debe ser de tipo int."));
			}
			else {
				VariableSymbol arr = getVariable($ID.text);
				string tipo = typeOfVector(arr.type.name);
				VariableSymbol temp = getNewTemporalVarOfType(tipo);
				pOperandos.Push(temp);
				quadruplesList.addGETVECTORELEM(temp.address.ToString(), arr.address.ToString(), index.address.ToString());
			}
			}
			*/
		| INT	
		{
		try {
			int intConst = int.Parse($INT.text);
		}
		catch(Exception e) {
			MethodSymbol methodSymbol = (MethodSymbol)actualScope;
			string msg = "Error en " + methodSymbol.fullyQualifiedName() + ". Constante entera es demasiado grande o pequena para un int: " + $INT.text;
			manageException(new Exception(msg));
		}
		pushICONST($INT.text);
		}
		| CHAR	{pushCCONST($CHAR.text);}	
		| DOUBLE 
		{
		try {
			double doubleConst = double.Parse($DOUBLE.text);
		}
		catch(Exception e) {
			MethodSymbol methodSymbol = (MethodSymbol)actualScope;
			string msg = "Error en " + methodSymbol.fullyQualifiedName() + ". Constante double es demasiado grande o pequena para un double: " + $DOUBLE.text;
			manageException(new Exception(msg));
		}
		
		pushDCONST($DOUBLE.text);
		}
		| '('{pOperadores.Push("(");} expression ')' {pOperadores.Pop();}
		;
	
relOp returns[string operador]:	 op = ('==' | '!=' | '>' | '>=' | '<' | '<=') {$operador = $op.text;};

BOOL	:	'bool';

VOID	:	'void';

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;
    
INT 	:	('-')? ('0'..'9')+;

DOUBLE
    :   ('-' | '+')?((INT '.' INT*) |   ('.' INT+))
    ;

COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n' {$channel=Hidden;}
    |   '/*' ( options {greedy=false;} : . )* '*/' {$channel=Hidden;}
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=Hidden;}
    ;

CHAR:  '\'' ( ESC_SEQ | ~('\''|'\\') ) '\''
    ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;


fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

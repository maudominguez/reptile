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
}

@rulecatch {
    catch (RecognitionException ex) {
        throw ex;
    }
}

@lexer::members {

public override void ReportError(RecognitionException e)
{
	throw e;
}
}

@members {
SymbolTable directory;
Stack<string> pOperadores = new Stack<string>();
Stack<VariableSymbol> pOperandos = new Stack<VariableSymbol>();
QuadruplesList quadruplesList = new QuadruplesList();
string mainClassName = "Main";

Scope actualScope;
ClassSymbol mainClass;

LinkedList<string> operadoresRelacionales = new LinkedList<string>(new string[] {"==", "!=", ">", "<", ">=", "<="});
LinkedList<string> masMenosOr = new LinkedList<string>(new string[] {"+", "-", "or"});
LinkedList<string> porEntreAnd = new LinkedList<string>(new string[] {"*", "/", "and"});

protected override object RecoverFromMismatchedToken(IIntStream input, int ttype, BitSet follow)
{
      throw new MismatchedTokenException(ttype, input);
}

public override object RecoverFromMismatchedSet(IIntStream input, RecognitionException e, BitSet follow)
{
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
	actualScope.defineVariable(variable.name, variable);
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
		Exception e = new Exception("No se encontro la variable " + variable);
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

void generateInstanceVariableNotFoundError(string scope, string variable) {
	Exception e = new Exception("No se encontro la variable de instancia " + variable + " en " + scope);
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

void verifyIsVector(string var) {
	if(verifyVariableCanBeAccessed(var)) {
		VariableSymbol arr = actualScope.getVariableSymbol(var);
		if(!arr.type.isVectorType()) {
			generateIsNotVectorError(arr.name);
		}
	}
}

void generateIsNotVectorError(string variable) {
	Exception e = new Exception("La variable " + variable + " no es de ninguna clase Vector y por tanto no tiene definido el operador [] .");
	manageException(e);
}

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
				manageException(new Exception("Operador \"" + operador + "\" no es valido para " + 
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

public void printQuadruplesList() {
	Console.WriteLine(quadruplesList.ToString());
}

public void verifyMainMethodDefinedInMainClass() {
	MethodSymbol mainMethod = mainClass.getMethodSymbol("main");
	if(mainMethod == null) {
		string errorMsg = "Debe definir al metodo void main() {..} en la clase Main";
		manageException(new Exception(errorMsg));
	}
	else if(mainMethod.returnType.name != SymbolTable.voidName) {
		string errorMsg = "El tipo de retorno de main() {..} en la clase Main debe ser void";
		manageException(new Exception(errorMsg));
	}
}

public static void manageException(Exception e) {
	Console.WriteLine(e.ToString());
	throw new RecognitionException("Se encontro Error semantico\n");
}
}

public program	:	{createDirectories(); defineMainClass();} classDecl* {actualScope = mainClass;} classMain;

classMain
	:	'class' 'Main' '{' vars? methods '}' 
		{
		verifyMainMethodDefinedInMainClass();
		directory.printDirectory(); directory.printTypesDirectory(); printQuadruplesList();
		};

classDecl
    :   'class' clase = ID (superClass)? {registerClass($clase.text, $superClass.superClase);} '{' vars? methods? '}';

superClass returns[string superClase]:	'extends' ID {$superClase = $ID.text;};

vars
	:	'vars' ':' varDecl*;

varDecl
@init {
	ClassSymbol clase;
}
    :   (t = primitiveType | t = referenceType) {clase = directory.findType($t.tipo);} ID {registerVariableInScope($ID.text, clase);} ';' ;
    
primitiveType returns[string tipo]:	t = ('int'|'char' | 'double') {$tipo = $t.text;};

referenceType returns[string tipo]:	
				(vectorType {$tipo = $vectorType.t;}
				| ID	{$tipo = $ID.text;}	
				)
				;
				
vectorType returns[string t]:
				'CharVector' {$t = SymbolTable.charVectorName;}
				| 'IntVector' {$t = SymbolTable.integerVectorName;}
				| 'DoubleVector' {$t = SymbolTable.doubleVectorName;}
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
}
:	(tRet = primitiveType | tRet = referenceType | tRet = voidType) {tipoRetorno = directory.findType($tRet.tipo);} 
	ID {registrarMetodo(tipoRetorno, $ID.text);} 
	'(' formalParameters? ')' 
	'{' vars? someStatements '}' 
	{actualScope = ((MethodSymbol)actualScope).enclosingScope;}
	;
	
formalParam:	t = formalParamType ID {registerFormalParameter($ID.text, $t.tipo);};
	
formalParameters
:  t = formalParam (',' formalParam)* ;

someStatements
	:	statement*;

statement :	assignment
		|	invoke ';'
		|	if_inst
		|	while_inst
		|	return_inst
		|	read
		|	print
		| ';';
			
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
			quadruplesList.addOBJECT(temp.address.ToString(), tipo.countVariables().ToString());
			
			}
		| 'new' vectorType '[' {pOperadores.Push("[");} INT ']' {pOperadores.Pop();}	
			{
			VariableSymbol temp = getNewTemporalVarOfType($vectorType.t);
			pOperandos.Push(temp);
			quadruplesList.addVECTOR(temp.address.ToString(), $INT.text);
			
			
			}
		)
		{
		VariableSymbol right = pOperandos.Pop();
		if(!directory.validAssignment($assignment::leftType, right.type)) {
			manageException(new Exception("No se puede asignar " + right.name + " a " + $assignment::par2.name + " porque los tipos " + 
						$assignment::leftType.name + " y " + right.type.name + " no son compatibles."));
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
		else if($assignment::caso == 3) {	//ID[expression] = bla
			quadruplesList.addPUTVECTORELEM(right.address.ToString(), $assignment::par2.address.ToString(), $assignment::par1.address.ToString());			
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
	;
		//TODO verificar semantica en invocaciones
invoke	:	ID actualParameters	 //miObjeto(param1, param2,...);
		| ID '.' ID actualParameters	 //miObjeto.attr(param1, param2,...);
		;

if_inst	:	'if' '(' expression ')' '{' someStatements '}' ('else' '{' someStatements '}')?;

while_inst	:	'while' '(' expression ')' '{' someStatements '}';

return_inst	:	'return' expression? ';';

read	:	'read' '(' designator ')' ';';

print	:	'print' '(' expression ')' ';';
	
actualParameters
	:	'(' (expression (',' expression)*)? ')';
	
expression
	:	es (relOp {pOperadores.Push($relOp.operador);} es {aplicaOperadorPendienteQueSea(operadoresRelacionales);})?;

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
	:	invoke	//TODO verificar semantica y hacer acciones para llamadas a metodos
		| v = ID 
			{
			VariableSymbol varSymbol = getVariable($v.text);
			pOperandos.Push(varSymbol);
			}
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
		| ID '[' {pOperadores.Push("[");} expression ']' {pOperadores.Pop();} 
			{
			verifyIsVector($ID.text);
			VariableSymbol index = pOperandos.Pop();
			if(!index.type.name.Equals("int")) {
				manageException(new Exception("El subindice del Vector " + $ID.text + " debe ser de tipo int."));
			}
			else {
				VariableSymbol arr = getVariable($ID.text);
				string tipo = typeOfVector(arr.type.name);
				VariableSymbol temp = getNewTemporalVarOfType(tipo);
				pOperandos.Push(temp);
				quadruplesList.addGETVECTORELEM(temp.address.ToString(), arr.address.ToString(), index.address.ToString());
			}
			}
		| INT	{pushICONST($INT.text);}	//int constant
		| CHAR	{pushCCONST($CHAR.text);}	//char constant
		| DOUBLE {pushDCONST($DOUBLE.text);}	//double constant
		| '('{pOperadores.Push("(");} expression ')' {pOperadores.Pop();}
		;
	
relOp returns[string operador]:	 op = ('==' | '!=' | '>' | '>=' | '<' | '<=') {$operador = $op.text;};

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;
    
INT 	:	('0'..'9')+;

DOUBLE
    :   INT '.' INT*
    |   '.' INT+
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
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

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

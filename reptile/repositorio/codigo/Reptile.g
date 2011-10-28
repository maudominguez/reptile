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

Scope actualScope;
Scope globalScope = new GlobalScope();

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

void defineScopeGlobal() {
	globalScope = new GlobalScope();
	directory.Add("GlobalScope", (ScopeWithMethods)globalScope);
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

void generateInstanceVariableNotFoundError(string clase, string variable) {
	Exception e = new Exception("No se encontro la variable de instancia " + variable + " en el tipo " + clase);
	manageException(e);
}

void verifyInstanceVariableDefinedInThis(string var) {
	ScopeWithMethods enclosingScope = ((MethodSymbol)actualScope).enclosingScope;
	if(enclosingScope is GlobalScope) {
		Exception e = new Exception("No se puede usar 'this' si no es dentro de una clase.");
		manageException(e);
		return;
	}
	else {
		ClassSymbol clase = (ClassSymbol)enclosingScope;
		VariableSymbol instVariable = clase.getVariableSymbol(var);
		if(instVariable == null) {
			generateInstanceVariableNotFoundError(clase.name, var);
		}
	}
}

VariableSymbol getInstanceVariable(string var) {
	verifyInstanceVariableDefinedInThis(var);
	ScopeWithMethods enclosingScope = ((MethodSymbol)actualScope).enclosingScope;
	ClassSymbol clase = (ClassSymbol)enclosingScope;
	return clase.getVariableSymbol(var);
}

void verifyIsArray(string var) {
	if(verifyVariableCanBeAccessed(var)) {
		VariableSymbol arr = actualScope.getVariableSymbol(var);
		if(!arr.type.isArrayType()) {
			generateIsNotArrayError(arr.name);
		}
	}
}

void generateIsNotArrayError(string variable) {
	Exception e = new Exception("La variable " + variable + " no es un arreglo y por tanto no tiene definido el operador [] .");
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

public bool isRelationalOperator(string operador) {
	return operador.Equals(">") || operador.Equals("<") || operador.Equals(">=")
		|| operador.Equals("<=");
}

public bool isPorEntreAnd(string operador) {
	return operador.Equals("*") || operador.Equals("/") || operador.Equals("and");
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
				//TODO el temporal debe obtenerse del avail
				VariableSymbol temporal = new VariableSymbol("temporal", tipoResultado);
				 
				//TODO generar cuadruplo usando operador, left, right y temporal
				
				pOperandos.Push(temporal);
			}
			else {
				//TODO accion correctiva: sacar los dos operandos y el operador de sus pilas
				pOperadores.Pop();
				VariableSymbol right = pOperandos.Pop();
				VariableSymbol left = pOperandos.Pop();
				manageException(new Exception("Operador \"" + operador + "\" no es valido para " + 
					left.type.name + " " + left.name + ", " + right.type.name + " " + right.name));
			}
		}
	}
}

public VariableSymbol getNewTemporalVarOfType(string type) {
	ClassSymbol tipo = directory.findType(type);
	VariableSymbol temp = ((MethodSymbol)actualScope).getNewTemporal(tipo);
	return temp;
}

public void printQuadruplesList() {
	Console.WriteLine(quadruplesList.ToString());
}

public static void manageException(Exception e) {
	Console.WriteLine(e.ToString());
	throw new RecognitionException("Se encontro Error semantico\n");
}
}

public program	:	{createDirectories(); defineScopeGlobal();} classes? {actualScope = globalScope;} vars? methods? mainMethod;

mainMethod
	:	'void' 'main' '(' ')' '{'vars? someStatements '}' {directory.printDirectory(); directory.printTypesDirectory(); printQuadruplesList();} ;

classes	:	'classes' ':' classDecl*;

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
				('char' '[' ']' {$tipo = "char[]";}	//char[]
				|'int' '[' ']' {$tipo = "int[]";}//int[]
				| 'double' '[' ']' {$tipo = "double[]";}
				| ID	{$tipo = $ID.text;}	)//MiClase
				;

voidType returns[string tipo]:	t = 'void' {$tipo = $t.text;};

formalParamType returns[string tipo]:	(t = primitiveType	//char, int
					| t = referenceType) 	//char[], int[], MiClase
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
		
assignment	//TODO
	:	designator '=' 
		(
		expression
		| 'new' ID '(' ')' {directory.findType($ID.text);}
		| 'new' primitiveType '[' INT ']'	
		//TODO generar cuadruplo ILOAD para la constante int leida
		) 
		';' //TODO verificar que la expresion, new clase, o new arreglo es asignable al tipo del designat
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

designator
	:	
		v = ID {verifyVariableCanBeAccessed($v.text); } //variable local del metodo
		| obj = ID  '.' var = ID {verifyObjectAndInstVariableDefined($obj.text, $var.text); } //objeto.variable
		| 'this' '.' var = ID   {verifyInstanceVariableDefinedInThis($var.text);}    //this.variable
		| (ID '[' expression ']')	//arreglo[exp]
		{
		verifyIsArray($ID.text);

		//TODO verificar que el resultado de la expresion es un entero
		}
	;
	
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

factor	:	invoke	//TODO verificar semantica y hacer acciones para llamadas a metodos
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
		| ID '[' expression ']' 
		{
		//TODO estamos metiendo objetos basura solo para verificar su tipo
		verifyIsArray($ID.text);
		VariableSymbol indice = pOperandos.Pop();
		if(!indice.type.name.Equals("int")) {
			manageException(new Exception("El subindice del arreglo " + $ID.text + " debe ser de tipo int."));
		}
		else {
			VariableSymbol basura = actualScope.getVariableSymbol($ID.text);
			string tipo = basura.type.name.Substring(0, basura.type.name.Length - 2);
			ClassSymbol t = directory.findType(tipo);
			VariableSymbol basura2 = new VariableSymbol("basura2", t);
			pOperandos.Push(basura2);
		}
		//TODO verificar que el resultado de la expresion es un entero
		}
		| INT	{
		VariableSymbol temp = getNewTemporalVarOfType("int");
		pOperandos.Push(temp);
		quadruplesList.addILOAD($INT.text, temp.address.ToString());
		}
		| CHAR
		{
		VariableSymbol temp = getNewTemporalVarOfType("char");
		pOperandos.Push(temp);
		quadruplesList.addCLOAD($CHAR.text, temp.address.ToString());
		}
		| DOUBLE
		{
		VariableSymbol temp = getNewTemporalVarOfType("double");
		pOperandos.Push(temp);
		quadruplesList.addDLOAD($DOUBLE.text, temp.address.ToString());
		}
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

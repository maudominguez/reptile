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
Dictionary<string, ScopeWithMethods> directory;
Dictionary<string, ClassSymbol> typesDirectory;
Scope actualScope;
Scope globalScope = new GlobalScope();

protected override object RecoverFromMismatchedToken(IIntStream input, int ttype, BitSet follow)
{
      throw new MismatchedTokenException(ttype, input);
}

public override object RecoverFromMismatchedSet(IIntStream input, RecognitionException e, BitSet follow)
{
        throw e;
}

void printDirectory() {
	Console.WriteLine("Directory:");
	foreach(KeyValuePair<String,ScopeWithMethods> entry in directory) {
		Console.WriteLine(entry.Key + " -> " + entry.Value.name);
	}
}

void printTypesDirectory() {
	Console.WriteLine("Types Directory:");	
	foreach(KeyValuePair<String, ClassSymbol> entry in typesDirectory) {
		Console.Write(entry.Key + " -> " + entry.Value.name);
		if(entry.Value.superClass != null) {
			Console.Write( " superClass-> " + entry.Value.superClass.name);
		}
		Console.WriteLine();
	}
}

void createDirectories() {
	directory = new Dictionary<string, ScopeWithMethods>();
	typesDirectory = new Dictionary<string, ClassSymbol>();
}

void defineScopeGlobal() {
	globalScope = new GlobalScope();
	directory.Add("GlobalScope", (ScopeWithMethods)globalScope);
}

void registerPrimitiveTypes() {
	ClassSymbol integers = new ClassSymbol("int");
	typesDirectory.Add(integers.name, integers);
	ClassSymbol chars = new ClassSymbol("char");
	typesDirectory.Add(chars.name, chars);
	ClassSymbol integerArray = new ClassSymbol("int[]");
	typesDirectory.Add(integerArray.name, integerArray);
	ClassSymbol charArray = new ClassSymbol("char[]");
	typesDirectory.Add(charArray.name, charArray); 
	ClassSymbol tipoVoid = new ClassSymbol("void");
	typesDirectory.Add(tipoVoid.name, tipoVoid);
}

void registerClass(string className, string superClase) {
	try {
		ClassSymbol newClass = new ClassSymbol(className);
		directory.Add(newClass.name, newClass);
		typesDirectory.Add(newClass.name, newClass);
		actualScope = newClass;
		if(superClase != null) {
			registerSuperClass(newClass, superClase);
		}
	}
	catch(Exception exception) {
		manageException(exception);	//manejarException
	}
}

void registerSuperClass(ClassSymbol clase, string superClase) {
	try {
		ClassSymbol clasePadre;
		clasePadre = findType(superClase);
		clase.superClass = clasePadre;
	}
	catch(Exception exception) {
		manageException(exception);
	}
}

ClassSymbol findType(string type) {
	ClassSymbol classSymbol;
	if(!typesDirectory.TryGetValue(type, out classSymbol)) {
		manageException(new Exception("El tipo " + type + " no existe."));
	}
	return classSymbol;
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

void registerVariableInMethod(string variableName, string tipo) {
	ClassSymbol tipoParam = findType(tipo);
	VariableSymbol variableSymbol = new VariableSymbol(variableName, tipoParam);
	registerVariableInScope(variableName, tipoParam);
	MethodSymbol methodSymbol = (MethodSymbol) actualScope;	//casting para poder llamar a defineParameter(..)
	methodSymbol.defineParameter(variableName, variableSymbol);
}

public static void manageException(Exception e) {
	Console.WriteLine(e.ToString());
}

}

public program	:	{createDirectories(); defineScopeGlobal(); registerPrimitiveTypes();} classes? {actualScope = globalScope;} vars? methods? mainMethod;

mainMethod
	:	'void' 'main' '(' ')' '{'vars? someStatements '}' {printDirectory(); printTypesDirectory();} ;

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
    :   (t = primitiveType | t = referenceType) {clase = findType($t.tipo);} ID {registerVariableInScope($ID.text, clase);} ';' ;
    
    
primitiveType returns[string tipo]:	t = ('int'|'char') {$tipo = $t.text;};

referenceType returns[string tipo]:	
				('char' '[' ']' {$tipo = "char[]";}	//char[]
				|'int' '[' ']' {$tipo = "int[]";}//int[]
				| ID	{$tipo = $ID.text;}	)//MiClase
				;

voidType returns[string tipo]:	t = 'void' {$tipo = $t.text;};

formalParamType returns[string tipo]:	(t = primitiveType	//char, int
					| t = referenceType) 	//char[], int[], MiClase
					{$tipo = $t.tipo;};
					
/*
methods	:	methodsPrototypes methodsDefinitions;

methodsPrototypes
	:	'methods' 'prototypes' ':' methodPrototype*;
	
methodPrototype
	:	(primitiveType | referenceType | 'void') ID '(' formalParameters? ')' ';';
	
methodsDefinitions
	:	'methods' 'definitions' ':' methodDefinition*;

methodDefinition:	(primitiveType | referenceType | 'void') ID '(' formalParameters? ')' '{' vars? someStatements '}';
	*/

methods
	:	'methods' ':' methodDeclaration*;

methodDeclaration
@init {
	ClassSymbol tipoRetorno;
}
:	(tRet = primitiveType | tRet = referenceType | tRet = voidType) {tipoRetorno = findType($tRet.tipo);} 
	ID {registrarMetodo(tipoRetorno, $ID.text);} 
	'(' formalParameters? ')' 
	'{' vars? someStatements '}' 
	{actualScope = ((MethodSymbol)actualScope).enclosingScope;}
	;
	
formalParam:	t = formalParamType ID {registerVariableInMethod($ID.text, $t.tipo);};
	
formalParameters
:  t = formalParam (',' formalParam)* ;

someStatements
	:	statement*;

statement :	assignment
		|	invoke
		|	if_inst
		|	while_inst
		|	return_inst
		|	read
		|	print
		| ';';
		
assignment
	:	designator '=' expression ';';
	
invoke	:	ID actualParameters	';' //miObjeto(param1, param2,...);
		| ID '.' ID actualParameters	';' //miObjeto.attr(param1, param2,...);
		;

if_inst	:	'if' '(' condition ')' '{' someStatements '}' ('else' '{' someStatements '}')?;

while_inst	:	'while' '(' condition ')' '{' someStatements '}';

return_inst	:	'return' expression? ';';

read	:	'read' '(' designator ')' ';';

print	:	'print' '(' expression ')' ';';

designator
	:	ID (('.' ID) | ('[' expression ']'))?;
	
actualParameters
	:	'(' (expression (',' expression)*)? ')';
	
condition
	:	expression relOp expression;

expression
	:	term (('+' | '-') term)?;
	
term	:	factor (('*' | '/') factor)?;

factor	:	invoke
		| ID
		| ID '.' ID
		| ID '[' expression ']'
		| INT
		| CHAR
		| 'new' referenceType '(' ')' ';'
		| '(' expression ')'
		;
	
relOp	:	'==' | '!=' | '>' | '>=' | '<' | '<=';

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT 	:	('0'..'9')+;

FLOAT
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

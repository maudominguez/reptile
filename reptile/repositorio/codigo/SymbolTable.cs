using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class SymbolTable
{
    Dictionary<string, ScopeWithMethods> directory;
    public static string integerName = "int";
    public static string charName = "char";
    public static string doubleName = "double";
    public static string boolName = "bool";

    public static string arrayName = "array";
    public static ClassSymbol arrayClassSymbol = new ClassSymbol(arrayName, null);
    public static string voidName = "void";

    public static bool isPrimitiveType(string type)
    {
        if (type.Equals(integerName) || type.Equals(charName) || type.Equals(doubleName)
            || type.Equals(boolName))
        {
            return true;
        }
        return false;
    }

    public SymbolTable()
    {
        directory = new Dictionary<string, ScopeWithMethods>();
        ClassSymbol integers = new ClassSymbol(integerName, null);
        directory.Add(integers.name, integers);
        ClassSymbol chars = new ClassSymbol(charName, null);
        directory.Add(chars.name, chars);
        ClassSymbol doubles = new ClassSymbol(doubleName, null);
        directory.Add(doubles.name, doubles);
        ClassSymbol bools = new ClassSymbol(boolName, null);
        directory.Add(bools.name, bools);


        directory.Add(arrayClassSymbol.name, arrayClassSymbol);

        ClassSymbol tipoVoid = new ClassSymbol(voidName, null);
        directory.Add(tipoVoid.name, tipoVoid);

    }

    public string formattedSymbolTable()
    {
        StringBuilder res = new StringBuilder();
        int firstQuadrupleOfMainMethod = findType("Main").getMethodSymbol("main").firstQuadruple;
        res.Append(firstQuadrupleOfMainMethod);
        res.Append("\n");
        res.Append(directory.Count);    //number of classes
        res.Append("\n");
        foreach (KeyValuePair<String, ScopeWithMethods> entry in directory)
        {
            ClassSymbol classSymbol = (ClassSymbol)entry.Value;
            res.Append(classSymbol.name + "\n");
            res.Append(classSymbol.countVariables() + "\n");

            if (classSymbol.countVariables() > 0)
            {
                res.Append(classSymbol.getInstVarsTypesFormatted());
                res.Append("\n");
            }
            res.Append(classSymbol.getMethodSymbols().Count + "\n");

            foreach (KeyValuePair<string, MethodSymbol> element in classSymbol.getMethodSymbols())
            {
                MethodSymbol methodSymbol = element.Value;
                res.Append(methodSymbol.fullyQualifiedName() + "\n");
                int totalOfVars = methodSymbol.countTotalOfVariables();
                int numberOfLocalVars = methodSymbol.getLocalVariablesList().Count;
                int registerOfFirstLocal = methodSymbol.registerOfFirstLocal();
                res.Append(methodSymbol.firstQuadruple + "\n");
                res.Append(totalOfVars + "\n");    //total, includes params, locals and temps
                res.Append(numberOfLocalVars + "\n");  //number of local vars
                if (numberOfLocalVars > 0)
                {
                    res.Append(registerOfFirstLocal + "\n");   //register of the first local
                }
                foreach (VariableSymbol localVar in methodSymbol.getLocalVariablesList())
                {
                    if (isPrimitiveType(localVar.type.name))
                    {
                        res.Append(localVar.type.name);
                    }
                    else if(localVar is ArrayVariableSymbol) 
                    {
                        ArrayVariableSymbol localArray = (ArrayVariableSymbol)localVar;
                        res.Append(localArray.type.name);
                        res.Append(" ");
                        res.Append(localArray.parameterizedType.name);
                        res.Append(" ");
                        res.Append(localArray.getTotalNumberOfSlots());
                    }
                    else
                    {
                        res.Append("ref");
                    }
                    res.Append("\n");
                }
            }
        }
        return res.ToString();
    }

    public ClassSymbol resultType(ClassSymbol left, ClassSymbol right, string op)
    {
        ClassSymbol resultType = findType(voidName);
        //no operator works with void type
        if (left.name.Equals(voidName) || right.name.Equals(voidName))
        {
            return resultType;
        }

        //no operator works with arrays
        if (left.name.Equals(arrayName) || right.name.Equals(arrayName)) 
        {
            return resultType;
        }

        if (isAndOrOperator(op)) //and, or
        {
            if (left.name.Equals(boolName) && right.name.Equals(boolName))
            {
                resultType = findType(boolName);
            }
        }
        else if (isEqOrDifOperator(op))  // ==, !=
        {
            if (SymbolTable.isPrimitiveType(left.name) || SymbolTable.isPrimitiveType(right.name))
            {
                if (validAssignment(left, right) || validAssignment(right, left))
                {
                    resultType = findType(boolName);
                }
            }
            else
            {
                resultType = findType(boolName);    //reference types can always be compared
            }
        }
        else if (isArithmeticOperator(op))  //+, -, *, /
        {
            if (isIntOrDouble(left) && isIntOrDouble(right))
            {
                if (left.name.Equals(doubleName) || right.name.Equals(doubleName))
                {
                    resultType = findType(doubleName);
                }
                else
                {
                    resultType = findType(integerName);
                }
            }
        }
        else if (isRelationalOperator(op))  // >, >=, <, <=
        {
            if (isIntOrDouble(left) && isIntOrDouble(right))
            {
                resultType = findType(boolName);
            }
        }
        else
        {
            ReptileParser.manageException(new Exception("Operador desconocido: " + op));
        }

        return resultType;
    }

    public bool validAssignment(ClassSymbol left, ClassSymbol right)
    {
        //not allowed to assign a void to anything nor to assign anything to a void
        if (left.name.Equals(voidName) || right.name.Equals(voidName))
        {
            return false;
        }
        //not allowed to assign an array to anything nor to to assign anything to an array
        if (left.name.Equals(arrayName) || right.name.Equals(arrayName))
        {
            return false;
        }
        

        if (left.name.Equals(doubleName))
        {
            return right.name.Equals(doubleName) || right.name.Equals(integerName);
        }
        else if (isPrimitiveType(left.name))
        {
            return left.name.Equals(right.name);
        }
        else
        {
            return right.isChildOf(left);
        }
    }

    private bool isArithmeticOperator(string op)
    {
        bool res = op.Equals("+") || op.Equals("-") || op.Equals("*") || op.Equals("/");
        return res;
    }

    private bool isAndOrOperator(string op)
    {
        return op.Equals("and") || op.Equals("or");
    }

    private bool isEqOrDifOperator(string op)
    {
        return op.Equals("==") || op.Equals("!=");
    }

    private bool isRelationalOperator(string op)
    {
        return op.Equals(">") || op.Equals(">=") || op.Equals("<") || op.Equals("<=");
    }

    private bool isIntOrDouble(ClassSymbol tipo)
    {
        return tipo.name.Equals(integerName) || tipo.name.
            Equals(doubleName);
    }

    public void printDirectory()
    {
        Console.WriteLine("Directory:");
        foreach (KeyValuePair<String, ScopeWithMethods> entry in directory)
        {
            Console.WriteLine(entry.Value);
        }
    }

    /**
     * Solo imprime las clases. No imprime la informacion del scope global.
     */
    public void printTypesDirectory()
    {
        Console.WriteLine("Types Directory:");
        foreach (KeyValuePair<String, ScopeWithMethods> entry in directory)
        {
            if (entry.Value is ClassSymbol)
            {
                ClassSymbol clase = (ClassSymbol)entry.Value;
                Console.Write(entry.Key + " -> " + clase.name);
                if (clase.superClass != null)
                {
                    Console.Write(" superClass-> " + clase.superClass.name);
                }
                Console.WriteLine();
            }
        }
    }

    public ClassSymbol findType(string type)
    {
        ScopeWithMethods scopeWithMethods;
        if (!directory.TryGetValue(type, out scopeWithMethods) || scopeWithMethods is GlobalScope)
        {
            ReptileParser.manageException(new Exception("El tipo " + type + " no existe."));
        }
        return (ClassSymbol)scopeWithMethods;
    }

    public void Add(string scopeName, ScopeWithMethods scopeWithMethods)
    {
        if (directory.ContainsKey(scopeName))
        {
            ReptileParser.manageException(new Exception("Clase " + scopeName + " ya ha sido definida antes."));
            return;
        }
        directory.Add(scopeName, scopeWithMethods);
    }

}

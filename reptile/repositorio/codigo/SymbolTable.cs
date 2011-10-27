using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class SymbolTable
{
    Dictionary<string, ScopeWithMethods> directory;
    private string integerName = "int";
    private string charName = "char";
    private string doubleName = "double";
    private string boolName = "bool";
    private string integerArrayName = "int[]";
    private string charArrayName = "char[]";
    private string doubleArrayName = "double[]";
    private string voidName = "void";

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
        ClassSymbol integerArray = new ClassSymbol(integerArrayName, null);
	    directory.Add(integerArray.name, integerArray);
        ClassSymbol charArray = new ClassSymbol(charArrayName, null);
	    directory.Add(charArray.name, charArray);
        ClassSymbol doubleArray = new ClassSymbol(doubleArrayName, null);
	    directory.Add(doubleArray.name, doubleArray);
        ClassSymbol tipoVoid = new ClassSymbol(voidName, null);
	    directory.Add(tipoVoid.name, tipoVoid);
    }

    public ClassSymbol resultType(ClassSymbol left, ClassSymbol right, string op)
    {
        ClassSymbol resultType = findType(voidName);

        if(isAndOrOperator(op)) //and, or
        {
            if(left.name.Equals(boolName) && right.name.Equals(boolName))
            {
                resultType = findType(boolName);
            }
        }
        else if(isEqOrDifOperator(op))  // ==, !=
        {
            if(left.name.Equals(right.name))
            {
                resultType = findType(boolName);
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
            if(isIntOrDouble(left) && isIntOrDouble(right))
            {
                resultType = findType(boolName);
            }
        }
        else {
            ReptileParser.manageException(new Exception("Operador desconocido: " + op));
        }

        return resultType;
    }
   
    public bool validAssignment(ClassSymbol left, ClassSymbol right)
    {
        if(left.name.Equals(doubleName))
        {
            return right.name.Equals(doubleName) || right.name.Equals(integerName);
        }
        else if (left.isArrayType() || left.name.Equals(integerName) || left.name.Equals(charName))
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
            if(entry.Value is ClassSymbol) {
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

    public void Add(string key, ScopeWithMethods value)
    {
        directory.Add(key, value);
    }

}

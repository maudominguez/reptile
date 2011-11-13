using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ClassSymbol : ScopeWithMethods
{
    public ClassSymbol superClass;
    private static int START_ADDRESS = 0;
    private static int MAX_ADDRESS = 9999;
    private LinkedList<VariableSymbol> instanceVariablesList = new LinkedList<VariableSymbol>();

    public ClassSymbol(string name, ClassSymbol superClass)
    {
        this.name = name;
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();
        this.memory = new Memory(START_ADDRESS, MAX_ADDRESS);
        this.superClass = superClass;
        if (superClass != null)
        {
            for (int i = 1; i <= superClass.countVariables(); i++)
            {
                this.memory.nextAddress();
            }
        }
    }

    public string getInstVarsTypesFormatted()
    {
        StringBuilder res = new StringBuilder();
        if (superClass != null)
        {
            res.Append(superClass.getInstVarsTypesFormatted());
        }
        foreach (VariableSymbol instVar in instanceVariablesList)
        {
            if (SymbolTable.isPrimitiveType(instVar.type.name))
            {
                res.Append(instVar.type.name);
            }
            else
            {
                res.Append("ref");
            }
            res.Append(" ");
        }
        return res.ToString();
    }

    public override void defineVariable(string variableName, VariableSymbol variableSymbol)
    {
        base.defineVariable(variableName, variableSymbol);
        instanceVariablesList.AddLast(variableSymbol);
    }

    public override void verifyVariableIsNotDefined(string variableName)
    {
        if (getVariableSymbol(variableName) != null)
        {
            ReptileParser.manageException(new Exception("Variable " + variableName + " ya declarada en la clase "
                                        + name + " o en alguna super clase."));
        }
    }

    public LinkedList<VariableSymbol> getInstanceVariablesList()
    {
        return instanceVariablesList;
    }

    public Dictionary<string, MethodSymbol> getMethodSymbols()
    {
        return methods;
    }

    public int countVariables()
    {
        if (superClass == null)
        {
            return variables.Count;
        }
        return superClass.countVariables() + variables.Count;
    }

    public bool isVectorType()
    {
        return name.Equals(SymbolTable.charVectorName) || name.Equals(SymbolTable.doubleVectorName)
                || name.Equals(SymbolTable.integerVectorName);
    }

    public bool isVoidType()
    {
        return name.Equals("void");
    }

    public override MethodSymbol getMethodSymbol(string methodName)
    {
        MethodSymbol methodSymbol;
        if (!methods.TryGetValue(methodName, out methodSymbol))
        {
            if (superClass != null)
            {
                methodSymbol = superClass.getMethodSymbol(methodName);
            }
        }
        return methodSymbol;
    }

    public override VariableSymbol getVariableSymbol(string variableName)
    {
        VariableSymbol variableSymbol;
        if (!variables.TryGetValue(variableName, out variableSymbol))
        {
            if (superClass != null)
            {
                variableSymbol = superClass.getVariableSymbol(variableName);
            }
        }
        return variableSymbol;
    }

    public bool isChildOf(ClassSymbol sup)
    {
        if (name == sup.name)
        {
            return true;
        }
        if (superClass == null)
        {
            return false;
        }
        return superClass.isChildOf(sup);
    }


}

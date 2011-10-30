using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ClassSymbol : ScopeWithMethods
{
    public ClassSymbol superClass;
    private static int START_ADDRESS = 0;
    private static int MAX_ADDRESS = 9999;

    public ClassSymbol(string name, ClassSymbol superClass)
    {
        this.name = name;
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();
        this.memory = new Memory(START_ADDRESS, MAX_ADDRESS);
        this.superClass = superClass;
        if(superClass != null)
        {
            for (int i = 1; i <= superClass.countVariables(); i++ )
            {
                this.memory.nextAddress();
            }
        }
    }

    public int countVariables()
    {
        if(superClass == null) 
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
        if(!methods.TryGetValue(methodName, out methodSymbol))
        {
            if(superClass != null)
            {
                methodSymbol = superClass.getMethodSymbol(methodName);
            }
        }
        return methodSymbol;
    }

    public override VariableSymbol getVariableSymbol(string variableName)
    {
        VariableSymbol variableSymbol;
        if(!variables.TryGetValue(variableName, out variableSymbol))
        {
            if(superClass != null)
            {
                variableSymbol = superClass.getVariableSymbol(variableName);
            }
        }
        return variableSymbol;
    }

    public override void verifyVariableIsNotDefined(string variableName)
    {
        if (superClass != null)
        {
            superClass.verifyVariableIsNotDefined(variableName);
        }
        if (variables.ContainsKey(variableName))
        {
            String errorMsg = "La variable " + variableName + " ya esta declarada en la clase " + name
                      + " y no se permite declararla de nuevo en la misma clase ni en ninguna de sus subclases.";
            ReptileParser.manageException(new Exception(errorMsg));
        }
    }

    public bool isChildOf(ClassSymbol sup)
    {
        if(name == sup.name)
        {
            return true;
        }
        if(superClass == null)
        {
            return false;
        }
        return superClass.isChildOf(sup);
    }
}

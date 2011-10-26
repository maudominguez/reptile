using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ClassSymbol : ScopeWithMethods
{
    public ClassSymbol superClass;

    public ClassSymbol(string name)
    {
        this.name = name;
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();

    }

    public bool isArrayType()
    {
        return name.Contains("[]");
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

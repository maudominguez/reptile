using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class ClassSymbol : ScopeWithMethods
{
    public ClassSymbol superClass;

    public ClassSymbol(string name)
    {
        this.name = name;
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();

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

}

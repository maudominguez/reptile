using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class GlobalScope : ScopeWithMethods
{
    public GlobalScope()
    {
        name = "GlobalScope";
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();
    }
    public override MethodSymbol getMethodSymbol(string methodName)
    {
        MethodSymbol methodSymbol;
        methods.TryGetValue(methodName, out methodSymbol);
        return methodSymbol;
    }

    public override VariableSymbol getVariableSymbol(string variableName)
    {
        VariableSymbol variableSymbol;
        variables.TryGetValue(variableName, out variableSymbol);
        return variableSymbol;
    }
}

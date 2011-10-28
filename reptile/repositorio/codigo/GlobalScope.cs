using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class GlobalScope : ScopeWithMethods
{
    private static int START_ADDRESS = 20000;
    private static int MAX_ADDRESS = 29999;

    public GlobalScope()
    {
        name = "GlobalScope";
        methods = new Dictionary<string, MethodSymbol>();
        variables = new Dictionary<string, VariableSymbol>();
        this.memory = new Memory(START_ADDRESS, MAX_ADDRESS);
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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public abstract class ScopeWithMethods : Scope
{
    protected Dictionary<string, MethodSymbol> methods;

    public abstract MethodSymbol getMethodSymbol(string methodName);

    public void defineMethod(string methodName, MethodSymbol methodSymbol)
    {
        if (methods.ContainsKey(methodName))
        {
            ReptileParser.manageException(new Exception("Metodo " + methodName + " ya ha sido declarado."));
        }
        else
        {
            methods.Add(methodName, methodSymbol);
        }
    }

    public override string ToString()
    {
        StringBuilder res = new StringBuilder();
        res.Append("ScopeWithMethods = ");
        res.Append(name);
        res.Append("\n\n");

        res.Append(variablesToString());
        res.Append("\n\n");

        //append informacion de cada metodo
        res.Append("Methods defined in this scope:\n");
        foreach (KeyValuePair<String, MethodSymbol> entry in methods)
        {
            res.Append(entry.Value);
            res.Append("\n\n");
        }
        res.Append("\n------------------\n");
        return res.ToString();
    }

}


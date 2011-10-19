using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

abstract class ScopeWithMethods : Scope
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

}


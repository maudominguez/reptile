using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

abstract class Scope
{
    public string name;
    protected Dictionary<string, VariableSymbol> variables; //tabla de variables de instancia o globales

    public abstract VariableSymbol getVariableSymbol(string variableName);
    
    public void defineVariable(string variableName, VariableSymbol variableSymbol) 
    {
        if (variables.ContainsKey(variableName))
        {
            ReptileParser.manageException(new Exception("Variable " + variableName + " ya declarada."));
        }
        else
        {
            variables.Add(variableName, variableSymbol);
        }
    }

    

}

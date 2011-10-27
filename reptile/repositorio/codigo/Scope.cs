using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public abstract class Scope
{
    public string name;
    protected Dictionary<string, VariableSymbol> variables; //tabla de variables de instancia o globales
    protected Memory memory = new Memory();

    public abstract VariableSymbol getVariableSymbol(string variableName);
    
    public void defineVariable(string variableName, VariableSymbol variableSymbol) 
    {
        verifyVariableIsNotDefined(variableName);
        variableSymbol.address = memory.nextAddress();
        variables.Add(variableName, variableSymbol);
    }

    public String variablesToString()
    {
        StringBuilder res = new StringBuilder();
        res.Append("variables:\n");
        foreach(KeyValuePair<String, VariableSymbol> entry in variables)
        {
            res.Append(entry.Value);
            res.Append("\n");
        }
        return res.ToString();
    }

    public void verifyVariableIsNotDefined(string variableName)
    {
        if (variables.ContainsKey(variableName))
        {
            ReptileParser.manageException(new Exception("Variable " + variableName + " ya declarada."));
        }
    }


}

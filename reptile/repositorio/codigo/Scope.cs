﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public abstract class Scope
{
    public string name;
    protected Dictionary<string, VariableSymbol> variables; //tabla de variables de instancia o globales
    protected Memory memory;

    public abstract VariableSymbol getVariableSymbol(string variableName);
    
    public virtual void defineVariable(string variableName, VariableSymbol variableSymbol) 
    {
        verifyVariableIsNotDefined(variableName);
        try
        {
            variableSymbol.address = calculateAddress(variableSymbol);
        }
        catch(Exception e) {
            ReptileParser.manageException(e);
        }
        variables.Add(variableName, variableSymbol);
    }

    private int calculateAddress(VariableSymbol variableSymbol)
    {
        if (variableSymbol is ArrayVariableSymbol)
        {
            ArrayVariableSymbol arrayVarSymbol = (ArrayVariableSymbol)variableSymbol;
            int totalSlots = arrayVarSymbol.getTotalNumberOfSlots();
            return memory.nextArrayAddress(totalSlots);
        }
        else
        {
            return memory.nextAddress();
        }
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

    public virtual void verifyVariableIsNotDefined(string variableName)
    {
        if (variables.ContainsKey(variableName))
        {
            ReptileParser.manageException(new Exception("Variable " + variableName + " ya declarada."));
        }
    }

}

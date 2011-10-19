using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class MethodSymbol : Scope
{
    public ScopeWithMethods enclosingScope; //puede ser el scope global o una clase
    public ClassSymbol returnType; 
    public int cuadruplo;  //numero de cuadruplo donde empieza

    public LinkedList<VariableSymbol> parametros;

    public MethodSymbol(string name, ClassSymbol returnType, ScopeWithMethods enclosingScope)
    {
        this.name = name;
        this.returnType = returnType;
        this.enclosingScope = enclosingScope;
        variables = new Dictionary<string, VariableSymbol>();
        parametros = new LinkedList<VariableSymbol>();
    }

    public bool containsParameter(string variableName) {
        foreach(VariableSymbol varSymbol in parametros)
        {
            if(variableName.Equals(varSymbol.name))
            {
                return true;
            }
        }
        return false;
    }

    public void defineParameter(string variableName, VariableSymbol variableSymbol)
    {
        if (containsParameter(variableName))
        {
            ReptileParser.manageException(new Exception("Parametro " + variableName + " ya definido en " + this.name));
        }
        else
        {
            parametros.AddLast(variableSymbol);
        }
    }

    public override VariableSymbol getVariableSymbol(string variableName)
    {
        VariableSymbol variableSymbol;
        if(!variables.TryGetValue(variableName, out variableSymbol))
        {
            variableSymbol = enclosingScope.getVariableSymbol(variableName);
        }
        return variableSymbol;
    }

    

}

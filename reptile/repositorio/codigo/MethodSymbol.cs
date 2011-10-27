using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class MethodSymbol : Scope
{
    public ScopeWithMethods enclosingScope; //puede ser el scope global o una clase
    public ClassSymbol returnType; 
    public int cuadruplo;  //numero de cuadruplo donde empieza


    private LinkedList<VariableSymbol> parametros;

    public MethodSymbol(string name, ClassSymbol returnType, ScopeWithMethods enclosingScope)
    {
        this.name = name;
        this.returnType = returnType;
        this.enclosingScope = enclosingScope;
        variables = new Dictionary<string, VariableSymbol>();
        parametros = new LinkedList<VariableSymbol>();

    }

    public override string ToString()
    {
        StringBuilder res = new StringBuilder();
        res.Append(returnType.name);
        res.Append(" ");
        res.Append(name);
        res.Append("(");
        res.Append(parametrosToString());
        res.Append(") {\n");
        res.Append(variablesToString());
        res.Append("}");
        return res.ToString();
    }

    private string parametrosToString()
    {
        StringBuilder res = new StringBuilder();
        foreach (VariableSymbol param in parametros)
        {
            res.Append(param);
            res.Append(", ");
        }
        return res.ToString();
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
        verifyVariableIsNotDefined(variableName);
        defineVariable(variableName, variableSymbol);
        parametros.AddLast(variableSymbol);
    }

    public override VariableSymbol getVariableSymbol(string variableName)
    {
        VariableSymbol variableSymbol;
        variables.TryGetValue(variableName, out variableSymbol);
        return variableSymbol;
    }

    public int nextAddress()
    {
        return memory.nextAddress();
    }

}

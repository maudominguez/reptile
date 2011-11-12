using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class MethodSymbol : Scope
{
    public ScopeWithMethods enclosingScope; //puede ser el scope global o una clase
    public ClassSymbol returnType; 
    public int firstQuadruple;  //first quadruple of this method
    private static string this_param_name = "#this";

    //the first address is reserved for the "This" parameter that the compiler implicitly passes to the method
    private static int THIS_IMPLICIT_PARAMETER_ADDRESS = 10000;
    private static int START_ADDRESS = THIS_IMPLICIT_PARAMETER_ADDRESS;
    private static int MAX_ADDRESS = 19999;

    private LinkedList<VariableSymbol> parametros;
    private LinkedList<VariableSymbol> localVariables;

    public int registerOfFirstLocal()
    {
        return parametros.Count;
    }

    //includes params, local vars and temporals
    public int countTotalOfVariables()
    {
        return memory.countVariables();
    }

    //includes the implicit this parameter added by the compiler
    //so at least it will always be one or more
    public int countParameters() 
    {
        return parametros.Count;
    }

    public LinkedList<VariableSymbol> getParametersList()
    {
        return parametros;
    }

    public LinkedList<VariableSymbol> getLocalVariablesList()
    {
        return localVariables;
    }

    public void defineLocalVariable(string variableName, VariableSymbol variableSymbol)
    {
        verifyVariableIsNotDefined(variableName);
        defineVariable(variableName, variableSymbol);
        localVariables.AddLast(variableSymbol);
    }

    public IEnumerator<VariableSymbol> getParamIterator() {
        return parametros.GetEnumerator();
    }

    public string getThisParameterAddress()
    {
        return parametros.ElementAt(0).address.ToString();
        //return "" + THIS_IMPLICIT_PARAMETER_ADDRESS;
    }

    public VariableSymbol getThisParameter()
    {
        return getVariableSymbol(this_param_name);
    }

    public MethodSymbol(string name, ClassSymbol returnType, ScopeWithMethods enclosingScope)
    {
        this.name = name;
        this.returnType = returnType;
        this.enclosingScope = enclosingScope;
        this.memory = new Memory(START_ADDRESS, MAX_ADDRESS);
        variables = new Dictionary<string, VariableSymbol>();
        parametros = new LinkedList<VariableSymbol>();
        localVariables = new LinkedList<VariableSymbol>();
        defineThisImplicitParameter();
    }

    public bool returnsVoid()
    {
        return returnType.name.Equals(SymbolTable.voidName);
    }

    public string fullyQualifiedName()
    {
        return enclosingScope.name + "@" + name;
    }

    private void defineThisImplicitParameter()
    {
        VariableSymbol implicit_this_param = new VariableSymbol(this_param_name, (ClassSymbol)enclosingScope);
        defineParameter(this_param_name, implicit_this_param);
    }

    public VariableSymbol getNewTemporal(ClassSymbol type)
    {
        int addressTemp = memory.nextAddress();
        VariableSymbol temp = new VariableSymbol("@_" + addressTemp, type);
        temp.address = addressTemp;
        return temp;
        //al parecer no sera necesario definir (registrar) la var temporal en el metodo
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
        res.Append("first quadruple: ");
        res.Append(firstQuadruple);
        res.Append("\n");
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


}

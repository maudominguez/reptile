using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class VariableSymbol
{
    public string name;
    public ClassSymbol type;
    public int address;  //direccion en memoria

    public VariableSymbol(string name, ClassSymbol type)
    {
        this.name = name;
        this.type = type;

        //Stack<String> pes = new Stack<string>();
        //pes.ElementAt
    }

    public override string ToString()
    {
        return type.name + " " + name + " address: " + address;

    }
}

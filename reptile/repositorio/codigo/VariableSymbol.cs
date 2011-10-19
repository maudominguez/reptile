using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class VariableSymbol
{
    public string name;
    ClassSymbol type;
    int address;  //direccion en memoria

    public VariableSymbol(string name, ClassSymbol type)
    {
        this.name = name;
        this.type = type;
        this.address = address;
    }
}

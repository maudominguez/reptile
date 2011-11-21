using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class ArrayVariableSymbol : VariableSymbol
{
    private LinkedList<int> dimensions = new LinkedList<int>();
    public ClassSymbol parameterizedType;

    public ArrayVariableSymbol(string name, ClassSymbol parameterizedType)
        : base(name, SymbolTable.arrayClassSymbol)
    {
        this.parameterizedType = parameterizedType;
    }

    public void addDimension(int size)
    {
        dimensions.AddLast(size);
    }

    public int getDimension(int dim)
    {
        return dimensions.ElementAt(dim);
    }

    public int getTotalNumberOfSlots()
    {
        int total = 1;
        foreach(int dim in dimensions) {
            total *= dim;
        }
        return total;
    }

    public override string ToString()
    {
        StringBuilder res = new StringBuilder();
        res.Append(type.name);
        res.Append("<");
        res.Append(parameterizedType.name);
        res.Append(">");
        foreach (int dim in dimensions)
        {
            res.Append("[");
            res.Append(dim);
            res.Append("]");
        }
        res.Append(" ");
        res.Append(name);
        res.Append(" address: ");
        res.Append(address);
        return res.ToString();
    }

}

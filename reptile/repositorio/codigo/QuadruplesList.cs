using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;


class QuadruplesList
{
    LinkedList<Quadruple> quadruplesList = new LinkedList<Quadruple>();

    public void addICONST(string intConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("ICONST", intConstant, tempAddress));
    }

    public void addDCONST(string doubleConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("DCONST", doubleConstant, tempAddress));
    }

    public void addCCONST(string charConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("CCONST", charConstant, tempAddress));
    }

    public void addGETFIELD(string tempAddress, string objAddress, string fieldAddress)
    {
        quadruplesList.AddLast(new Quadruple("GETFIELD", tempAddress, objAddress, fieldAddress));
    }

    //Array Element Load
    public void addGETARRAYELEM(string tempAddress, string arrAddress, string index)
    {
        quadruplesList.AddLast(new Quadruple("GETARRAYELEM", tempAddress, arrAddress, index));
    }

    public void addEXPRESSION_OPER(string op, string op1Address, string op2Address, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple(op, op1Address, op2Address, tempAddress));
    }

    public override string ToString()
    {
        StringBuilder res = new StringBuilder();
        foreach (Quadruple quadruple in quadruplesList)
        {
            res.Append(quadruple);
            res.Append("\n");
        }
        return res.ToString();
    }

}

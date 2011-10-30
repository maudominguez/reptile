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

    //Vector Element Load
    public void addGETVECTORELEM(string tempAddress, string vectorAddress, string index)
    {
        quadruplesList.AddLast(new Quadruple("GETVECTORELEM", tempAddress, vectorAddress, index));
    }

    public void addEXPRESSION_OPER(string op, string op1Address, string op2Address, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple(op, op1Address, op2Address, tempAddress));
    }

    public void addOBJECT(string tempAddress, string nFields)
    {
        quadruplesList.AddLast(new Quadruple("OBJECT", tempAddress, nFields));
    }

    public void addVECTOR(string tempAddress, string nSlots)
    {
        quadruplesList.AddLast(new Quadruple("VECTOR", tempAddress, nSlots));
    }

    //se asigna el contenido de address1 a address2
    public void addASSIGNMENT(string address1, string address2)
    {
        quadruplesList.AddLast(new Quadruple("=", address1, address2));
    }

    public void addPUTFIELD(string rightAddress, string objAddress, string field)
    {
        quadruplesList.AddLast(new Quadruple("PUTFIELD", rightAddress, objAddress, field));
    }

    public void addPUTVECTORELEM(string rightAddress, string vectorAddress, string indexAddress)
    {
        quadruplesList.AddLast(new Quadruple("PUTVECTORELEM", rightAddress, vectorAddress, indexAddress));
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

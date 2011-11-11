using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;


class QuadruplesList
{
    //we start to count the quadruples in zero

    LinkedList<Quadruple> quadruplesList = new LinkedList<Quadruple>();

    public int nextNumberOfQuadruple()
    {
        return quadruplesList.Count();
    }

    public int countQuadruples()
    {
        return quadruplesList.Count;
    }

    public Quadruple getLastQuadruple()
    {
        return quadruplesList.ElementAt(quadruplesList.Count - 1);
    }

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

    public void addOBJECT(string tempAddress, string clase)
    {
        quadruplesList.AddLast(new Quadruple("OBJECT", tempAddress, clase));
    }

    public void addINTVECTOR(string tempAddress, string nSlots)
    {
        quadruplesList.AddLast(new Quadruple("INTVECTOR", tempAddress, nSlots));
    }

    public void addDOUBLEVECTOR(string tempAddress, string nSlots)
    {
        quadruplesList.AddLast(new Quadruple("DOUBLEVECTOR", tempAddress, nSlots));
    }

    public void addCHARVECTOR(string tempAddress, string nSlots)
    {
        quadruplesList.AddLast(new Quadruple("CHARVECTOR", tempAddress, nSlots));
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

    public void addRETURN(string varToReturn)
    {
        quadruplesList.AddLast(new Quadruple("RETURN", varToReturn));
    }

    public void addRETURNVOID()
    {
        quadruplesList.AddLast(new Quadruple("RETURNVOID"));
    }

    public void addSHOULD_RETURN_SOMETHING_ERROR(string fullyQualifiedMethodName)
    {
        quadruplesList.AddLast(new Quadruple("SHOULD_RETURN_SOMETHING_ERROR", fullyQualifiedMethodName));
    }

    public void addERA(string method)
    {
        quadruplesList.AddLast(new Quadruple("ERA", method));
    }

    public void addPARAM(string variable, string nParam)
    {
        quadruplesList.AddLast(new Quadruple("PARAM", variable, nParam));
    }

    public void addGOSUB(string method, string varToStoreResult)
    {
        quadruplesList.AddLast(new Quadruple("GOSUB", method, varToStoreResult));
    }

    public void addGOSUBVOID(string method)
    {
        quadruplesList.AddLast(new Quadruple("GOSUBVOID", method));
    }

    public void addGOTOFALSE(string condition, string quadruple)
    {
        quadruplesList.AddLast(new Quadruple("GOTOFALSE", condition, quadruple));
    }

    public void addGOTO(string quadruple)
    {
        quadruplesList.AddLast(new Quadruple("GOTO", quadruple));
    }

    public void addHALT()
    {
        quadruplesList.AddLast(new Quadruple("HALT"));
    }

    public override string ToString()
    {
        StringBuilder res = new StringBuilder();
        int countQuadruple = 0;
        foreach (Quadruple quadruple in quadruplesList)
        {
            //res.Append(countQuadruple + " ");
            countQuadruple++;
            res.Append(quadruple);
            res.Append("\n");
        }
        return res.ToString();
    }

    public string ToStringWithQuadrupleNumbers()
    {
        StringBuilder res = new StringBuilder();
        int countQuadruple = 0;
        foreach (Quadruple quadruple in quadruplesList)
        {
            res.Append(countQuadruple + " ");
            countQuadruple++;
            res.Append(quadruple);
            res.Append("\n");
        }
        return res.ToString();
    }

}

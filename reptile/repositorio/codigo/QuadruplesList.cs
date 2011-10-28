﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;


class QuadruplesList
{
    LinkedList<Quadruple> quadruplesList = new LinkedList<Quadruple>();

    public void addILOAD(string intConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("ILOAD", intConstant, tempAddress));
    }

    public void addDLOAD(string doubleConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("DLOAD", doubleConstant, tempAddress));
    }

    public void addCLOAD(string charConstant, string tempAddress)
    {
        quadruplesList.AddLast(new Quadruple("CLOAD", charConstant, tempAddress));
    }

    public void addGETFIELD(string tempAddress, string objAddress, string fieldAddress)
    {
        quadruplesList.AddLast(new Quadruple("GETFIELD", tempAddress, objAddress, fieldAddress));
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
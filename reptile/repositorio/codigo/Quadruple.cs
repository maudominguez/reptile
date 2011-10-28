using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


class Quadruple
{

    public string operador {get; set;}
    public string operando1 { get; set; }
    public string operando2 { get; set; }
    public string operando3 { get; set; }

    public Quadruple(string operador)
    {
        this.operador = operador;
    }

    public Quadruple(string operador, string op1) : this(operador)
    {
        this.operando1 = op1;
    }

    public Quadruple(string operador, string op1, string op2)
        : this(operador, op1)
    {
        this.operando2 = op2;
    }

    public Quadruple(string operador, string op1, string op2, string op3)
        : this(operador, op1, op2)
    {
        this.operando3 = op3;
    }

    public override string ToString()
    {
        return operador + " " + operando1 + " " + operando2 + " " + operando3;
    }

}

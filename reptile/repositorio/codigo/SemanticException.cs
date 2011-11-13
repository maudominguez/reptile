using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class SemanticException : Exception
{
    string m;

    public SemanticException (string message)
    {
        m = message;
    }

    public override string ToString()
    {
        return m;
    }

}

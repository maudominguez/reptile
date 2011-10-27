using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class Memory
{

    private int count = 0;

    public int nextAddress()
    {
        return count++;
    }

}


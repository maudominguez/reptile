using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class Memory
{

    private int count = 0;
    private int limit = 0;

    public Memory(int startAddress, int limit)
    {
        count = startAddress;
        this.limit = limit;
    }

    public int nextAddress()
    {
        if(count >= limit) 
        {
            throw new Exception("Ha excedido el numero maximo de variables que puede declarar ");
        }
        return count++;
    }

}


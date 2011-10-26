using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


class ConstantsMemory
{
    public static int SLOTS_FOR_EACH_TYPE = 5000;
    public static int START_ADDRESS = 50000;

    int integersCount;
    int doublesCount;
    int charsCount;

    public ConstantsMemory()
    {
        integersCount = START_ADDRESS;
        doublesCount = integersCount + SLOTS_FOR_EACH_TYPE;
        charsCount = doublesCount + SLOTS_FOR_EACH_TYPE;
    }

    public int nextInt()
    {
        return integersCount++;
    }

    public int nextDouble()
    {
        return doublesCount++;
    }

    public int nextChar()
    {
        return charsCount++;
    }
}


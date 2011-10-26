using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


class TemporalMemory
{
    public static int SLOTS_FOR_EACH_TYPE = 5000;
    public static int START_ADDRESS = 25000;

    int integersCount;
    int doublesCount;
    int charsCount;
    int boolCount;
    int objectsCount;

    public TemporalMemory()
    {
        integersCount = START_ADDRESS;
        doublesCount = integersCount + SLOTS_FOR_EACH_TYPE;
        charsCount = doublesCount + SLOTS_FOR_EACH_TYPE;
        boolCount = charsCount + SLOTS_FOR_EACH_TYPE;
        objectsCount = boolCount + SLOTS_FOR_EACH_TYPE;
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

    public int nextBool()
    {
        return boolCount++;
    }

    public int nextObject()
    {
        return objectsCount++;
    }
}


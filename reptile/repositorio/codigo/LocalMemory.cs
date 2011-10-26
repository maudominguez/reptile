using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class LocalMemory
{
    public static int SLOTS_FOR_EACH_TYPE = 5000;
    public static int START_ADDRESS = 65000;

    int integersCount;
    int doublesCount;
    int charsCount;
    int objectsCount;

    public LocalMemory()
    {
        integersCount = START_ADDRESS;
        doublesCount = integersCount + SLOTS_FOR_EACH_TYPE;
        charsCount = doublesCount + SLOTS_FOR_EACH_TYPE;
        objectsCount = charsCount + SLOTS_FOR_EACH_TYPE;
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

    public int nextObject()
    {
        return objectsCount++;
    }
}


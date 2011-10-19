using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Antlr.Runtime;

namespace reptile
{
    class Program
    {
        static void Main(string[] args)
        {
            bool archivoEncontrado = true;
            do
            {
                try
                {
                    archivoEncontrado = true;
                    Console.WriteLine("Ruta de archivo fuente a reconocer: ");
                    ANTLRStringStream input = new ANTLRFileStream(Console.In.ReadLine());
                    ReptileLexer lex = new ReptileLexer(input);
                    CommonTokenStream tokens = new CommonTokenStream(lex);
                    ReptileParser parser = new ReptileParser(tokens);
                    try
                    {
                        parser.program();
                        Console.WriteLine("Apropiado.\n");
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                        Console.WriteLine("No apropiado.\n");
                    }
                }
                catch (Exception fnfe)
                {
                    archivoEncontrado = false;
                    Console.WriteLine("No se puede leer archivo, verifique la ruta proporcionada.\n");
                }
            } while (!archivoEncontrado);


            Console.WriteLine("end...\n");
            Console.In.ReadLine();
        }
    }
}

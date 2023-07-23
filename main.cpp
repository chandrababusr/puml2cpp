#include <iostream>
#include <fstream>

#include "CppGenerator.hpp"

using namespace std;

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        cerr << "Usage: " << argv[0] << " <puml_file>" << endl;
        cerr << "Example: " << argv[0] << " example.wsd" << endl;
        return 1;
    }

    string fileName{argv[1]};

    puml::CppGenerator cppGen(fileName, "./tests/testSrc");

    int res = cppGen.parse();

    cout << "Parsing result: " << res << endl;

    cppGen.generate();

    return res;
}